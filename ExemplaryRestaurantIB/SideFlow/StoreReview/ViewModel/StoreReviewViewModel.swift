//
//  StoreReviewViewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2023/01/26.
//

import Foundation
import FirebaseDatabase
import SnapKit
import Kingfisher
import RxSwift

class StoreReviewViewModel {
    
    private var model = StoreReviewModel()
    
    private var ref: DatabaseReference {
        return self.model.ref
    }
    
}

extension StoreReviewViewModel {
    
    func createModel_store(_ store: Store) {
        self.model.store = store
    }
    
    func createModel_imageUrlList(_ reviewImageURL: [String]) {
        let imageUrlList = reviewImageURL.compactMap { URL(string: $0) }
        self.model.imageUrlList = imageUrlList
    }
    
    func deleteModel_imageUrlList() {
        self.model.imageUrlList = nil
    }
    
}

extension StoreReviewViewModel {
    
    func viewDidLoad(_ vc: StoreReviewViewController) {
        guard let storeUID = model.store?.uid,
              let storeName = model.store?.name else {return}
        
        vc.navigationItem.title = "\(storeName) 리뷰"
        vc.navigationController?.navigationBar.isHidden = true
        vc.lodingView.startLoding()
        getStoreReview(storeUID)
            .map { value -> [StoreReview] in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: value)
                    let storeReviewDic = try JSONDecoder().decode([String: StoreReview].self, from: jsonData)
                    
                    let storeReviewList = storeReviewDic
                        .map { $0.value }
                        .sorted(by: { $0.timeStamp > $1.timeStamp })
                    
                    return storeReviewList
                }
            }.subscribe(onNext: { [weak self] storeReviewList in
                self?.model.storeReviewList = storeReviewList
                
            }, onCompleted: {
                vc.storeReviewTableView.reloadData()
                vc.lodingView.stopLoding()
                vc.navigationController?.navigationBar.isHidden = false
            })
            .disposed(by: model.disposeBag)
    }
    
    private func getStoreReview(_ storeUID: String) -> Observable<[String: Any]> {
        return Observable<[String : Any]>.create { [weak self] observer in
            guard let self = self else {return Disposables.create()}
            
            self.ref.child("StoreReviewList").child(storeUID).observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [String: Any] else {observer.on(.completed); return}
                    
                observer.on(.next(value))
                observer.on(.completed)
            })
            
            return Disposables.create()
        }
    }
    
    func refresh(_ vc: StoreReviewViewController) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self,
                  let storeUID = self.model.store?.uid else {return}
            
            self.getStoreReview(storeUID)
                .map { value -> [StoreReview] in
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: value)
                        let storeReviewDic = try JSONDecoder().decode([String: StoreReview].self, from: jsonData)
                        
                        let storeReviewList = storeReviewDic
                            .map { $0.value }
                            .sorted(by: { $0.timeStamp > $1.timeStamp })
                        
                        return storeReviewList
                    }
                }.subscribe(onNext: { storeReviewList in
                    self.model.storeReviewList = storeReviewList
                    
                }, onCompleted: { [weak vc] in
                    guard let vc = vc else {return}
                    vc.storeReviewTableView.reloadData()
                    vc.storeReviewTableView.refreshControl?.endRefreshing()
                })
                .disposed(by: self.model.disposeBag)
        }
    }
        
}

// storeReviewTableView
extension StoreReviewViewModel {
    
    func prepareForReuse(_ cell: StoreReviewCell) {
        model.imageUrlList = nil
        cell.userNameLabel.text = nil
        cell.cosmosView.rating = 0.0
        cell.storeReviewImageCollectionView.snp.updateConstraints { make in
            make.height.equalTo(0)
        }
        cell.pageControl.numberOfPages = 0
        cell.storeReviewLabel.text = nil
        
        cell.storeReviewImageCollectionView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return model.storeReviewList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StoreReviewCell", for: indexPath) as? StoreReviewCell else {return UITableViewCell()}
        
        cell.selectionStyle = .none
        
        let storeReview = model.storeReviewList[indexPath.row]
        
        cell.userNameLabel.text = storeReview.userName
        cell.cosmosView.rating = Double(storeReview.starScore)
        if let reviewImageURL = storeReview.reviewImageURL {
            cell.pageControl.numberOfPages = reviewImageURL.count
            
            cell.vm.createModel_imageUrlList(reviewImageURL)
            cell.storeReviewImageCollectionView.snp.updateConstraints { make in
                make.height.equalTo(200)
            }
            cell.storeReviewImageCollectionView.reloadData()
        }
        cell.storeReviewLabel.text = storeReview.reviewText
        
        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>, pageControl: UIPageControl) {
        let page = Int(targetContentOffset.pointee.x / scrollView.frame.width)
        pageControl.currentPage = page
    }
    
}

// userReviewImageCollectionView
extension StoreReviewViewModel {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = model.imageUrlList?.count else {return 0}
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoreReviewImageCell", for: indexPath) as? StoreReviewImageCell,
              let imageUrl = model.imageUrlList?[indexPath.item] else {return UICollectionViewCell()}
        
        cell.imageView.kf.setImage(with: imageUrl, placeholder: UIImage(systemName: "heart"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
}
