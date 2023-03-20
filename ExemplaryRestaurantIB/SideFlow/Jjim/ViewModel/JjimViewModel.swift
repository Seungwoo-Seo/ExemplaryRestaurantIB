//
//  JjimViewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/26.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import PromiseKit

class JjimViewModel {
    
    // MARK: Model
    private var model = JjimModel()
    
    private var ref: DatabaseReference {
        return self.model.ref
    }
    
    private var handle: AuthStateDidChangeListenerHandle? {
        return self.model.handle
    }
        
}

extension JjimViewModel {
    
    enum JjimError: Error {
        case notLogin
    }
    
    func viewWillAppear(_ vc: JjimViewController, completionHandler: @escaping (UIAlertController?) -> ()) {
        firstly {
            self.addStateDidChangeListener()
        }.then { userUID in
            self.readFIR_UserJjimList(userUID)
        }.then { values in
            self.readFIR_StoreList(values)
        }.done { storeInfoList in
            self.createModel_containerList(storeInfoList)
            completionHandler(nil)

        }.catch { error in
            guard let error = error as? JjimError else {return}

            var alert: UIAlertController

            switch error {
            case .notLogin:
                alert = Alert.confirmAlert(title: "로그인 후 사용가능") {
                    vc.navigationController?.popViewController(animated: true)
                }
                completionHandler(alert)
            }
        }
    }
    
    // 1. 유저 uid 가져오기
    private func addStateDidChangeListener() -> Promise<String> {
        return Promise { seal in
            self.model.handle = Auth.auth().addStateDidChangeListener({ _, user in
                guard let user = user else {seal.reject(JjimError.notLogin); return}
                
                let userUID = user.uid
                seal.fulfill(userUID)
            })
        }
    }
    
//    // 2. 유저 찜 가져오기
//    private func getUserJjim(_ userUID: String) -> Promise<[UserJjim]?> {
//        return Promise { seal in
//            self.ref.child("UserJjimList").child(userUID).observeSingleEvent(of: .value, with: { snapshot in
//                guard let values = snapshot.value as? [String: Any] else {seal.fulfill(nil); return}
//
//                do {
//                    let jsonData = try JSONSerialization.data(withJSONObject: values)
//                    let userJjimDic = try JSONDecoder().decode([String: UserJjim].self, from: jsonData)
//                    let userJjimList = userJjimDic
//                        .map { $0.value }
//                        .sorted(by: { $0.timestamp > $1.timestamp })
//                    seal.fulfill(userJjimList)
//
//                } catch {
//
//                }
//            })
//        }
//    }
    
    
    // 2. uid 에 해당하는 찜 목록 가져오기 -> 일단 호출되면 유저는 무조건 있는 상태
    private func readFIR_UserJjimList(_ userUID: String) -> Promise<[String: UInt64]?> {
        return Promise { seal in
            self.ref.child("UserJjimList").child(userUID).observeSingleEvent(of: .value, with: { snapshot in
                guard let values = snapshot.value as? [String: UInt64] else {seal.fulfill(nil); return}

                seal.fulfill(values)
            })
        }
    }
    
    private func readFIR_StoreList(_ values: [String: UInt64]?) -> Promise<[(String, UInt64, [String: Double])]?> {
        return Promise { seal in
            guard let values = values else {seal.fulfill(nil); return}
            
            let group = DispatchGroup()
            var storeInfoList: [(String, UInt64, [String: Double])] = []
            
            for (storeUID, timestamp) in values {
                group.enter()
                self.ref.child("StoreList").child(storeUID).observeSingleEvent(of: .value, with: { snapshot in
                    guard let value = snapshot.value as? [String: Double] else {return}
                    
                    storeInfoList.append((storeUID, timestamp, value))
                    
                    group.leave()
                })
            }
            
            group.notify(queue: .main) {
                seal.fulfill(storeInfoList)
            }
        }
    }
    
    private func createModel_containerList(_ storeInfoList: [(String, UInt64, [String: Double])]?) {
        guard let storeInfoList = storeInfoList else {self.model.containerList = []; return}
        
        var containerList: [ContainerJjim] = []
        
        for (storeUID, timestamp, value) in storeInfoList {
            if let index = StandardViewModel.shared.storeList.firstIndex(where: { $0.uid == storeUID }) {
                let store = StandardViewModel.shared.storeList[index]
                let reviewAverage = value["reviewAverage"]!
                let reviewCount = value["reviewCount"]!
                
                containerList.append(ContainerJjim(store: store, timestamp: timestamp, reviewAverage: reviewAverage, reviewCount: reviewCount))
            }
        }
        
        self.model.containerList = containerList.sorted { $0.timestamp > $1.timestamp }
    }
    
    func removeStateDidChangeListener() {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
  
}

// MARK: tableView
extension JjimViewModel {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return model.containerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "JjimTableViewCell", for: indexPath) as? JjimTableViewCell else {return UITableViewCell()}
        let container = model.containerList[indexPath.row]
        
        cell.storeNameLabel.text = container.store.name
        cell.storeMainMenuLabel.text = container.store.mainMenu
        
        cell.storeReviewAverageLabel.text = "\(container.reviewAverage)"
        cell.storeReviewCountLabel.text = "(\(Int(container.reviewCount)))"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, completionHandler: (StoreInfoViewController) -> ()) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "StoreInfoViewController") as? StoreInfoViewController else {return}
        
        let store = model.containerList[indexPath.row].store
    
        vc.vm.createModel_store(store: store)
        
        completionHandler(vc)
    }
    
}
