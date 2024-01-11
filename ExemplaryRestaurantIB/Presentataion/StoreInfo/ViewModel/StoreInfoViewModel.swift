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
import PromiseKit
import SnapKit
import Kingfisher

class StoreInfoViewModel {
    
    // MARK: model
    private var model = StoreInfoModel()
    
    private var handle: AuthStateDidChangeListenerHandle? {
        return self.model.handle
    }
    
    private var ref: DatabaseReference {
        return self.model.ref
    }
    
    private var storageRef: StorageReference {
        return self.model.storageRef
    }
    
    var mapPoint: MTMapPoint? {
        let latitude = self.model.coordinate?.latitude ?? 0.0
        let longitude = self.model.coordinate?.longitude ?? 0.0
                
        let point = MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude, longitude: longitude))
        
        return point
    }
    
    func createModel_store(store: Store) {
        self.model.store = store
    }
        
}
 
// MARK: Life Cycle
extension StoreInfoViewModel {
    
    enum StoreInfoReadError: Error {
        case notStoreUID
        case decodeError
        case storeListReadErrror
        case reviewImageListReadError
    }
    
    func viewWillAppear(_ lodingView: LodingView,
                        navigationVC: UINavigationController?,
                        tableView: StoreInfoTableView,
                        completionHandler: @escaping (UIAlertController?) -> ()) {
        
        navigationVC?.isNavigationBarHidden = true
        lodingView.startLoding()
        
        let alert = Alert.confirmAlert(title: "가게 정보를 불러올 수 없습니다.") {
            navigationVC?.popViewController(animated: true)
        }
        
        guard let storeUID = model.store?.uid else {completionHandler(alert); return}
        
        firstly {
            when(fulfilled: self.addStateDidChangeListener(),           // 로그인 유무
                            self.readFIR_StoreList(storeUID))           // 가게 정보
            
        }.then { userUID, _ in
            self.readFIR_UserJjimList(userUID, storeUID)
            
        }.then { isJjim in
            self.isJjimCheck(isJjim)
            
        }.done { _ in
            DispatchQueue.main.async {
                navigationVC?.isNavigationBarHidden = false
                tableView.reloadData()
                lodingView.stopLoding()
                completionHandler(nil)
            }
            
        }.catch { error in
            guard let error = error as? StoreInfoReadError else {return}
            
            switch error {
            case .decodeError, .storeListReadErrror:
                completionHandler(alert)
                
            default:
                completionHandler(alert)
            }
        }
    }
    
    // 1-1. 유저 uid 확인
    private func addStateDidChangeListener() -> Promise<String?> {
        return Promise { seal in
            self.model.handle = Auth.auth().addStateDidChangeListener { _, user in
                guard let user = user else {seal.fulfill(nil); return}
                
                let userUID = user.uid
                
                self.model.userUID = userUID
                
                seal.fulfill(userUID)
            }
        }
    }
    
    // 1-2. 가게 별점 등 가져오기
    private func readFIR_StoreList(_ storeUID: String) -> Promise<Void> {
        return Promise { seal in
            self.ref.child("StoreList").child(storeUID).observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [String: Double] else {seal.reject(StoreInfoReadError.storeListReadErrror); return}
                
                let reviewAverage = value["reviewAverage"]!
                let reviewCount = Int(value["reviewCount"]!)
                let jjimCount = Int(value["jjimCount"]!)
                
                self.model.reviewCount = reviewCount
                self.model.reviewAverage = reviewAverage
                self.model.jjimcount = jjimCount
                
                seal.fulfill(Void())
            })
        }
    }
    


    
    // 2-1. 찜 확인
    private func readFIR_UserJjimList(_ userUID: String?, _ storeUID: String) -> Promise<Bool?> {
        return Promise { seal in
            guard let userUID = userUID else {seal.fulfill(nil); return}
            
            self.ref.child("UserJjimList").child(userUID).child(storeUID).observeSingleEvent(of: .value, with: { snapshot in
                guard let _ = snapshot.value as? Int else {seal.fulfill(false); return}
                seal.fulfill(true)
            })
        }
    }
    
    
    
    // 3-1
    private func isJjimCheck(_ isJjim: Bool?) -> Promise<Void> {
        return Promise { seal in
            guard let isJjim = isJjim else {
                self.model.isJjim = false
                seal.fulfill(Void())
                return
            }
            
            self.model.isJjim = isJjim
            seal.fulfill(Void())
        }
    }
    
    
    func removeStateDidChangeListener() {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
}

// MARK: actions
extension StoreInfoViewModel {
    
    func didTapReviewWriteButton(_ sender: UIButton, completionHandler: @escaping (ReviewWriteViewController?, UIAlertController?) -> ()) {
        if let _ = self.model.userUID {
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReviewWriteViewController") as? ReviewWriteViewController else {return}
        
            vc.vm.createModel(storeName: self.model.store?.name,
                              storeUID: self.model.store?.uid)

            completionHandler(vc, nil)
        } else {
            let alert = Alert.confirmAlert(title: "로그인 후 사용할 수 있습니다.")
            completionHandler(nil, alert)
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
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, delegate: StoreInfoViewController) -> UITableViewCell {
    
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell", for: indexPath) as? MapCell else {return UITableViewCell()}
            
            if cell.delegate == nil {
                cell.delegate = delegate
                cell.setupUI_mapView()
            }
            
            return cell
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "StoreInfoCell", for: indexPath) as? StoreInfoCell else {return UITableViewCell()}
            
            let store = model.store
            
            // 가게 이름 할당
            cell.storeNameLabel.text = store?.name
            
            // 가게 별점 할당
            cell.cosmosView.rating = model.reviewAverage
            cell.cosmosView.text = "\(model.reviewAverage)"
            cell.reviewCountLabel.text = "(\(model.reviewCount))"

            if cell.delegate == nil {
                cell.delegate = delegate
            }
            
            // 찜 버튼
            cell.jjimButton.isSelected = model.isJjim
//            cell.jjimButton.setTitle("\(model.jjimcount)", for: .normal)
            
            // 가게 정보 할당
            cell.superStoreInfoStackView.storeInfoStackView0.storeMainMenuLabel.text = store?.name
            
            if var selectDay = store?.assignationSelectedDay {
                let index1 = selectDay.index(selectDay.startIndex, offsetBy: 4)
                let index2 = selectDay.index(selectDay.startIndex, offsetBy: 7)

                selectDay.insert("-", at: index1)
                selectDay.insert("-", at: index2)
                
                cell.superStoreInfoStackView.storeInfoStackView1.storeSelectDayLabel.text = selectDay
            } else {
                cell.superStoreInfoStackView.storeInfoStackView1.storeSelectDayLabel.text = "없음"
            }
            
            
            cell.superStoreInfoStackView.storeInfoStackView2.storeAddressLabel.text = store?.address
            cell.superStoreInfoStackView.storeInfoStackView3.storeRoadAddressLabel.text = store?.roadAddress
            
            return cell
            
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "StoreContentCell", for: indexPath) as? StoreContentCell else {return UITableViewCell()}
            
            if cell.delegate == nil {
                cell.delegate = delegate
            }
            
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


// MARK: MapCellDelegate, StoreInfoCellDelegate, StoreReviewCellDelegate
extension StoreInfoViewModel {
    
    func setupUI_mapView(_ mapView: MTMapView, completionHandler: @escaping (UIAlertController?) -> ()) {
        let alert = Alert.confirmAlert(title: "해당 주소로 지도에 표시할 수 없습니다.")
        
        guard let address = model.store?.address,
              let roadAddress = model.store?.roadAddress else {
            mapView.setMapCenter(self.mapPoint, animated: true)
            completionHandler(alert)
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
                        mapView.setMapCenter(self.mapPoint, animated: true)
                        completionHandler(alert)
                        return
                    }

                    let coordinate = placemarks?.first?.location?.coordinate

                    self.model.coordinate = coordinate
                    mapView.setMapCenter(self.mapPoint, animated: true)
                    
                    let poi = MTMapPOIItem()
                    poi.mapPoint = self.mapPoint
                    poi.markerType = .bluePin
                    mapView.addPOIItems([poi])
                    
                    completionHandler(nil)
                }
            } else {
                let coordinate = placemarks?.first?.location?.coordinate

                self.model.coordinate = coordinate
                mapView.setMapCenter(self.mapPoint, animated: true)
                
                let poi = MTMapPOIItem()
                poi.mapPoint = self.mapPoint
                poi.markerType = .bluePin
                mapView.addPOIItems([poi])
                
                completionHandler(nil)
            }
        }
    }
        
    func setupUI_callButton(_ sender: UIButton, completionHandler: (UIAlertController) -> ()) {
        var alert = Alert.confirmAlert(title: "번호 없음")
        
        guard let phoneNumber = model.store?.phoneNumber else {
            completionHandler(alert)
            return
        }
        
        if phoneNumber.isEmpty {
            completionHandler(alert)
            return
        }
        
        var number = phoneNumber.components(separatedBy: [" "]).joined()
        
        let regex1 = "^02([0-9]{3})([0-9]{4})$"
        let regex2 = "^02([0-9]{4})([0-9]{4})$"
        let regex3 = "^01([0-9])([0-9]{3,4})([0-9]{4})$"
            
        var index1: String.Index
        var index2: String.Index
        
        if NSPredicate(format: "SELF MATCHES %@", regex1).evaluate(with: number) {
            index1 = number.index(number.startIndex, offsetBy: 2)
            index2 = number.index(number.startIndex, offsetBy: 6)
            number.insert("-", at: index1)
            number.insert("-", at: index2)
            
        } else if NSPredicate(format: "SELF MATCHES %@", regex2).evaluate(with: number) {
            index1 = number.index(number.startIndex, offsetBy: 2)
            index2 = number.index(number.startIndex, offsetBy: 7)
            number.insert("-", at: index1)
            number.insert("-", at: index2)
            
        } else if NSPredicate(format: "SELF MATCHES %@", regex3).evaluate(with: number) {
            index1 = number.index(number.startIndex, offsetBy: 3)
            index2 = number.index(number.startIndex, offsetBy: 8)
            number.insert("-", at: index1)
            number.insert("-", at: index2)
        }
                
        alert = Alert.confirmAlert(title: number)
        completionHandler(alert)
    }
    
    func setupUI_jjimButton(_ sender: UIButton, completionHandler: (UIAlertController) -> ()) {
        if let userUID = model.userUID, let storeUID = model.store?.uid {
            if sender.isSelected {
                firstly {
                    when(fulfilled: self.deleteFIR_UserJjimList(userUID, storeUID),
                                    self.deleteFIR_UserList(userUID),
                                    self.deleteFIR_StoreList(storeUID))
                }.done { _, _, _ in
                    sender.isSelected = !sender.isSelected
                }.catch { error in
                    
                }
            } else {
                firstly {
                    when(fulfilled: self.createFIR_UserJjimList(userUID, storeUID),
                                    self.updateFIR_UserList(userUID),
                                    self.updateFIR_StoreList(storeUID))
                }.done { _, _, _ in
                    sender.isSelected = !sender.isSelected
                }.catch { error in
                    
                }
            }
        } else {
            let alert = Alert.confirmAlert(title: "로그인 후 사용할 수 있습니다.")
            completionHandler(alert)
        }
    }
    
    enum StoreInfoJjimError: Error {
        
    }
    
    // 찜 했을때
    private func createFIR_UserJjimList(_ userUID: String, _ storeUID: String) -> Promise<Void> {
        return Promise { seal in
            self.ref.child("UserJjimList").child(userUID).child(storeUID).setValue(Int(Date().timeIntervalSince1970)) { error, _  in
                if let _ = error {
                    
                } else {
                    seal.fulfill(Void())
                }
            }
        }
    }
    
    private func updateFIR_UserList(_ userUID: String) -> Promise<Void> {
        return Promise { seal in
            let updates = ["jjimCount": ServerValue.increment(1)]
            
            self.ref.child("UserList").child(userUID).updateChildValues(updates) { error, _  in
                if let _ = error {
                    
                } else {
                    seal.fulfill(Void())
                }
            }
        }
    }
    
    private func updateFIR_StoreList(_ storeUID: String) -> Promise<Void> {
        return Promise { seal in
            self.ref.child("StoreList").child(storeUID).runTransactionBlock({ currentData in
                if var post = currentData.value as? [String: AnyObject] {
                    var jjimCount = post["jjimCount"] as! Int
                    jjimCount += 1
                    
                    post["jjimCount"] = jjimCount as AnyObject
                    
                    currentData.value = post
                    
                    return TransactionResult.success(withValue: currentData)
                }
                
                return TransactionResult.success(withValue: currentData)
            }) { error, _, snapshot in
                if let _ = error {
                    
                } else {
                    seal.fulfill(Void())
                }
            }
        }
    }
    
    // 찜 취소 했을 때
    private func deleteFIR_UserJjimList(_ userUID: String, _ storeUID: String) -> Promise<Void> {
        return Promise { seal in
            self.ref.child("UserJjimList").child(userUID).child(storeUID).removeValue { error, _ in
                if let _ = error {
                    
                } else {
                    seal.fulfill(Void())
                }
            }
        }
    }
    
    private func deleteFIR_UserList(_ userUID: String) -> Promise<Void> {
        return Promise { seal in
            let updates = ["jjimCount": ServerValue.increment(-1)]
            
            self.ref.child("UserList").child(userUID).updateChildValues(updates) { error, _  in
                if let _ = error {
                    
                } else {
                    seal.fulfill(Void())
                }
            }
        }
    }
    
    private func deleteFIR_StoreList(_ storeUID: String) -> Promise<Void> {
        return Promise { seal in
            self.ref.child("StoreList").child(storeUID).runTransactionBlock({ currentData in
                if var post = currentData.value as? [String: AnyObject] {
                    var jjimCount = post["jjimCount"] as! Int
                    jjimCount -= 1
                    
                    post["jjimCount"] = jjimCount as AnyObject
                    
                    currentData.value = post
                    
                    return TransactionResult.success(withValue: currentData)
                }
                
                return TransactionResult.success(withValue: currentData)
            }) { error, _, snapshot in
                if let _ = error {
                    
                } else {
                    seal.fulfill(Void())
                }
            }
        }
    }

    func setupUI_shareButton(_ sender: UIButton,
                             view: UIView,
                             completionHandler: (UIActivityViewController) -> ()) {
        let activityViewController = UIActivityViewController(activityItems : ["공유하기"], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        
        completionHandler(activityViewController)
    }
    
    func didTapShowStoreReviewButton(_ sender: UIButton, completionHandler: (StoreReviewViewController) -> ()) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StoreReviewViewController") as? StoreReviewViewController,
              let store = model.store else {return}
        
        vc.vm.createModel_store(store)
        completionHandler(vc)
    }
    
}

extension StoreInfoViewModel {
    
    func touchesShouldCancel(in view: UIView, superTouchesShouldCancel: Bool) -> Bool {
        
        if view.tag == 20090806 {
            return false
        } else if view is UIButton {
            return true
        }
        
        return superTouchesShouldCancel
    }
    
}
