//
//  ReviewWriteViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/10/08.
//

import UIKit
import PhotosUI
import Photos
import AVFoundation
import FirebaseDatabase
import FirebaseStorage


final class ReviewWriteViewController: UIViewController {
    
    // MARK: @IBOutlets
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var storeNameLabel: UILabel!
    @IBOutlet var starStackView: UIStackView!
    @IBOutlet var starSlider: StarSlider!
    @IBOutlet var reviewWriteTextView: UITextView!
    @IBOutlet var textCountLabel: UILabel!
    @IBOutlet var photoAddButton: UIButton!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var photoCollectionView: UICollectionView!
 
    
    // MARK: ViewModel
    let vm = ReviewViewModel()
      

    // MARK: Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
        setupGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.vm.createModel_handle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.vm.deleteModel_handle()
    }
    
    
    // MARK: @IBActions
    @IBAction func didTrackingStarSlider(_ sender: UISlider) {
        
        self.vm.updateModel_starScore(sender: sender,
                                      stackView: self.starStackView)
    }
    
    @IBAction func didTapPhotoAddButton(_ sender: UIButton) {
        self.present_PHPicker()
    }
    
    @IBAction func didTapCameraButton(_ sender: UIButton) {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] authority in
            if authority {
                DispatchQueue.main.async {
                    let picker = UIImagePickerController()
                    picker.sourceType = .camera
                    picker.allowsEditing = false
                    picker.mediaTypes = ["public.image"]
                    picker.delegate = self
                    
                    self?.present(picker, animated: true)
                }
            } else {
                let alert = UIAlertController(title: "현재 카메라 사용에 대한 접근 권한이 없습니다.",
                                              message: "설정 > {앱 이름} 탭에서 접근을 활성화 할 수 있습니다.",
                                              preferredStyle: .alert)
                let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in
                    alert.dismiss(animated: true, completion: nil)
                }
                let goToSetting = UIAlertAction(title: "설정으로 이동하기", style: .default) { _ in
                    guard let settingURL = URL(string: UIApplication.openSettingsURLString),
                          UIApplication.shared.canOpenURL(settingURL) else { return }
                    UIApplication.shared.open(settingURL, options: [:])
                }
                
                [cancel, goToSetting].forEach { alert.addAction($0) }
                
                DispatchQueue.main.async {
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    @IBAction func didTapThumnailImageDeleteButton(_ sender: UIButton) {
        
        self.vm.deleteModel_reviewImageList(sender: sender,
                                            collectionView: self.photoCollectionView)
    }
    
    @IBAction func didTapRegistrationButton(_ sender: UIButton) {
        
        self.vm.reviewRegistration()
 
        self.navigationController?.popViewController(animated: true)
    }

}

// MARK: TextView
extension ReviewWriteViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        self.vm.updateModel_reviewText(textView: textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        self.vm.updateModel_reviewText(textView: textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return self.vm.reviewTextCountLimit(textView: textView, range: range, text: text)
    }
}

// MARK: PhotoCollectionView
extension ReviewWriteViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.vm.reviewImageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell else {return UICollectionViewCell()}
        
        return self.vm.configure_photoCell(cell: cell, indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 100, height: collectionView.frame.height)
    }
    
}

// MARK: PHPicker
extension ReviewWriteViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
    
        var reviewImageList: [(UIImage, Int)] = []
        var number = 0
        
        let group = DispatchGroup()
        
        for result in results {
            group.enter()
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    guard let image = image as? UIImage else {return}
            
                    reviewImageList.append((image, number))
                    number += 1
                    group.leave()
                }
            } else {
                let alert = UIAlertController(title: "사진을 불러 올 수 없습니다.", message: nil, preferredStyle: .alert)
                let confirm = UIAlertAction(title: "확인", style: .cancel)
                alert.addAction(confirm)
                
                self.present(alert, animated: true)
                return
            }
        }
        
        group.notify(queue: .main) {
            if self.vm.reviewImageList.count == 0 {
                self.vm.createModel_reviewImageList(reviewImageList: reviewImageList)

            } else {
                self.vm.updateModel_reviewImageList(reviewImageList: reviewImageList)
            }
            self.photoCollectionView.reloadData()
        }
            
    }
        
}

// MARK: ImagePicker
extension ReviewWriteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] state in
            guard let self = self else {return}
            
            switch state {
            case .authorized, .limited:
                guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                    picker.dismiss(animated: true)
                    return
                }
                
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
                
                DispatchQueue.main.async {
                    self.present_PHPicker()
                }
            default:
                print("")
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
     }
    
}

// MARK: Private
private extension ReviewWriteViewController {
    
    func present_PHPicker() {
        let count = self.vm.reviewImageList.count
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selection = .ordered
        
        switch count {
        case 0:
            configuration.selectionLimit = 3
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            self.present(picker, animated: true)
        case 1:
            configuration.selectionLimit = 2
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            self.present(picker, animated: true)
        case 2:
            configuration.selectionLimit = 1
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            self.present(picker, animated: true)
        case 3:
            let alert = UIAlertController(title: "사진은 최대 3장까지 선택 가능합니다.", message: nil, preferredStyle: .alert)
            let confirm = UIAlertAction(title: "확인", style: .cancel)
            alert.addAction(confirm)
            
            self.present(alert, animated: true)
        default:
            print("x")
        }
    }
    
}

// MARK: Setup
extension ReviewWriteViewController: Setup {
    
    func setupUI() {
        setupUI_storeNameLabel()
        setupUI_reviewWriteTextView()
        setupUI_photoAddButton()
        setupUI_cameraButton()
        setupUI_photoCollectionView()
    }
    
    func setupLayout() {
        
    }
    
    func setupGesture() {
        setupGesture_scrollView()
    }
    
}

// MARK: for setupUI
private extension ReviewWriteViewController {
    
    func setupUI_storeNameLabel() {
        guard let label = self.storeNameLabel else {return}
        
        label.text = self.vm.storeName
    }
    
    func setupUI_reviewWriteTextView() {
        guard let textView = self.reviewWriteTextView,
              let reviewText = self.vm.reviewText else {return}
        
        textView.textColor = .gray
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.black.cgColor
        textView.text = reviewText
        
        textView.delegate = self
    }
    
    func setupUI_photoAddButton() {
        self.photoAddButton.layer.borderWidth = 1
        self.photoAddButton.layer.borderColor = UIColor.black.cgColor
    }
    
    func setupUI_cameraButton() {
        self.cameraButton.layer.borderWidth = 1
        self.cameraButton.layer.borderColor = UIColor.black.cgColor
    }
    
    func setupUI_photoCollectionView() {
        self.photoCollectionView.delegate = self
        self.photoCollectionView.dataSource = self
    }
    
}

// MARK: for setupGesture
private extension ReviewWriteViewController {
    
    func setupGesture_scrollView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
        
        self.scrollView.addGestureRecognizer(tap)
    }
    
    @objc
    func didTapView(_ sender: UIGestureRecognizer) {
        self.view.endEditing(true)
    }
    
}




