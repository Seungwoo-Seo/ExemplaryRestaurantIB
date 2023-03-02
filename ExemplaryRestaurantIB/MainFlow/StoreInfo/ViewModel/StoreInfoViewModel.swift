//
//  StoreInfoViewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/20.
//

import Foundation
import CoreLocation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class StoreInfoViewModel {
    
    // MARK: model
    private var model = StoreInfoModel()
    
    // MARK: computed property
    var store: Store? {
        return self.model.store
    }
    
    var mapPoint: MTMapPoint? {
        let latitude = self.model.coordinate?.latitude ?? 0.0
        let longitude = self.model.coordinate?.longitude ?? 0.0
        
        if latitude == 0.0 && longitude == 0.0 {
            return nil
        }
        
        let point = MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude, longitude: longitude))
        
        return point
    }
    
    private var handle: AuthStateDidChangeListenerHandle? {
        return self.model.handle
    }
    
    private var ref: DatabaseReference {
        return self.model.ref
    }
    
    private var storageRef: StorageReference {
        return self.model.storageRef
    }
    
    var userUID: String? {
        return self.model.userUID
    }
    
    
    var storeStarScore: Int {
        return self.model.storeStarScore
    }
    
    var storeAverage: Double {
        return self.model.storeAverage
    }
    
    var storeReviewCount: Int {
        return self.model.storeReviewCount
    }
    
    
    var jjimIsSelected: Bool {
        return self.model.jjimIsSelected
    }
    

    
    

    var storeUID: String? {
        return self.model.store?.uid
    }
    
    
    
    
    
    var finalStoreReviewList: [FinalStoreReview] {
        return self.model.finalStoreReviewList
    }
    
    
    
    
    
    var storeReviewList: [StoreReview] {
        return self.model.storeReviewList
    }
    
    var totalReviewImageList: [String: [UIImage?]] {
        return self.model.totalReviewImageList
    }
    
    var reviewImageList: [UIImage?] {
        return self.model.reviewImageList
    }
    
}
 

// MARK: model crud
extension StoreInfoViewModel {
    
    // MARK: model create
    func createModel_store(store: Store) {
        self.model.store = store
    }
    
    // 지번주소와 도로명 주소를 받아서 좌표를 리턴하는 메소드
    func createModel_coordinate(completionHandler: @escaping (Bool) -> ()) {
        guard let address = store?.address,
              let roadAddress = store?.roadAddress else {
            completionHandler(false)
            return
        }

        let geocode = CLGeocoder()

        // 먼저 지번주소를 지오코딩
        geocode.geocodeAddressString(address) { [weak self] placemarks, error in
            guard let self = self else {return}

            if let _ = error {
                // 지번주소가 에러가 나면 도로명 주소로 지오코딩
                geocode.geocodeAddressString(roadAddress) { placemarks, error in
                    if let _ = error {
                        completionHandler(false)
                        return
                    }

                    let coordinate = placemarks?.first?.location?.coordinate

                    self.model.coordinate = coordinate
                    completionHandler(true)
                }

            } else {
                let coordinate = placemarks?.first?.location?.coordinate

                self.model.coordinate = coordinate
                completionHandler(true)
            }
        }
        
    }
    
    func createModel_handle() {
        self.model.handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self,
                  let user = user else { return }
            
            let userUID = user.uid

            self.createModel_userUID(userUID: userUID)
        }
    }
    
    func createModel_userUID(userUID: String?) {
        self.model.userUID = userUID
    }
    
    func createModel_reviewInfo(userImage: UIImage?,
                           userName: String?,
                           starScore: Int?,
                           reviewImage: UIImage?,
                           reviewText: String?) {
        self.model.userImage = userImage
        self.model.userName = userName
        self.model.starScore = starScore
        self.model.reviewImage = reviewImage
        self.model.reviewText = reviewText
    }
    
    
    func createModel_storeReviewList(storeReviewList: [StoreReview]) {
        self.model.storeReviewList = storeReviewList
    }
    
    func createModel_totalReviewImageList(totalReviewImageList: [String: [UIImage?]]) {
        self.model.totalReviewImageList = totalReviewImageList
    }
    
    func createModel_reviewImageList(reviewImageList: [UIImage?]) {
        self.model.reviewImageList = reviewImageList
    }
    
    
    // MARK: model update
    func updateModel_jjimIsSelected(result: Bool) {
        self.model.jjimIsSelected = result
    }
    
    
    // MARK: model delete
    func deleteModel_handle() {
        Auth.auth().removeStateDidChangeListener(self.model.handle!)
    }
    
}

 
// MARK: ref crud
extension StoreInfoViewModel {
    
    // MARK: ref create
    func createRef_userJjim() {
        guard let userUID = self.userUID,
              let storeUID = self.userUID else {return}
        
        self.ref.child("UserJjimList").child("\(userUID)JjimList").child(storeUID).setValue(true)
        
        // 이 부분은 트랜젝션 처리 해야함
//        ref.child("Stores/\(identifier)/jjimCount").observe(.value, with: ({ [weak self] snapshot in
//            guard let self = self,
//                  let value = snapshot.value as? Int else {return}
//            self.value = value
//            print(self.value)
//        }))
//
//        ref.child("Stores/\(identifier)").updateChildValues(["jjimCount": self.value + 1])
    }
    
    // MARK: read
    func readRef_userJjim(completionHandler: @escaping (Bool) -> ()) {
        guard let storeUID = self.userUID,
              let userUID = self.userUID else {return}
        
        self.ref.child("UserJjimList").child("\(userUID)JjimList").queryOrderedByKey().queryEqual(toValue: storeUID).observe(.value) { snapshot in
            
            guard let _ = snapshot.value as? [String: Any] else {
                completionHandler(false)
                return
            }
            
            completionHandler(true)
        }
    }
    
    func readRef_storeReviewList(completionHandler: @escaping ([StoreReview]?) -> ()) {
        guard let storeUID = self.userUID else {return}
        
        self.ref.child("StoreReviewList").child("\(storeUID)ReviewList").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completionHandler(nil)
                return
            }
            
            do {
                let data = try JSONSerialization.data(withJSONObject: value)
                let result = try JSONDecoder().decode([String: StoreReview].self, from: data)
                
                let storeReviewList = Array(result.values)
        
                completionHandler(storeReviewList)
            } catch {
                print(error.localizedDescription)
            }
        })
    }
    
    
    // MARK: delete
    func deleteRef_userJjim() {
        guard let userUID = self.userUID,
              let storeUID = self.userUID else {return}
        
        self.ref.child("UserJjimList").child("\(userUID)JjimList").child("\(storeUID)").removeValue()
        // 여기도 마찬가지로 트랜젝션 처리
//        self.ref.child("Stores/\(identifier)").updateChildValues(["jjimCount": self.value - 1])
    }
    
}

// MARK: storage
extension StoreInfoViewModel {
    
    func readStorage_reviewImgaeList(storeReview: StoreReview, completionHandler: @escaping (FinalStoreReview?) -> ()) {
        
        let group = DispatchGroup()
        var finalStoreReview: FinalStoreReview?
        var imageList: [UIImage] = []
        
        
        if storeReview.reviewImageCount != 0 {
            // 전달 받은 리뷰에 사진이 있다면
            let path = self.storageRef.child("reviewImageList/\(storeReview.identifier)")
            
            group.enter()
            path.listAll { results, error in
                if let error = error {
                    print(error.localizedDescription)
                    // 일단 스토리지가 만들어지지 않은 리뷰이기 때문에
                    // 만들 수가 없는 리뷰임 아직은
                    completionHandler(nil)
                    return
                } else {
                    // 에러가 없으니까
                    // 최소한 패스가 잘못되진 않았다!
                    guard let results = results else {return}
                    
                    for item in results.items {
                        group.enter()
                        item.getData(maxSize: 1 * 1024 * 1024) { data, error in
                            if let error = error {
                                print(error.localizedDescription)
                                return
                            } else {
                                guard let data = data else {return}
                                let image = UIImage(data: data)
                                
                                imageList.append(image!)
                                group.leave()
                            }
                        }
                    } // for
                    group.leave()
                }
            } // listAll
            
            group.notify(queue: .main) {
                let userName = storeReview.userName
                let starScore = storeReview.starScore
                let reviewImageList = imageList
                let reviewText = storeReview.reviewText
                
                
                finalStoreReview = FinalStoreReview(userName: userName, starScore: starScore, reviewImageList: reviewImageList, reviewText: reviewText)
                
                completionHandler(finalStoreReview)
            }
        
            
        } else {
            // 전달 받은 리뷰에 사진이 없다면
            let userName = storeReview.userName
            let starScore = storeReview.starScore
            let reviewText = storeReview.reviewText
            
            
            finalStoreReview = FinalStoreReview(userName: userName, starScore: starScore, reviewImageList: [], reviewText: reviewText)
            
            // 그냥 사진 없으면
            // 사진 없는 최종 데이터 만들어서 리턴해
            completionHandler(finalStoreReview)
        }
        
        
    }
    
    
}

// MARK: tableView
extension StoreInfoViewModel {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return self.finalStoreReviewList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell", for: indexPath) as? MapCell else {return UITableViewCell()}
            
            if let mapPoint = mapPoint {
                cell.mapView.setMapCenter(mapPoint, animated: true)
            }
                        
            return cell
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "StoreInfoCell", for: indexPath) as? StoreInfoCell else {return UITableViewCell()}
            
            // storeNameLabel
            cell.storeNameLabel.text = store?.name
            
            // superStoreEvaluationStackView
            cell.superStoreEvaluationStackView.storeEvaluationStackView0
            cell.superStoreEvaluationStackView.storeEvaluationStackView1.storeScoreAverageLabel.text = String(storeAverage)
            cell.superStoreEvaluationStackView.storeEvaluationStackView1.storeReviewCountLabel.text = String(storeReviewCount)
            
            // buttonStackView
            
            // superStoreInfoStackView
            cell.superStoreInfoStackView.storeInfoStackView0.storeMainMenuLabel.text = store?.name
            cell.superStoreInfoStackView.storeInfoStackView1.storeSelectDayLabel.text = store?.assignationSelectedDay
            cell.superStoreInfoStackView.storeInfoStackView2.storeAddressLabel.text = store?.address
            cell.superStoreInfoStackView.storeInfoStackView3.storeRoadAddressLabel.text = store?.roadAddress
            
            return cell
            
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "StoreReviewCell", for: indexPath) as? StoreReviewCell else {return UITableViewCell()}
            
            
            configure_StoreReviewCell(cell: cell, indexPath: indexPath)
            
            return cell
            
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 400.0
        }
        
        return UITableView.automaticDimension
    }
    
}

// MARK: configure
extension StoreInfoViewModel {

    func updateModel_finalStoreReviewList(finalStoreReviewList: [FinalStoreReview]) {
        self.model.finalStoreReviewList = finalStoreReviewList
    }
    
    func createModel_FinalStoreReviewList(completionHandler: @escaping (Bool) -> ()) {
        // 해당 가게에 리뷰가 있는지 확인
        let group = DispatchGroup()
        var finalStoreReviewList: [FinalStoreReview] = []
        // 리뷰가 있는지 없는지만
        self.readRef_storeReviewList { [weak self] result in
            
            guard let self = self,
                  let storeReviewList = result else {
                // 리뷰 없음
                // 빈 최종리뷰배열을 업데이트
                self?.updateModel_finalStoreReviewList(finalStoreReviewList: finalStoreReviewList)
                completionHandler(false)
                return
            }
            
            // 리뷰 있음
            // 사진이 있는 리뷰도 잇을것이고
            // 사진이 없는 리뷰도 있을 것이란 말야
            for storeReview in storeReviewList {
                // 일단 리뷰는 있는데
                // 리뷰에
                // 사진이 있는지 없는지 검사좀
                group.enter()
                self.readStorage_reviewImgaeList(storeReview: storeReview) { finalStoreReview in
                    guard let finalStoreReview = finalStoreReview else {
                        // 여기에 걸리는건 사진은 있지만 스토리지에 올라오지 않은 리뷰
                        
                        group.leave()
                        return
                    }
    
                    
                    // 사진 없는 리뷰와 사진 있는 리뷰 모두 추가
                    finalStoreReviewList.append(finalStoreReview)
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.updateModel_finalStoreReviewList(finalStoreReviewList: finalStoreReviewList)
                completionHandler(true)
            }
        }
        
    }
    
    
    
    func configure_StoreReviewCell(cell: StoreReviewCell, indexPath: IndexPath) {
        
        guard !self.finalStoreReviewList.isEmpty else {return}
        
        let finalStoreReview = self.finalStoreReviewList[indexPath.row]
        
        print(finalStoreReview)
        
        // userName
        cell.userNameLabel.text = finalStoreReview.userName
        
        // starScore
        for index in 0...finalStoreReview.starScore {
            guard let imageView = cell.starScoreStackView.arrangedSubviews[index] as? UIImageView else {return}
            imageView.image = UIImage(systemName: "star.fill")
            imageView.tintColor = .yellow
        }
        
        // reviewImage
        if !finalStoreReview.reviewImageList.isEmpty {
            // 해당 리뷰에 사진 있음
            let reviewImageList = finalStoreReview.reviewImageList
            cell.vm.createModel_reviewImageList(reviewImageList: reviewImageList)
            cell.userReviewImageCollectionView.reloadData()
        } else {
            // 해당 리뷰에 사진없음
        }
        
        
        // reviewText
        cell.userReviewLabel.text = finalStoreReview.reviewText
        
        
    }
    
    func configure_ReviewImageCell(cell: ReviewImageCell, indexPath: IndexPath) {
        
        let reviewImage = self.reviewImageList[indexPath.item]
        
        print("--------")
        print(reviewImage)
        
        cell.reviewImageView.image = reviewImage
    }
    
}






