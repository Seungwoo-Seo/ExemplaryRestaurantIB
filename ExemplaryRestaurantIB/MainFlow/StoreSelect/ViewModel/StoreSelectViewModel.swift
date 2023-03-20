//
//  StoreSelectViewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/19.
//

import Foundation
import Tabman
import Pageboy
import FirebaseDatabase
import PromiseKit

class StoreSelectViewModel {
    
    // MARK: Model
    private var model = StoreSelectModel()
    
    private var ref: DatabaseReference {
        return self.model.ref
    }
        
}

// MARK: StoreSelectContainerViewController
extension StoreSelectViewModel {
    
    enum StoreSelectViewModelError: Error {
        case decodingError
    }
    
    func prepare(_ segue: UIStoryboardSegue, sender: Any?, completionHandler: @escaping (UIAlertController?) -> ()) {
        if segue.identifier == "Segue_StoreSelectTabViewController" {
            guard let vc = segue.destination as? StoreSelectTabViewController else {return}
                       
            vc.vm.createModel(businessTypeList: model.businessTypeList,
                              currentBusinessType: model.currentBusinessType,
                              nowGooType: model.nowGooType)
            
            vc.lodingView.startLoding()
            
            firstly {
                self.readFIR_StoreList()
            }.then { decodeList in
                self.wrappingDecodeList(decodeList)
            }.then { containerList in
                self.filteringContainerList(containerList)
            }.done { viewControllers in
                vc.vm.model.viewControllers = viewControllers
                DispatchQueue.main.async {
                    vc.reloadData()
                    vc.lodingView.stopLoding()
                    
                }
            }.catch { error in
                guard let error = error as? StoreSelectViewModelError else {return}
                switch error {
                case .decodingError:
                    let alert = Alert.confirmAlert(title: "디코딩 실패")
                    
                    completionHandler(alert)
                }
            }
        }
    }
    
    private func readFIR_StoreList() -> Promise<[String: StoreRating]> {
        return Promise { seal in
            self.ref.child("StoreList").observe(.value, with: { snapshot in
                guard let value = snapshot.value as? [String: Any] else {return}
                
                do {
                    let data = try JSONSerialization.data(withJSONObject: value)
                    let decodeList = try JSONDecoder().decode([String: StoreRating].self, from: data)
                    
                    seal.fulfill(decodeList)
                } catch {
                    seal.reject(StoreSelectViewModelError.decodingError)
                }
            })
        }
    }
    
    private func wrappingDecodeList(_ decodeList: [String: StoreRating]) -> Promise<[ContainerStoreRating]> {
        return Promise { seal in
            let storeList = StandardViewModel.shared.storeList
            var containerList: [ContainerStoreRating] = []
            
            for decode in decodeList {
                if let index = storeList.firstIndex(where: {$0.uid == decode.key}) {
                    let container = ContainerStoreRating(store: storeList[index],
                                                         storeRating: decode.value)
                    
                    containerList.append(container)
                }
            }
            
            seal.fulfill(containerList)
        }
    }
    
    private func filteringContainerList(_ containerList: [ContainerStoreRating]) -> Promise<[UIViewController]> {
        return Promise { seal in
            let businessTypeList = self.model.businessTypeList
            let nowGooType = self.model.nowGooType
 
            var viewControllers: [UIViewController] = []
            
            for businessType in businessTypeList {
                var filteringList = containerList.filter { $0.store.businessType == businessType }
                
                if let gooCode = nowGooType.gooCode {
                    filteringList = filteringList.filter { $0.store.gooCode == gooCode }
                }
                
                guard let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "StoreSelectViewController") as? StoreSelectViewController else {return}
                
                vc.vm.model.containerList = filteringList
                viewControllers.append(vc)
            }
             
            seal.fulfill(viewControllers)
        }
    }
    
}

// MARK: UITabBarDelegate
extension StoreSelectViewModel {
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem, completionHandler: (UIViewController) -> ()) {
        guard let title = item.title else {return}
        
        switch title {
        case "검색":
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else {return}
            
            completionHandler(vc)
                
        case "찜":
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "JjimViewController") as? JjimViewController else {return}
        
            completionHandler(vc)
            
        case "리뷰내역":
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserReviewViewController") as? UserReviewViewController else {return}
            
            completionHandler(vc)
            
        case "My":
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyViewController") as? MyViewController else {return}
            
            completionHandler(vc)
            
        default:
            print(title)
        }
    }
    
}

// MARK: Tabman, Pageboy
extension StoreSelectViewModel {
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        
        return model.viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        
        return model.viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        
        guard let index = model.businessTypeList.firstIndex(of: model.currentBusinessType) else {return nil}
    
        return .at(index: index)
    }
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let title = model.businessTypeList[index]
        
        return TMBarItem(title: title)
    }
    
}

// MARK: StoreSelectViewController.tableView
extension StoreSelectViewModel {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return model.containerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StoreSelectViewCell") as? StoreSelectViewCell else {return UITableViewCell()}
        
        let store = model.containerList[indexPath.row].store
        let storeRating = model.containerList[indexPath.row].storeRating
        
        cell.nameLabel.text = store.name
        cell.averageLabel.text = "\(storeRating.reviewAverage)"
        cell.reviewCountLabel.text = "(\(storeRating.reviewCount))"
        cell.mainMenuLabel.text = store.mainMenu
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, completionHandler: (StoreInfoViewController) -> ()) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "StoreInfoViewController") as? StoreInfoViewController else {return}
        
        let store = model.containerList[indexPath.row].store
                
        vc.vm.createModel_store(store: store)
    
        completionHandler(vc)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: model crud
extension StoreSelectViewModel {
    
    func createModel(businessTypeList: [String], currentBusinessType: String, nowGooType: (gooName: String, gooCode: String?)) {
        self.model.businessTypeList = businessTypeList
        self.model.currentBusinessType = currentBusinessType
        self.model.nowGooType = nowGooType
    }

}
