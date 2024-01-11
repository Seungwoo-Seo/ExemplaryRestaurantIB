//
//  ReviewWriteViewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/10/11.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import PhotosUI
import PromiseKit

class ReviewWriteViewModel {
    
    private var model = ReviewWriteModel()
    
    private var handle: AuthStateDidChangeListenerHandle? {
        return self.model.handle
    }
    
    private var ref: DatabaseReference {
        return self.model.ref
    }
    
    private var storageRef: StorageReference {
        return self.model.storageRef
    }
    
    private var key: String? {
        return self.model.ref.childByAutoId().key
    }
        
    
    func createModel(storeName: String?, storeUID: String?) {
        self.model.storeName = storeName
        self.model.storeUID = storeUID
    }
    
}

// MARK: Life Cycles
extension ReviewWriteViewModel {
    
    func viewDidLoad(_ vc: ReviewWriteViewController) {
        vc.storeNameLabel.text = model.storeName
    }
    
    func viewWillAppear(_ vc: ReviewWriteViewController, completionHandler: @escaping (UIAlertController) -> ()) {
        firstly {
            self.addStateDidChangeListener()
        }
        .then { userUID in
            self.getUserName(userUID)
        }
        .done { [weak self] userName in
            self?.model.userName = userName
        }
        .catch { error in
            guard let error = error as? ReviewWriteError else {return}
            
            var alert = Alert.confirmAlert(title: "현재 리뷰를 작성할 수 없습니다.") { [weak vc] in
                vc?.navigationController?.popViewController(animated: true)
            }
            
            switch error {
            case .notLogin:
                alert = Alert.confirmAlert(title: "로그인 후 작성 가능합니다.") { [weak vc] in
                    vc?.navigationController?.popViewController(animated: true)
                }
                completionHandler(alert)
                
            case .notUserName:
                completionHandler(alert)
                
            default:
                completionHandler(alert)
            }
        }
    }
    
    func viewWillDisappear() {
        Auth.auth().removeStateDidChangeListener(handle!)
    }

}

extension ReviewWriteViewModel {
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, vc: ReviewWriteViewController) {
        vc.view.endEditing(true)
    }
    
}

extension ReviewWriteViewModel {
    
    func didFinishTouchingCosmos() -> (Double) -> () {
        return { rating in
            self.model.starScore = rating
        }
    }
    
    func didTapPhotoAddButton(_ sender: UIButton, vc: ReviewWriteViewController, completionHandler: (UIAlertController) -> ()) {
        
        vc.present(vc.photoPicker, animated: true)
    }
    
    func didTapCameraButton(_ sender: UIButton, vc: ReviewWriteViewController, completionHandler: @escaping  (UIImagePickerController?, UIAlertController?) -> ()) {
        AVCaptureDevice.requestAccess(for: .video) { authority in
            if authority {
                DispatchQueue.main.async { [weak vc] in
                    guard let vc = vc else {return}
                    vc.present(vc.cameraPicker, animated: true)
                }
                
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "현재 카메라 사용에 대한 접근 권한이 없습니다.",
                                                  message: "설정 > {앱 이름} 탭에서 접근을 활성화 할 수 있습니다.",
                                                  preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "취소", style: .cancel)
                    let goToSetting = UIAlertAction(title: "설정으로 이동하기", style: .default) { _ in
                        guard let settingURL = URL(string: UIApplication.openSettingsURLString),
                              UIApplication.shared.canOpenURL(settingURL) else {return}
                        UIApplication.shared.open(settingURL, options: [:])
                    }
                    
                    [cancel, goToSetting].forEach { alert.addAction($0) }
                    
                    completionHandler(nil, alert)
                }
            }
        }
    }
    
    func didTapRegistrationButton(_ sender: UIButton, vc: ReviewWriteViewController, completionHandler: @escaping (UIAlertController) -> ()) {
        guard let key = self.key else {return}
        
        firstly {
            when(fulfilled: self.addStateDidChangeListener(),
                            self.putReviewImageList(key))
        }
        .then { userUID, urlList in
            when(fulfilled: self.createUserReview(key, userUID: userUID, urlList: urlList),
                            self.createStoreReview(key, userUID: userUID, urlList: urlList))
        }
        .then { userUID, storeUID in
            when(fulfilled: self.updateUserInfo(userUID),
                            self.updateStoreInfo(storeUID))
        }
        .done { _, _ in
            let alert = Alert.confirmAlert(title: "성공") { [weak vc] in
                vc?.navigationController?.popViewController(animated: true)
            }
            completionHandler(alert)
        }
        .catch { error in
            guard let error = error as? ReviewWriteError else {return}
            
            var alert = Alert.confirmAlert(title: "현재 리뷰를 작성할 수 없습니다.")
            
            switch error {
            case .notEnough:
                alert = Alert.confirmAlert(title: "별점과 리뷰 작성은 필수입니다.")
                completionHandler(alert)
                
            case .userReviewCreate:
                completionHandler(alert)
                
            case .storeReviewCreate:
                completionHandler(alert)
                
            case .reviewImagePut:
                completionHandler(alert)
                
            case .userInfoUpdate:
                completionHandler(alert)
                
            case .storeInfoUpdate:
                completionHandler(alert)
                
            default:
                completionHandler(alert)
            }
        }
    }
    
}

// MARK: reviewWriteTextViewDelegate
extension ReviewWriteViewModel {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .systemGray {
            textView.textColor = .black
            textView.text = nil
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
           textView.textColor = .systemGray
           textView.text = "음식 맛, 서비스 등 후기를 작성해주세요."
       } else {
           self.model.reviewText = textView.text
       }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String, textCountLabel: UILabel) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        
        if newText.count <= 200 {
            textCountLabel.text = "(\(newText.count)/200)"
        }
        
        return newText.count <= 200
    }
    
}

// MARK: PHPickerViewControllerDelegate
extension ReviewWriteViewModel {

    enum PHPickerError: Error {
        case canLoadObjectError
        case loadObjectError
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult], vc: ReviewWriteViewController, completionHandler: @escaping (UIAlertController) -> ()) {
        
        // cancel 눌렀을 때
        if results.isEmpty && model.photoList?.isEmpty != true {
            picker.dismiss(animated: true)
            return
        }
    
        firstly {
            self.resultsMap(results)
        }
        .then { resultList in
            self.makePhotoList(resultList)
        }
        .done { photoList in
            DispatchQueue.main.async { [weak vc, weak picker] in
                self.model.photoList = photoList.sorted(by: {$0.num < $1.num})
                vc?.photoCollectionView.reloadData()
                picker?.dismiss(animated: true)
            }
        }
        .catch { error in
            guard let error = error as? PHPickerError else {return}
            switch error {
            case .canLoadObjectError, .loadObjectError:
                let alert = Alert.confirmAlert(title: "사진을 불러 올 수 없습니다.")
                completionHandler(alert)
            }
        }
    }

    private func resultsMap(_ results: [PHPickerResult]) -> Promise<[(Int, String, PHPickerResult)]> {
        return Promise { seal in
            var resultList: [(Int, String, PHPickerResult)] = []
            var num = 0
            
            for result in results {
                guard let identifier = result.assetIdentifier else {return}
                resultList.append((num, identifier, result))
                num += 1
            }
            
            seal.fulfill(resultList)
        }
    }
    
    private func makePhotoList(_ resultList: [(Int, String, PHPickerResult)]) -> Promise<[Photo]> {
        return Promise { seal in
            let group = DispatchGroup()
            var photoList: [Photo] = []
            
            for (num, identifier, result) in resultList {
                group.enter()
                
                let itemProvider = result.itemProvider
                guard itemProvider.canLoadObject(ofClass: UIImage.self) else {seal.reject(PHPickerError.canLoadObjectError); return}
                
                itemProvider.loadObject(ofClass: UIImage.self) { item, error in
                    guard error == nil,
                          let image = item as? UIImage else {seal.reject(PHPickerError.loadObjectError); return}
                    
                    let photo = Photo(num: num, identifier: identifier, image: image)
                    photoList.append(photo)
                    
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                seal.fulfill(photoList)
            }
        }
    }
    
}

// MARK: UIImagePickerControllerDelegate
extension ReviewWriteViewModel {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any], vc: ReviewWriteViewController, completionHandler: @escaping (UIAlertController) -> ()) {
        
        // 사진 찍으면 앨범을 수정해야하니까
        // 앨범에 수정할 수 있는 권한을 체크
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { state in
            
            let alert = Alert.confirmAlert(title: "권한이 없습니다.") { [weak picker] in
                picker?.dismiss(animated: true)
            }
            
            switch state {
            case .authorized, .limited:
                guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                    picker.dismiss(animated: true)
                    return
                }

                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                
                DispatchQueue.main.async { [weak picker, weak vc] in
                    guard let picker = picker,
                          let vc = vc else {return}
                    picker.dismiss(animated: true) {
                        vc.present(vc.photoPicker, animated: true)
                    }
                }

            default:
                DispatchQueue.main.async { [weak picker] in
                    picker?.dismiss(animated: true) {
                        completionHandler(alert)
                    }
                }
            }
        }

    }
    
}

// MARK: PhotoCollectionView Extension
extension ReviewWriteViewModel {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = model.photoList?.count else {return 0}
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, vc: ReviewWriteViewController) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell,
              let photoList = model.photoList else {return UICollectionViewCell()}
        
        if cell.delegate == nil {
            cell.delegate = vc
        }
        
        cell.thumnailImageView.image = photoList[indexPath.item].image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 100.0, height: collectionView.bounds.height)
    }
    
}

// MARK: thumnailImageDeleteButton
extension ReviewWriteViewModel {
    
    func didTapThumnailImageDeleteButton(_ sender: UIButton, vc: ReviewWriteViewController) {
        guard let indexPath = vc.photoCollectionView.indexPathForItem(at: sender.convert(CGPoint.zero, to: vc.photoCollectionView)) else {return}
        
        let identifier = model.photoList?[indexPath.item].identifier ?? ""
        if #available(iOS 16, *) {
            vc.photoPicker.deselectAssets(withIdentifiers: [identifier])
        }
        self.model.photoList?.remove(at: indexPath.item)
        vc.photoCollectionView.deleteItems(at: [indexPath])
        vc.photoCollectionView.reloadData()
    }
    
}

private extension ReviewWriteViewModel {
    
    enum ReviewWriteError: Error {
        case notLogin           // 로그인 안함
        case notUserName        // 유저 이름 가져오기 실패
        case notEnough             // 조건 미달성
        case userReviewCreate      // 유저 리뷰 업데이트 실패
        case storeReviewCreate     // 가게 리뷰 업데이트 실패
        case reviewImagePut        // 리뷰 이미지 올리기 실패
        case userInfoUpdate        // 유저 정보 업데이트 실패
        case storeInfoUpdate       // 가게 정보 업데이트 실패
    }
    
    // 로그인 체크
    func addStateDidChangeListener() -> Promise<String> {
        return Promise { seal in
            self.model.handle = Auth.auth().addStateDidChangeListener { _, user in
                guard let user = user else {seal.reject(ReviewWriteError.notLogin); return}
                seal.fulfill(user.uid)
            }
        }
    }
    
    // 이름 가져오기
    func getUserName(_ userUID: String) -> Promise<String> {
        return Promise { seal in
            self.ref.child("UserList").child(userUID).child("userName").getData { error, snapshot in
                guard error == nil, let userName = snapshot?.value as? String else {seal.reject(ReviewWriteError.notUserName); return}

                seal.fulfill(userName)
            }
        }
    }
    
    // 리뷰 이미지들을 Storage에 올리고 url 다운로드
    private func putReviewImageList(_ key: String) -> Promise<[Int: URL]?> {
        return Promise { seal in
            let group = DispatchGroup()
            var urlList: [Int: URL] = [:]
            
            guard let photoList = self.model.photoList else {seal.fulfill(nil); return}
            // 이미지 있음
            photoList.forEach { photo in
                group.enter()
                guard let data = photo.image.jpegData(compressionQuality: 0.3) else {seal.reject(ReviewWriteError.reviewImagePut); return}
                
                let reviewImageListRef = self.storageRef.child("ReviewImageList/\(key)/image\(photo.num)")
                
                reviewImageListRef.putData(data, metadata: nil) { _, error in
                    reviewImageListRef.downloadURL { url, error in
                        guard error == nil, let downloadURL = url else {return}
                        
                        urlList[photo.num] = downloadURL
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                seal.fulfill(urlList)
            }
        }
    }
    
    // 유저 리뷰 생성
    private func createUserReview(_ key: String, userUID: String, urlList: [Int: URL]?) -> Promise<String> {
        return Promise { seal in
            guard let storeUID = self.model.storeUID,
                  let storeName = self.model.storeName,
                  let starScore = self.model.starScore,
                  let reviewText = self.model.reviewText else {seal.reject(ReviewWriteError.notEnough);return}
            
            var post: [String: Any]
            
            if let urlList = urlList {
                let urlStringList = urlList.sorted(by: {$0.key < $1.key}).map { $0.value.absoluteString }
                            
                post = ["storeName": storeName,
                        "storeUID": storeUID,
                        "starScore": starScore,
                        "reviewText": reviewText,
                        "reviewImageURL": urlStringList,
                        "identifier": key,
                        "timeStamp": Int(Date().timeIntervalSince1970)]
            } else {
                post = ["storeName": storeName,
                        "storeUID": storeUID,
                        "starScore": starScore,
                        "reviewText": reviewText,
                        "identifier": key,
                        "timeStamp": Int(Date().timeIntervalSince1970)]
            }
            
            let updateChildValues = [key: post]
            
            self.ref.child("UserReviewList").child(userUID).updateChildValues(updateChildValues) { error, _ in
                guard error == nil else {seal.reject(ReviewWriteError.userReviewCreate); return}
                seal.fulfill(userUID)
            }
        }
    }
    
    // 가게 리뷰 생성
    private func createStoreReview(_ key: String, userUID: String, urlList: [Int: URL]?) -> Promise<String> {
        return Promise { seal in
            guard let storeUID = self.model.storeUID,
                  let userName = self.model.userName,
                  let starScore = self.model.starScore,
                  let reviewText = self.model.reviewText else {seal.reject(ReviewWriteError.notEnough); return}
            
            var post: [String: Any]
            
            if let urlList = urlList {
                let urlStringList = urlList.sorted(by: {$0.key < $1.key}).map { $0.value.absoluteString }
                
                post = ["userName": userName,
                        "userUID": userUID,
                        "starScore": starScore,
                        "reviewText": reviewText,
                        "reviewImageURL": urlStringList,
                        "identifier": key,
                        "timeStamp": Int(Date().timeIntervalSince1970)]
                
            } else {
                post = ["userName": userName,
                        "userUID": userUID,
                        "starScore": starScore,
                        "reviewText": reviewText,
                        "identifier": key,
                        "timeStamp": Int(Date().timeIntervalSince1970)]
            }
            
                        
            let updateChildValues = [key: post]

            self.ref.child("StoreReviewList").child(storeUID).updateChildValues(updateChildValues) { error, _ in
                guard error == nil else {seal.reject(ReviewWriteError.storeReviewCreate); return}
                seal.fulfill(storeUID)
            }
        }
    }

    // 유저 정보 업데이트
    private func updateUserInfo(_ userUID: String) -> Promise<Void> {
        return Promise { seal in
            let updateChildValues = ["reviewCount": ServerValue.increment(1)]
            
            self.ref.child("UserList").child(userUID).updateChildValues(updateChildValues) { error, _ in
                guard error == nil else {seal.reject(ReviewWriteError.userInfoUpdate); return}
                seal.fulfill(())
            }
        }
    }
    
    // 가게 정보 업데이트
    private func updateStoreInfo(_ storeUID: String) -> Promise<Void> {
        return Promise { seal in
            self.ref.child("StoreList").child(storeUID).runTransactionBlock({ currentData in
                guard var post = currentData.value as? [String: AnyObject] else {return TransactionResult.success(withValue: currentData)}
                
                var reviewCount = post["reviewCount"] as! Int
                var reviewTotal = post["reviewTotal"] as! Int
                var reviewAverage = post["reviewAverage"] as! Double
                
                reviewCount += 1
                reviewTotal += Int(self.model.starScore!)
                reviewAverage = Double(String(format: "%.1f", Double(reviewTotal) / Double(reviewCount)))!
                
                post["reviewCount"] = reviewCount as AnyObject
                post["reviewTotal"] = reviewTotal as AnyObject
                post["reviewAverage"] = reviewAverage as AnyObject
                
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }) { error, _, _ in
                guard error == nil else {seal.reject(ReviewWriteError.storeInfoUpdate); return}
                seal.fulfill(())
            }
        }
    }
    
}




