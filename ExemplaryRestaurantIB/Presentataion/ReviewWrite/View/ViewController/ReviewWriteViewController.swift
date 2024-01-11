//
//  ReviewWriteViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/10/08.
//

import UIKit
import SnapKit
import Cosmos
import PhotosUI
import FirebaseDatabase
import FirebaseStorage

final class ReviewWriteViewController: UIViewController {
        
    lazy var storeNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 25.0, weight: .bold)
        
        return label
    }()
    
    lazy var cosmosView: CosmosView = {
        let cosmosView = CosmosView()
        cosmosView.settings.fillMode = .full
        cosmosView.settings.filledColor = .yellow
        cosmosView.settings.filledBorderColor = .black
        cosmosView.settings.emptyBorderColor = .black
        cosmosView.settings.totalStars = 5
        cosmosView.rating = 0
        cosmosView.settings.starSize = 35
        cosmosView.settings.starMargin = 5
        cosmosView.didFinishTouchingCosmos = self.didFinishTouchingCosmos()
        
        return cosmosView
    }()
    
    lazy var reviewWriteTextView: UITextView = {
        let textView = UITextView()
        textView.text = "음식 맛, 서비스 등 후기를 작성해주세요."
        textView.font = .systemFont(ofSize: 17.0, weight: .regular)
        textView.textColor = .systemGray
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.black.cgColor
        textView.delegate = self
        
        return textView
    }()
    
    lazy var textCountLabel: UILabel = {
        let label = UILabel()
        label.text = "(0/200)"
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 17.0, weight: .regular)
        
        return label
    }()
    
    lazy var photoPicker: PHPickerViewController = {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selection = .ordered
        config.selectionLimit = 3
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        
        return picker
    }()
    
    lazy var photoAddButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "사진 추가"
        config.image = UIImage(systemName: "photo")
        config.imagePlacement = .top
        config.imagePadding = 5.0
        config.buttonSize = .medium
        
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(didTapPhotoAddButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var cameraPicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.cameraDevice = .front
        picker.cameraCaptureMode = .photo
        picker.mediaTypes = ["public.image"]
        picker.delegate = self
        
        return picker
    }()
    
    lazy var cameraButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "직접 촬영"
        config.image = UIImage(systemName: "camera")
        config.imagePlacement = .top
        config.imagePadding = 5.0
        config.buttonSize = .medium
        
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(didTapCameraButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var photoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10.0
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        
        return collectionView
    }()
    
    lazy var registerButton: UIButton = {
        var attString = AttributedString("등록하기")
        attString.font = .systemFont(ofSize: 25.0, weight: .regular)
        attString.foregroundColor = .white
        
        var config = UIButton.Configuration.filled()
        config.buttonSize = .medium
        config.attributedTitle = attString
        config.background.cornerRadius = 0
        config.cornerStyle = .fixed
        
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(didTapRegistrationButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    
    // MARK: ViewModel
    let vm = ReviewWriteViewModel()
      

    // MARK: Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vm.viewDidLoad(self)
        setupLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        vm.viewWillAppear(self) { [weak self] in
            self?.present($0, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        vm.viewWillDisappear()
    }
    
    
    // MARK: overrides
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        vm.touchesBegan(touches, with: event, vc: self)
    }
    

    
    // MARK: actions
    func didFinishTouchingCosmos() -> (Double) -> () {
        return vm.didFinishTouchingCosmos()
    }
    
    @objc func didTapPhotoAddButton(_ sender: UIButton) {
        vm.didTapPhotoAddButton(sender, vc: self) { alert in
            self.present(alert, animated: true)
        }
    }
    
    @objc func didTapCameraButton(_ sender: UIButton) {
        vm.didTapCameraButton(sender, vc: self) { [weak self] picker, alert in
            guard alert == nil,
                  let picker = picker else {
                self?.present(alert!, animated: true); return}
            
            self?.present(picker, animated: true)
        }
    }
        
    @objc func didTapRegistrationButton(_ sender: UIButton) {
        vm.didTapRegistrationButton(sender, vc: self) { [weak self] in
            self?.present($0, animated: true)
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

// MARK: PHPickerViewControllerDelegate
extension ReviewWriteViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        vm.picker(picker, didFinishPicking: results, vc: self) { [weak self] in
            self?.present($0, animated: true)
        }
    }
        
}

// MARK: UIImagePickerControllerDelegate
extension ReviewWriteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        vm.imagePickerController(picker, didFinishPickingMediaWithInfo: info, vc: self) { [weak self] in
            self?.present($0, animated: true)
        }
     }
    
}

// MARK: PhotoCollectionView Extension
extension ReviewWriteViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return vm.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return vm.collectionView(collectionView, cellForItemAt: indexPath, vc: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return vm.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
    }
    
}

extension ReviewWriteViewController: ReviewWriteCellDelegate {
    
    func didTapThumnailImageDeleteButton(_ sender: UIButton) {
        vm.didTapThumnailImageDeleteButton(sender, vc: self)
    }
    
}

// MARK: Private
private extension ReviewWriteViewController {
            
    func setupLayout() {
        [
            storeNameLabel,
            cosmosView,
            reviewWriteTextView,
            textCountLabel,
            photoAddButton,
            cameraButton,
            photoCollectionView,
            registerButton
        ].forEach { view.addSubview($0) }
        
        storeNameLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.centerX.equalToSuperview()
        }
        
        cosmosView.snp.makeConstraints { make in
            make.top.equalTo(storeNameLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        
        reviewWriteTextView.snp.makeConstraints { make in
            make.top.equalTo(cosmosView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(50)
            make.bottom.equalTo(view.snp.centerY)
        }
        
        textCountLabel.snp.makeConstraints { make in
            make.top.equalTo(reviewWriteTextView.snp.bottom)
            make.trailing.equalTo(reviewWriteTextView.snp.trailing)
        }
        
        photoAddButton.snp.makeConstraints { make in
            make.top.equalTo(textCountLabel.snp.bottom).offset(30)
            make.leading.equalTo(reviewWriteTextView.snp.leading)
        }
        
        cameraButton.snp.makeConstraints { make in
            make.top.equalTo(photoAddButton.snp.bottom).offset(30)
            make.leading.equalTo(photoAddButton.snp.leading)
        }
        
        photoCollectionView.snp.makeConstraints { make in
            make.top.equalTo(photoAddButton.snp.top)
            make.leading.equalTo(photoAddButton.snp.trailing).offset(30)
            make.trailing.equalTo(textCountLabel.snp.trailing)
            make.bottom.equalTo(cameraButton.snp.bottom)
        }
        
        registerButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
    }
    
}


