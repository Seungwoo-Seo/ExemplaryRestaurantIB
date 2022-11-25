//
//  ReviewViewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/10/11.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Kingfisher

class ReviewViewModel {
    
    private var model = ReviewModel()
    
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
    
    var storeUID: String? {
        return self.model.storeUID
    }
    
    var userUID: String? {
        return self.model.userUID
    }
    
    var userName: String? {
        return self.model.userName
    }
    
    
    
    var starScore: Int? {
        return self.model.starScore
    }
    
    var reviewText: String? {
        return self.model.reviewText
    }
    
    var reviewImageList: [(image: UIImage, number: Int)] {
        return self.model.reviewImageList
    }
    

    
    
    var reviewList: [(Review, [UIImage?])] {
        return self.model.reviewList
    }
    
    var userReviewList: [String: Review]? {
        return self.model.userReviewList
    }
    
    var userReviewImageList: [String: [UIImage]]? {
        return self.model.userReviewImageList
    }
    
    var finalUserReviewList: [(Review, [UIImage]?)] {
        return self.model.finalUserReviewList
    }
    
}
 
// MARK: model
extension ReviewViewModel {
    
    // MARK: create
    func createModel_handle() {
        self.model.handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self,
                  let user = user else {return}
            
            let userUID = user.uid
            self.createModel_userUID(userUID: userUID)
            self.readRef_userName { userName in
                self.createModel_userName(userName: userName)
            }
        }
    }
    
    func createModel_storeName(storeName: String?) {
        self.model.storeName = storeName
    }
    
    func createModel_storeUID(storeUID: String?) {
        self.model.storeUID = storeUID
    }
    
    func createModel_userUID(userUID: String) {
        self.model.userUID = userUID
    }
    
    func createModel_userName(userName: String) {
        self.model.userName = userName
    }
    
    func createModel_starScore(starScore: Int?) {
        self.model.starScore = starScore
    }

    func createModel_reviewText(reviewText: String?) {
        self.model.reviewText = reviewText
    }
    
    func createModel_reviewImageList(reviewImageList: [(UIImage, Int)]) {
        self.model.reviewImageList = reviewImageList
    }
    

    
    // MARK: update
    func updateModel_starScore(sender: UISlider, stackView: UIStackView) {
        let starScore = Int(round(sender.value))
        for index in 0...4 {
            if let star = stackView.subviews[index] as? UIImageView {
                
                if index <= starScore {
                    star.image = UIImage(systemName: "star.fill")
                    star.tintColor = .yellow
                } else {
                    star.image = UIImage(systemName: "star")
                    star.tintColor = .black
                }
            }
        }
        
        self.createModel_starScore(starScore: starScore)
    }
    
    
    func updateModel_reviewText(textView: UITextView) {
        var reviewText: String? = ""
        
        if textView.text == "음식 맛, 서비스 등 후기를 작성해주세요." {
            textView.textColor = .black
            textView.text = ""
            reviewText = textView.text
            
        } else if textView.text == "" {
            textView.textColor = .gray
            textView.text = "음식 맛, 서비스 등 후기를 작성해주세요."
            reviewText = textView.text
            
        } else {
            reviewText = textView.text
        }
    
        self.createModel_reviewText(reviewText: reviewText)
    }
    
    
    func updateModel_reviewImageList(reviewImageList: [(UIImage, Int)]) {
        for reviewImage in reviewImageList {
            self.model.reviewImageList.append(reviewImage)
        }
    }
    
    // MARK: delete
    func deleteModel_handle() {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    func deleteModel_reviewImageList(sender: UIButton, collectionView: UICollectionView) {
        let item = sender.tag
        let indexPath = IndexPath(item: item, section: 0)
        
        collectionView.deleteItems(at: [indexPath])
        
        self.model.reviewImageList.remove(at: item)
    }
    
    
    
    // ReviewViewController 에서 사용
    // 데이터 전달들은 잘 됩니다.
    func setupModel_userReviewList(_ userReviewList: [String: Review]) {
        self.model.userReviewList = userReviewList
    }
    
    
    // 자 여긴 문제 없이 데이터 전달 완료
    func setupModel_userReviewImageList(_ userReviewImageList: [String: [UIImage]]) {
        
        self.model.userReviewImageList = userReviewImageList
    }
    
    
    
    func setupModel_finalUserReviewList(_ finalUserReview: (Review, [UIImage]?)) {
        print("----- 이거슨 \(finalUserReview)")
        
        self.model.finalUserReviewList.append(finalUserReview)
        print("--- 결과 확인 \(self.model.finalUserReviewList)")
        
    }
    
}
    
    
// MARK: ref
extension ReviewViewModel {
    
    // MARK: read
    func readRef_userName(completionHandler: @escaping (String) -> ()) {
        guard let userUID = self.userUID else {return}
        self.ref.child("UserList").child(userUID).child("userName").getData { error, snapshot in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                let userName = snapshot?.value as? String ?? "Unknown"
                completionHandler(userName)
            }
        }
    }
    
    // MAKR: update
    func updateRef_userReivewList(key: String) {
        guard let userUID = self.userUID,
              let storeName = self.storeName,
              let storeUID = self.storeUID,
              let starScore = self.starScore,
              let reviewText = self.reviewText else {print("조건 미달성");return}
        
        let post: [String: Any] = ["storeName": storeName,
                                   "storeUID": storeUID,
                                   "starScore": starScore,
                                   "reviewText": reviewText]
        
        let childUpdates = ["\(key)": post]
        
        self.ref.child("UserReviewList").child("\(userUID)ReviewList").updateChildValues(childUpdates)
    }
    
    func updateRef_storeReivewList(key: String) {
        guard let userName = self.userName,
              let storeUID = self.storeUID,
              let starScore = self.starScore,
              let reviewText = self.reviewText else {print("조건 미달성");return}
        
        let post: [String: Any] = ["identifier": key,
                                   "userName": userName,
                                   "starScore": starScore,
                                   "reviewImageCount": self.reviewImageList.count,
                                   "reviewText": reviewText]
        
        let childUpdates = ["\(key)": post]
        
        self.ref.child("StoreReviewList").child("\(storeUID)ReviewList").updateChildValues(childUpdates)
    }
    
}

// MARK: Storage
extension ReviewViewModel {
    
    func createStorage_reviewImageList(key: String) {
        
        guard !self.reviewImageList.isEmpty else {return}
        
        
        let group = DispatchGroup()
        NotificationCenter.default.post(name: NSNotification.Name("createStorage_reviewImageList"), object: nil)
        
        for (image, number) in self.reviewImageList {
            
            
            group.enter()
            let reviewImageListRef = self.storageRef.child("reviewImageList/\(key)/image\(number)")
            
            guard let data = image.jpegData(compressionQuality: 0.5) else {return}
            
            let uploadTask = reviewImageListRef.putData(data, metadata: nil) { metadata, error in
                if let _ = error {
                    return
                }
                
                // 이때가 올라 갔다는 거니까
                // 여기서 뭘 알려주긴 해야하거든
                // 그럼 여기서 노티피케이션을 준다?
                group.leave()
            }
            
        }
        
        group.notify(queue: .main) {
            // 이미지가 다 올라 갔어 이때 뭘해줄래?
        }
        
    }
    
}



// MAKR: configure
extension ReviewViewModel {
    
    func configure_photoCell(cell: PhotoCell, indexPath: IndexPath) -> PhotoCell {
        
        let image = self.reviewImageList[indexPath.item].image
        cell.thumnailImageView.image = image
        cell.thumnailImageDeleteButton.tag = indexPath.item
        
        return cell
    }
    
}






extension ReviewViewModel {
    
    // MARK: reviewWriteTextView
    func reviewTextCountLimit(textView: UITextView, range: NSRange, text: String) -> Bool {
        guard let currentText = textView.text,
              let stringRange = Range(range, in: currentText) else {return false}
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        return currentText.count <= 10
    }
    
    // MARK: registrationButton
    func reviewRegistration() {
        guard let key = self.key else {return}
        
        self.updateRef_userReivewList(key: key)
        self.updateRef_storeReivewList(key: key)
        self.createStorage_reviewImageList(key: key)
    }
    
    
    
    
    func combine_finalUserReviewList() {
        
        if let userReviewList = self.userReviewList {
            
            for userReview in userReviewList {
                
                let result = userReviewImageList?.filter {$0.key == userReview.key}
                
                let review = userReview.value
                
                if result?.isEmpty ?? true {
                    self.setupModel_finalUserReviewList((review, nil))
                } else {
                    let imageList = result?.first?.value
                    
                    self.setupModel_finalUserReviewList((review, imageList))
                    print(self.finalUserReviewList)
                }
            }
            
        } else {
            print("리뷰가 없다.")
        }
        
        
    }
    
}
