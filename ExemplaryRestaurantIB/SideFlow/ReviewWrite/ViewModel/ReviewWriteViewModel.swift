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
import RxSwift

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
    
    var storeName: String? {
        return self.model.storeName
    }
    
    
    let disposeBag = DisposeBag()
    
}

// MARK: Life Cycles
extension ReviewWriteViewModel {
    
    enum ReviewWriteReadError: Error {
        case notLogin           // 로그인 안함
        case userListReadError  // 유저 정보 읽기 실패
    }
    
    // 로그인 체크
    func addStateDidChangeListener() -> Promise<String> {
        return Promise { seal in
            self.model.handle = Auth.auth().addStateDidChangeListener { _, user in
                guard let user = user else {seal.reject(ReviewWriteReadError.notLogin); return}
                self.model.userUID = user.uid
                seal.fulfill(user.uid)
            }
        }
    }
    
    // 이름 가져오기
    func readFIR_UserList(_ userUID: String) -> Promise<String> {
        return Promise { seal in
            self.ref.child("UserList").child(userUID).child("userName").getData { error, snapshot in
                if let _ = error {
                    seal.reject(ReviewWriteReadError.userListReadError)
                } else {
                    guard let userName = snapshot?.value as? String else {seal.reject(ReviewWriteReadError.userListReadError); return}
                    
                    seal.fulfill(userName)
                }
            }
        }
    }
    
    func lastDance(completionHandler: @escaping (ReviewWriteReadError?) -> ()) {
        firstly {
            self.addStateDidChangeListener()
        }.then { userUID in
            self.readFIR_UserList(userUID)
        }.done { userName in
            self.model.userName = userName
            completionHandler(nil)
        }.catch { error in
            guard let error = error as? ReviewWriteReadError else {return}
            switch error {
            case .notLogin:
                completionHandler(.notLogin)
            case .userListReadError:
                completionHandler(.userListReadError)
            }
        }
    }
    
    func removeStateDidChangeListener() {
        Auth.auth().removeStateDidChangeListener(handle!)
    }

}

// MARK: photoAddButton
extension ReviewWriteViewModel {
    
    func didTapPhotoAddButton(_ delegate: ReviewWriteViewController, completionHandler: (PHPickerViewController?) -> ()) {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selection = .ordered
        
        var picker: PHPickerViewController
        
        switch model.reviewImageList.count {
        case 0:
            configuration.selectionLimit = 3
            picker = PHPickerViewController(configuration: configuration)
            picker.delegate = delegate
            completionHandler(picker)
            
        case 1:
            configuration.selectionLimit = 2
            picker = PHPickerViewController(configuration: configuration)
            picker.delegate = delegate
            completionHandler(picker)
            
        case 2:
            configuration.selectionLimit = 1
            picker = PHPickerViewController(configuration: configuration)
            picker.delegate = delegate
            completionHandler(picker)
            
        case 3:
            completionHandler(nil)
            
        default:
            print("x")
        }
    }
    
}

// MARK: cameraButton
extension ReviewWriteViewModel {
    
    func didTapCameraButton(_ sender: UIButton, delegate: ReviewWriteViewController, completionHandler: @escaping  (UIImagePickerController?) -> ()) {
        AVCaptureDevice.requestAccess(for: .video) { authority in
            if authority {
                DispatchQueue.main.async {
                    let picker = UIImagePickerController()
                    picker.sourceType = .camera
                    picker.allowsEditing = false
                    picker.mediaTypes = ["public.image"]
                    picker.delegate = delegate
                    
                    completionHandler(picker)
                }
            } else {
                completionHandler(nil)
            }
        }
    }
    
}

// MARK: thumnailImageDeleteButton
extension ReviewWriteViewModel {
    
    func didTapThumnailImageDeleteButton(_ sender: UIButton, photoCollectionView: UICollectionView) {
        let item = sender.tag
        let indexPath = IndexPath(item: item, section: 0)
        
        photoCollectionView.deleteItems(at: [indexPath])
        
        self.model.reviewImageList.remove(at: item)
    }
    
}

// MARK: registrationButton
extension ReviewWriteViewModel {
        
    enum ReviewWriteUpdateError: Error {
        case conditionNotMet            // 조건 미달성
        case userReviewUpdateError      // 유저 리뷰 업데이트 실패
        case storeReviewUpdateError     // 가게 리뷰 업데이트 실패
        case reviewImagePutError        // 리뷰 이미지 올리기 실패
        case userInfoUpdateError        // 유저 정보 업데이트 실패
        case storeInfoUpdateError       // 가게 정보 업데이트 실패
    }
    
    // MARK: registrationButton
    func didTapRegistrationButton(_ sender: UIButton, completionHandler: @escaping (ReviewWriteUpdateError?) -> ()) {
        guard let key = self.key else {return}
        
        firstly {
            self.updateFIS_ReviewImageList(key)
            
        }.then { urlList in
            when(fulfilled: self.updateFIR_UserReviewLiew(key, urlList: urlList),
                            self.updateFIR_StoreReviewList(key, urlList: urlList))
            
        }.then { userUID, storeUID in
            when(fulfilled: self.updateFIR_UserList(userUID),
                            self.updateFIR_StoreList(storeUID))
            
        }.done {
            completionHandler(nil)
            
        }.catch { error in
            guard let error = error as? ReviewWriteUpdateError else {return}
            
            var alert = Alert.confirmAlert(title: "")
            
            switch error {
            case .conditionNotMet:
                completionHandler(.conditionNotMet)
                
            case .userReviewUpdateError:
                completionHandler(.userReviewUpdateError)
                
            case .storeReviewUpdateError:
                completionHandler(.storeReviewUpdateError)
                
            case .reviewImagePutError:
                completionHandler(.reviewImagePutError)
                
            case .userInfoUpdateError:
                completionHandler(.userInfoUpdateError)
                
            case .storeInfoUpdateError:
                completionHandler(.storeInfoUpdateError)
            }
        }
    }
    
    // 이미지 생성
    private func updateFIS_ReviewImageList(_ key: String) -> Promise<[Int: URL]?> {
        return Promise { seal in
            let group = DispatchGroup()
            let reviewImageList = self.model.reviewImageList
            var urlList: [Int: URL] = [:]
            
            if reviewImageList.isEmpty {
                // 이미지 없음.
                seal.fulfill(nil)
            } else {
                // 이미지 있음
                for (num, image) in reviewImageList {
                    group.enter()
                    guard let data = image.jpegData(compressionQuality: 0.3) else {seal.reject(ReviewWriteUpdateError.reviewImagePutError); return}
                    
                    let reviewImageListRef = self.storageRef.child("ReviewImageList/\(key)/image\(num)")
                    
                    let uploadTask = reviewImageListRef.putData(data, metadata: nil) { _, error in
                        reviewImageListRef.downloadURL { url, error in
                            guard let downloadURL = url else {return}
                            urlList[num] = downloadURL
                            group.leave()
                        }
                    }
                }
            }
            
            group.notify(queue: .main) {
                seal.fulfill(urlList)
            }
        }
    }
    
    // 유저 리뷰 생성
    private func updateFIR_UserReviewLiew(_ key: String, urlList: [Int: URL]?) -> Promise<String> {
        return Promise { seal in
            guard let userUID = self.model.userUID,
                  let storeUID = self.model.storeUID,
                  let storeName = self.model.storeName,
                  let starScore = self.model.starScore,
                  let reviewText = self.model.reviewText else {seal.reject(ReviewWriteUpdateError.conditionNotMet);return}
            
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
                if let _ = error {
                    seal.reject(ReviewWriteUpdateError.userReviewUpdateError)
                } else {
                    seal.fulfill(userUID)
                }
            }
        }
    }
    
    // 가게 리뷰 생성
    private func updateFIR_StoreReviewList(_ key: String, urlList: [Int: URL]?) -> Promise<String> {
        return Promise { seal in
            guard let storeUID = self.model.storeUID,
                  let userUID = self.model.userUID,
                  let userName = self.model.userName,
                  let starScore = self.model.starScore,
                  let reviewText = self.model.reviewText else {seal.reject(ReviewWriteUpdateError.conditionNotMet); return}
            
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
                if let _ = error {
                    seal.reject(ReviewWriteUpdateError.storeReviewUpdateError)
                } else {
                    seal.fulfill(storeUID)
                }
            }
        }
    }

    // 유저 정보 업데이트
    private func updateFIR_UserList(_ userUID: String) -> Promise<Void> {
        return Promise { seal in
            let updateChildValues = ["reviewCount": ServerValue.increment(1)]
            
            self.ref.child("UserList").child(userUID).updateChildValues(updateChildValues) { error, _ in
                if let _ = error {
                    seal.reject(ReviewWriteUpdateError.userInfoUpdateError)
                } else {
                    seal.fulfill(())
                }
            }
        }
    }
    
    // 가게 정보 업데이트
    private func updateFIR_StoreList(_ storeUID: String) -> Promise<Void> {
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
                if let _ = error {
                    seal.reject(ReviewWriteUpdateError.storeInfoUpdateError)
                } else {
                    seal.fulfill(())
                }
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
           model.reviewText = textView.text
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

// MARK: PhotoCollectionView Extension
extension ReviewWriteViewModel {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return model.reviewImageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell else {return UICollectionViewCell()}
        
        let image = model.reviewImageList[indexPath.item].image
        cell.thumnailImageView.image = image
        cell.thumnailImageDeleteButton.tag = indexPath.item
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 100, height: collectionView.frame.height)
    }
    
}


// MARK: PHPickerViewControllerDelegate
extension ReviewWriteViewModel {

    enum PHPickerError: Error {
        case canLoadObjectError
        case loadObjectError
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult], completionHandler: @escaping (PHPickerError?) -> ()) {
        firstly {
            self.resultsMap(results)
        }.then { resultList in
            self.resultListLoadObject(resultList)
        }.done { imageList in
            self.updateModel_reviewImageList(imageList)
            completionHandler(nil)
        }.catch { error in
            guard let error = error as? PHPickerError else {return}
            switch error {
            case .canLoadObjectError:
                completionHandler(.canLoadObjectError)
            case .loadObjectError:
                completionHandler(.loadObjectError)
            }
        }
    }
    
    private func resultsMap(_ results: [PHPickerResult]) -> Promise<[Int: PHPickerResult]> {
        return Promise { seal in
            var resultList: [Int: PHPickerResult] = [:]
            var num = 0
            
            for result in results {
                resultList[num] = result
                num += 1
            }
            
            seal.fulfill(resultList)
        }
    }
    
    private func resultListLoadObject(_ resultList: [Int: PHPickerResult]) -> Promise<[Int: UIImage]> {
        return Promise { seal in
            let group = DispatchGroup()
            var imageList: [Int: UIImage] = [:]
            
            for (key, value) in resultList {
                group.enter()
                let itemProvider = value.itemProvider
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                        if let _ = error {
                            seal.reject(PHPickerError.loadObjectError)
                        } else {
                            guard let image = reading as? UIImage else {return}
                            imageList[key] = image
                            group.leave()
                        }
                    }
                } else {
                    seal.reject(PHPickerError.canLoadObjectError)
                }
            }
            
            group.notify(queue: .main) {
                seal.fulfill(imageList)
            }
        }
    }
    
    private func updateModel_reviewImageList(_ imageList: [Int: UIImage]) {
        let reviewImageList = imageList.sorted { $0.key < $1.key }
        
        for reviewImage in reviewImageList {
            self.model.reviewImageList.append((num: reviewImage.key, image: reviewImage.value))
        }
    }
    
}

// MARK: UIImagePickerControllerDelegate
extension ReviewWriteViewModel {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any], completionHandler: @escaping () -> ()) {
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] state in
            guard let self = self else {return}
            
            switch state {
            case .authorized, .limited:
                guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                    picker.dismiss(animated: true)
                    return
                }
                
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
                
                completionHandler()
            default:
                print("x")
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: cosmosView
extension ReviewWriteViewModel {
        
    func didFinishTouchingCosmos() -> (Double) -> () {
        return { rating in
            self.model.starScore = rating
        }
    }
    
}

extension ReviewWriteViewModel {
    
    func createModel(storeName: String?, storeUID: String?) {
        self.model.storeName = storeName
        self.model.storeUID = storeUID
    }
        
}












