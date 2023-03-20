//
//  ReviewWriteViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/10/08.
//

import UIKit
import Cosmos
import PhotosUI
import FirebaseDatabase
import FirebaseStorage

final class ReviewWriteViewController: UIViewController {
    
    // MARK: @IBOutlet
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var cosomosView: CosmosView!
    @IBOutlet weak var reviewWriteTextView: UITextView!
    @IBOutlet weak var textCountLabel: UILabel!
    @IBOutlet weak var photoAddButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var photoCollectionView: UICollectionView!
 
    
    // MARK: ViewModel
    let vm = ReviewWriteViewModel()
      

    // MARK: Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        vm.lastDance { [weak self] error in
            if let error = error {
                switch error {
                case .notLogin:
                    let alert = Alert.confirmAlert(title: "로그인 시 작성할 수 있습니다.") {
                        self?.navigationController?.popViewController(animated: true)
                    }
                    self?.present(alert, animated: true)
                    
                case .userListReadError:
                    let alert = Alert.confirmAlert(title: "현재 리뷰를 작성할 수 없습니다.")
                    self?.present(alert, animated: true)
                }
            } else {
                // loding stop
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        vm.removeStateDidChangeListener()
    }
    
    
    // MARK: touchesBegan
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // MARK: @IBAction
    // MARK: photoAddButton
    @IBAction func didTapPhotoAddButton(_ sender: UIButton) {
        vm.didTapPhotoAddButton(self) { picker in
            if let picker = picker {
                self.present(picker, animated: true)
            } else {
                let alert = Alert.confirmAlert(title: "사진은 최대 3장까지 선택 가능합니다.")
                self.present(alert, animated: true)
            }
        }
    }
    
    // MARK: cameraButton
    @IBAction func didTapCameraButton(_ sender: UIButton) {
        vm.didTapCameraButton(sender, delegate: self) { [weak self] picker in
            if let picker = picker {
                self?.present(picker, animated: true)
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
    
    // MARK: thumnailImageDeleteButton
    @IBAction func didTapThumnailImageDeleteButton(_ sender: UIButton) {
        
        vm.didTapThumnailImageDeleteButton(sender,
                                           photoCollectionView: self.photoCollectionView)
    }
    
    // MARK: registrationButton
    @IBAction func didTapRegistrationButton(_ sender: UIButton) {
     
        vm.didTapRegistrationButton(sender) { [weak self] error in
            
            if let error = error {
                switch error {
                case .conditionNotMet:
                    print(error.localizedDescription)
                    let alert = Alert.confirmAlert(title: "별점과 리뷰작성은 필수 입니다.")
                    self?.present(alert, animated: true)
                    
                case .userReviewUpdateError:
                    print(error.localizedDescription)
                    let alert = Alert.confirmAlert(title: "현재 리뷰를 작성할 수 없습니다. 1")
                    self?.present(alert, animated: true)
                    
                case .storeReviewUpdateError:
                    print(error.localizedDescription)
                    let alert = Alert.confirmAlert(title: "현재 리뷰를 작성할 수 없습니다. 2")
                    self?.present(alert, animated: true)
                    
                case .reviewImagePutError:
                    print(error.localizedDescription)
                    let alert = Alert.confirmAlert(title: "현재 리뷰를 작성할 수 없습니다. 3")
                    self?.present(alert, animated: true)
                    
                case .userInfoUpdateError:
                    print(error.localizedDescription)
                    let alert = Alert.confirmAlert(title: "현재 리뷰를 작성할 수 없습니다. 4")
                    self?.present(alert, animated: true)
                    
                case .storeInfoUpdateError:
                    print(error.localizedDescription)
                    let alert = Alert.confirmAlert(title: "현재 리뷰를 작성할 수 없습니다. 5")
                    self?.present(alert, animated: true)
                }
            } else {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

}

// MARK: reviewWriteTextViewDelegate
extension ReviewWriteViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        vm.textViewDidBeginEditing(textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        vm.textViewDidEndEditing(textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return vm.textView(textView,
                           shouldChangeTextIn: range,
                           replacementText: text,
                           textCountLabel: self.textCountLabel)
    }
    
}

// MARK: PhotoCollectionView Extension
extension ReviewWriteViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return vm.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return vm.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return vm.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
    }
    
}

// MARK: PHPickerViewControllerDelegate
extension ReviewWriteViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        vm.picker(picker, didFinishPicking: results) { error in
            if let error = error {
                switch error {
                case .canLoadObjectError, .loadObjectError:
                    let alert = Alert.confirmAlert(title: "사진을 불러 올 수 없습니다.")
                    self.present(alert, animated: true)
                }
                
            } else {
                self.photoCollectionView.reloadData()
            }
        }
    }
        
}

// MARK: UIImagePickerControllerDelegate
extension ReviewWriteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        vm.imagePickerController(picker, didFinishPickingMediaWithInfo: info) { [weak self] in
            guard let self = self else {return}
            
            self.vm.didTapPhotoAddButton(self) { picker in
                guard let picker = picker else {
                    let alert = Alert.confirmAlert(title: "사진은 최대 3장까지 선택 가능합니다.")
                    
                    self.present(alert, animated: true)
                    
                    return
                }
                
                self.present(picker, animated: true)
            }
        }
     }
    
}

// MARK: Private
private extension ReviewWriteViewController {
        
    func setupUI() {
        // storeNameLabel
        storeNameLabel.text = vm.storeName
        
        // MARK: cosmosView
        cosomosView.settings.fillMode = .full
        cosomosView.didFinishTouchingCosmos = vm.didFinishTouchingCosmos()
        
        // reviewWriteTextView
        reviewWriteTextView.layer.borderWidth = 1
        reviewWriteTextView.layer.borderColor = UIColor.black.cgColor
        reviewWriteTextView.delegate = self
        
        // photoCollectionView
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
    }
    
}


