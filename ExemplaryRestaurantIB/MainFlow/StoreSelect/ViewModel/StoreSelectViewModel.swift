//
//  StoreSelectViewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/19.
//

import Foundation
import Tabman
import Pageboy

class StoreSelectViewModel {
    
    // MARK: standard ViewModel
    private let shared = StandardViewModel.shared
    
    
    // MARK: Model
    private var model = StoreSelectModel()
    
    
    // MARK: Computed Property
    var businessTypeList: [String] {
        return self.model.businessTypeList
    }
    
    var currentBusinessType: String {
        return self.model.currentBusinessType
    }
    
    var nowGooType: (gooName: String, gooCode: String?) {
        return self.model.nowGooType
    }
    
    var viewControllers: [UIViewController] {
        return self.model.viewControllers
    }
    
    var storeList: [Store] {
        return self.model.storeList
    }
    
}

// MARK: model crud
extension StoreSelectViewModel {
    
    func createModel(businessTypeList: [String],
                     currentBusinessType: String,
                     nowGooType: (gooName: String, gooCode: String?)) {
        self.model.businessTypeList = businessTypeList
        self.model.currentBusinessType = currentBusinessType
        self.model.nowGooType = nowGooType
    }
    
    func createModel_viewControllers() {
        // 전체 store 가져오기
        let storeList = self.shared.storeList
        // 임시로 저장할 변수
        var viewControllers: [UIViewController] = []
        
        for businessType in businessTypeList {
            var storeList = storeList.filter { $0.businessType == businessType }
                
            if let gooCode = nowGooType.gooCode {
                storeList = storeList.filter { $0.gooCode == gooCode }
            }
            
            guard let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "StoreSelectViewController") as? StoreSelectViewController else {return}
            
            vc.vm.createModel_storeList(storeList: storeList)
            viewControllers.append(vc)
        }
        
        self.model.viewControllers = viewControllers
    }
    
    func createModel_storeList(storeList: [Store]) {
        self.model.storeList = storeList
    }

}

// MARK: StoreSelectContainerViewController
extension StoreSelectViewModel {
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?, vm: StoreSelectViewModel) {
        
        if segue.identifier == "Segue_StoreSelectTabViewController" {
            guard let vc = segue.destination as? StoreSelectTabViewController else {return}
            
            vc.vm.createModel(businessTypeList: vm.businessTypeList,
                              currentBusinessType: vm.currentBusinessType,
                              nowGooType: vm.nowGooType)
            vc.vm.createModel_viewControllers()
        }
    }
    
}

// MARK: Tabman, Pageboy
extension StoreSelectViewModel {
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        
        guard let index = businessTypeList.firstIndex(of: currentBusinessType) else {return nil}
    
        return .at(index: index)
    }
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let title = businessTypeList[index]
        
        return TMBarItem(title: title)
    }
    
}

// MARK: StoreSelectViewController.tableView
extension StoreSelectViewModel {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return storeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StoreSelectViewCell") as? StoreSelectViewCell else {return UITableViewCell()}
        
        let store = storeList[indexPath.row]
        let storeName = store.name
        let storeMainMenu = store.mainMenu

        cell.nameLabel.text = storeName
        cell.mainMenuLabel.text = storeMainMenu
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, completion: (StoreInfoViewController) -> ()) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "StoreInfoViewController") as? StoreInfoViewController else {return}
        
        let store = storeList[indexPath.row]
                
        vc.vm.createModel_store(store: store)
    
        completion(vc)
    }
    
}
