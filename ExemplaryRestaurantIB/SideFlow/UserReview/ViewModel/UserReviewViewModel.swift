//
//  UserReviewViewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/29.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import PromiseKit
import SnapKit
import Kingfisher

class UserReviewViewModel {
    
    private var model = UserReviewModel()
    
    private var handle: AuthStateDidChangeListenerHandle? {
        return self.model.handle
    }
    
    private var ref: DatabaseReference {
        return self.model.ref
    }
    
    private var storage: Storage {
        return self.model.storage
    }
        
}

// MARK: Life Cycles
extension UserReviewViewModel {
    
    func viewWillAppear(_ vc: UserReviewViewController, completionHandler: @escaping (UIAlertController) -> ()) {
        firstly {
            self.addStateDidChangeListener()
            
        }.then { [unowned self] userUID in
            self.getUserReview(userUID)
            
        }.then{ [unowned self] userReviewList in
            self.createContainerList(userReviewList)
            
        }.done { containerList in
            if containerList == nil {
                let alert = Alert.confirmAlert(title: "리뷰가 없습니다.")
                completionHandler(alert)
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                
                self.model.containerList = containerList
                vc.userReviewTableView.reloadData()
            }
            
        }.catch { error in
            guard let error = error as? UserReviewError else {return}
            
            var alert = Alert.confirmAlert(title: "리뷰를 불러오지 못했습니다.") { [weak vc] in
                vc?.navigationController?.popViewController(animated: true)
            }
            
            switch error {
            case .notLogin:
                alert = Alert.confirmAlert(title: "로그인 후 사용가능") { [weak vc] in
                    vc?.navigationController?.popViewController(animated: true)
                }
                completionHandler(alert)
                
            default:
                completionHandler(alert)
            }
        }
    }
    
    // viewWillDisappear
    func viewWillDisappear() {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
        
}

// userReviewTableView
extension UserReviewViewModel {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = model.containerList?.count else {return 0}
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, delegate: UserReviewViewController) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserReviewCell", for: indexPath) as? UserReviewCell,
              let containerList = model.containerList else {return UITableViewCell()}
        
        cell.selectionStyle = .none
        
        let container = containerList[indexPath.row]
        
        if cell.delegate == nil {
            cell.delegate = delegate
        }
        
        cell.vm.model.container = container
        
        // 스토어 이름
        cell.storeNameButton.setTitle("\(container.userReview.storeName) >", for: .normal)
        
        // 리뷰 별점
        cell.cosmosView.rating = Double(container.userReview.starScore)
        
        // 스토어 이미지
        if let reviewImageURL = container.userReview.reviewImageURL {
            cell.pageControl.numberOfPages = reviewImageURL.count
            
            cell.userReviewImageCollectionView.snp.updateConstraints { make in
                make.height.equalTo(200)
            }
            cell.userReviewTextLabel.snp.updateConstraints { make in
                make.top.equalTo(cell.userReviewImageCollectionView.snp.bottom).offset(10)
            }
            
            cell.userReviewImageCollectionView.reloadData()
        }
        
        // 리뷰
        cell.userReviewTextLabel.text = container.userReview.reviewText
        
        return cell
    }
    
}

// userReviewCell
extension UserReviewViewModel {
    
    func prepareForReuse(_ cell: UserReviewCell) {
        model.container = nil
        cell.storeNameButton.setTitle(nil, for: .normal)
        cell.cosmosView.rating = 0.0
        cell.userReviewImageCollectionView.snp.updateConstraints { make in
            make.height.equalTo(0)
        }
        cell.userReviewTextLabel.snp.updateConstraints { make in
            make.top.equalTo(cell.userReviewImageCollectionView.snp.bottom)
        }
        
        cell.pageControl.numberOfPages = 0
        cell.userReviewTextLabel.text = nil
        
        cell.userReviewImageCollectionView.reloadData()
    }
    
    func didTapStoreNameButton(_ sender: UIButton, cell: UserReviewCell, completionHandler: (StoreInfoViewController) -> ()) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StoreInfoViewController") as? StoreInfoViewController,
              let container = cell.vm.model.container else {return}
        
        let store = container.store
        vc.vm.createModel_store(store: store)
        
        completionHandler(vc)
    }
    
    func didTapUserReviewDeleteButton(_ sender: UIButton, cell: UserReviewCell, tableView: UITableView, completionHandler: (UIAlertController) -> ()) {
        
        let alert = UIAlertController(title: "해당 리뷰를 삭제하시겠습니까?", message: "삭제 시 복구가 불가능 합니다.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let confirm = UIAlertAction(title: "확인", style: .default) { _ in
            firstly {
                self.addStateDidChangeListener()
            }
            .then { [unowned self] userUID in
                when(fulfilled: self.deleteReviewImageList(userUID, cell: cell),
                                self.deleteUserReview(userUID, cell: cell),
                                self.deleteStoreReview(userUID, cell: cell),
                                self.updateUserInfo(userUID),
                                self.updateStoreInfo(userUID, cell: cell))
            }
            .done { _, _, _, _, _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self,
                          let indexPath = tableView.indexPathForRow(at: sender.convert(CGPoint.zero, to: tableView)) else {return}
                    
                    self.model.containerList?.remove(at: indexPath.row)
                    
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
                    tableView.endUpdates()
                }
            }
            .catch { error in
                guard let error = error as? UserReviewError else {return}
                
                switch error {
                case .notLogin:
                    print("notLogin")
                case .notReview:
                    print("notReview")
                case .cantDecoding:
                    print("cantDecoding")
                case .cantReviewImagesDelete:
                    print("cantReviewImagesDelete")
                case .cantUserReviewDelete:
                    print("cantUserReviewDelete")
                case .cantStoreReviewDelete:
                    print("cantStoreReviewDelete")
                case .cantUserInfoUpdate:
                    print("cantUserInfoUpdate")
                case .cantStoreInfoUpdate:
                    print("cantStoreInfoUpdate")
                }
            }
        }
        
        [cancel, confirm].forEach { alert.addAction($0) }
        
        completionHandler(alert)
    }
    
}

// userReviewImageCollectionView
extension UserReviewViewModel {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let count = model.container?.userReview.reviewImageURL?.count else {return 0}
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserReviewImageCell", for: indexPath) as? UserReviewImageCell,
              let reviewImageURL = model.container?.userReview.reviewImageURL else {return UICollectionViewCell()}
        
        let imageUrlList = reviewImageURL.compactMap { URL(string: $0) }
        let imageUrl = imageUrlList[indexPath.item]
        
        cell.reviewImageView.kf.setImage(with: imageUrl, placeholder: UIImage(systemName: "heart"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>, pageControl: UIPageControl) {
        
        let page = Int(targetContentOffset.pointee.x / scrollView.frame.width)
        pageControl.currentPage = page
    }
}


// private
private extension UserReviewViewModel {
    
    enum UserReviewError: Error {
        case notLogin                   // 로그인 안함
        case notReview                  // 리뷰 없음
        
        case cantDecoding
        
        case cantUserReviewDelete
        case cantStoreReviewDelete
        case cantReviewImagesDelete
        case cantUserInfoUpdate
        case cantStoreInfoUpdate
    }
    
    private func addStateDidChangeListener() -> Promise<String?> {
        return Promise { [weak self] seal in
            guard let self = self else {return}
            
            self.model.handle = Auth.auth().addStateDidChangeListener { _, user in
                guard let user = user else {seal.reject(UserReviewError.notLogin); return}
                
                let userUID = user.uid
                
                seal.fulfill(userUID)
            }
        }
    }
    
    // 2. 유저 리뷰 목록 가져오기
    private func getUserReview(_ userUID: String?) -> Promise<[UserReview]?> {
        return Promise { [weak self] seal in
            guard let self = self,
                  let userUID = userUID else {seal.fulfill(nil); return}
            
            self.ref.child("UserReviewList").child(userUID).observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [String: Any] else {seal.fulfill(nil); return}

                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: value)
                    let userReviewDic = try JSONDecoder().decode([String: UserReview].self, from: jsonData)
                    let userReviewList = userReviewDic
                        .map { $0.value }
                        .sorted(by: { $0.timeStamp > $1.timeStamp })

                    seal.fulfill(userReviewList)

                } catch {
                    seal.reject(UserReviewError.cantDecoding)
                }
            })
        }
    }
    
    // 3. 셀에서 사용할 데이터 만들기
    private func createContainerList(_ userReviewList: [UserReview]?) -> Promise<[ContainerUserReview]?> {
        return Promise { seal in
            guard let userReviewList = userReviewList else {seal.fulfill(nil); return}
            
            let containerList = userReviewList.map { userReview in
                let index = StandardViewModel.shared.storeList.firstIndex(where: {$0.uid == userReview.storeUID})!
                let store = StandardViewModel.shared.storeList[index]
                
                return ContainerUserReview(store: store, userReview: userReview)
            }
            
            seal.fulfill(containerList)
        }
    }
    
    
    
    private func deleteReviewImageList(_ userUID: String?, cell: UserReviewCell) -> Promise<Void> {
        return Promise { seal in
            guard let userUID = userUID else {seal.reject(UserReviewError.notLogin); return}
            guard let reviewImageUrlList = cell.vm.model.container?.userReview.reviewImageURL else {seal.fulfill(Void()); return}
            
            let group = DispatchGroup()
            
            for reviewImageUrl in reviewImageUrlList {
                group.enter()
                self.storage.reference(forURL: reviewImageUrl).delete { error in
                    guard error == nil else {return}
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                seal.fulfill(Void())
            }
        }
    }
    
    private func deleteUserReview(_ userUID: String?, cell: UserReviewCell) -> Promise<Void> {
        return Promise { seal in
            guard let userUID = userUID else {seal.reject(UserReviewError.notLogin); return}
            guard let userReview = cell.vm.model.container?.userReview else {seal.reject(UserReviewError.notReview); return}
            
            let identifier = userReview.identifier
            
            self.ref.child("UserReviewList").child(userUID).child(identifier).removeValue() { error, _  in
                guard error == nil else {seal.reject(UserReviewError.cantUserReviewDelete); return}
                
                seal.fulfill(Void())
            }
        }
    }
    
    private func deleteStoreReview(_ userUID: String?, cell: UserReviewCell) -> Promise<Void> {
        return Promise { seal in
            guard let userUID = userUID else {seal.reject(UserReviewError.notLogin); return}
            guard let userReview = cell.vm.model.container?.userReview else {seal.reject(UserReviewError.notReview); return}
            
            let storeUID = userReview.storeUID
            let identifier = userReview.identifier
            
            self.ref.child("StoreReviewList").child(storeUID).child(identifier).removeValue() { error, _ in
                guard error == nil else {seal.reject(UserReviewError.cantStoreReviewDelete); return}
                
                seal.fulfill(Void())
            }
        }
    }
    
    private func updateUserInfo(_ userUID: String?) -> Promise<Void> {
        return Promise { seal in
            guard let userUID = userUID else {seal.reject(UserReviewError.notLogin); return}
            
            let updates = ["reviewCount": ServerValue.increment(-1)]
            
            self.ref.child("UserList").child(userUID).updateChildValues(updates) { error, _ in
                guard error == nil else {seal.reject(UserReviewError.cantUserInfoUpdate); return}
                
                seal.fulfill(Void())
            }
        }
    }

    
    private func updateStoreInfo(_ userUID: String?, cell: UserReviewCell) -> Promise<Void> {
        return Promise { seal in
            guard let userUID = userUID else {seal.reject(UserReviewError.notLogin); return}
            guard let userReview = cell.vm.model.container?.userReview else {seal.reject(UserReviewError.notReview); return}
            
            let storeUID = userReview.storeUID
            let starScore = userReview.starScore
            
            self.ref.child("StoreList").child(storeUID).runTransactionBlock({ currentData in
                if var post = currentData.value as? [String: AnyObject] {
                    var reviewCount = post["reviewCount"] as! Int
                    var reviewTotal = post["reviewTotal"] as! Int
                    var reviewAverage = post["reviewAverage"] as! Double

                    reviewCount -= 1
                    reviewTotal -= starScore

                    if reviewCount == 0 && reviewTotal == 0 {
                        reviewAverage = 0.0
                    } else {
                        reviewAverage = Double(String(format: "%.1f", Double(reviewTotal) / Double(reviewCount)))!
                    }

                    post["reviewCount"] = reviewCount as AnyObject
                    post["reviewTotal"] = reviewTotal as AnyObject
                    post["reviewAverage"] = reviewAverage as AnyObject

                    currentData.value = post

                    return TransactionResult.success(withValue: currentData)
                }
                return TransactionResult.success(withValue: currentData)
            }) { error, _, _ in
                guard error == nil else {seal.reject(UserReviewError.cantStoreReviewDelete); return}
                
                seal.fulfill(Void())
            }
        }
    }
}
