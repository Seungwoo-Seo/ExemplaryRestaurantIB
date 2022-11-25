//
//  BusinessTypeSelectViewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/24.
//

import Foundation
import SnapKit

class BusinessTypeSelectViewModel {
    
    // MARK: Standard ViewModel
    private let shared = StandardViewModel.shared
    
    
    // MARK: Model
    private var model = BusinessTypeSeletModel()
    
    
    private var businessTypeList: [String] {
        return self.model.businessTypeList
    }
    
    private var businessTypeImageList: [String: String] {
        return self.model.businessTypeImageList
    }
    
    private var gooTypeList: [(gooName: String, gooCode: String?)] {
        return self.model.gooTypeList
    }
    
    private var nowGooType: (gooName: String, gooCode: String?) {
        return self.model.nowGooType
    }
    
    
    
    init() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("fetchDataCompleted"), object: nil, queue: nil) { [weak self] notification in
            self?.createModel_businessTypeList()
            
            NotificationCenter.default.post(name: NSNotification.Name("completedReload"), object: nil)
        }
    }
    
}

// MARK: model crud
extension BusinessTypeSelectViewModel {
    
    // MARK: create
    func createModel_businessTypeList() {
        guard !shared.storeList.isEmpty else {return}
        
        let businessTypeList = shared.storeList.map { store in
            return store.businessType
        }
        
        var set = Set<String>()
        
        for businessType in businessTypeList {
            guard let businessType = businessType else {return}
            
            set.insert(businessType)
        }

        self.model.businessTypeList = Array(set)
    }
    
    // MARK: update
    func updateModel_businessTypeList(storeList: [Store]) {
        let businessTypeList = storeList.map { store in
            return store.businessType
        }
        
        var set = Set<String>()
        
        for businessType in businessTypeList {
            guard let businessType = businessType else {return}
            
            set.insert(businessType)
        }

        self.model.businessTypeList = Array(set)
    }
    
    func updateModel_nowGooType(nowGooType: (gooName: String, gooCode: String?)) {
        // 여기서 스토어도 바꿔줘야함
        // 예를 들어서
        guard let gooCode = nowGooType.gooCode else {
            createModel_businessTypeList()
            self.model.nowGooType = nowGooType
            return
        }
        
        // 지금 선택한게 은평구야
        // ("은평구", 3030490349)
        let storeList = shared.storeList.filter { store in
            store.gooCode == gooCode
        }
        
        updateModel_businessTypeList(storeList: storeList)
        
        self.model.nowGooType = nowGooType
    }
    
}


extension BusinessTypeSelectViewModel {
    
    func addObserver(_ collectionView: UICollectionView) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("completedReload"), object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                collectionView.reloadData()
            }
        }
    }
    
}


// MARK: collectionView configure
extension BusinessTypeSelectViewModel {
    
    func configure_collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return businessTypeList.count
    }
    
    func configure_collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessTypeCell", for: indexPath) as? BusinessTypeCell else {return UICollectionViewCell()}
        
        let businessType = businessTypeList[indexPath.item]
        let imageName = businessTypeImageList[businessType] ?? ""
        
        cell.businessTypeImageView.image = UIImage(named: imageName)
        cell.businessTypeLabel.text = businessType
        
        return cell
    }
    
    func configure_collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, completionHandler: (StoreSelectContainerViewController)->()) {
        
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StoreSelectContainerViewController") as? StoreSelectContainerViewController else {return}
        
        vc.vm.createModel(businessTypeList: self.businessTypeList,
                          currentBusinessType: businessTypeList[indexPath.item],
                          nowGooType: self.nowGooType)
        
        completionHandler(vc)
    }
    
    func configure_collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemSpacing: CGFloat = 10
        let inset: CGFloat = 10
        let width: CGFloat = (collectionView.frame.width - inset*2 - itemSpacing*2) / 3
        let height: CGFloat = width
        
        return CGSize(width: width, height: height)
    }
    
}

// MARK: tableView configure
extension BusinessTypeSelectViewModel {
    
    func configure_tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gooTypeList.count
    }
    
    func configure_tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, headerView: BusinessTypeSelectHeaderView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GooTypeCell", for: indexPath) as? GooTypeCell else {return UITableViewCell()}
        
        cell.gooTypeLabel.text = gooTypeList[indexPath.row].gooName
        
        if headerView.gooSelectButton.titleLabel?.text == cell.gooTypeLabel.text {
            cell.gooTypeLabel.textColor = .systemBlue
            let image = UIImage(systemName: "checkmark")
            let checkmark  = UIImageView(frame:CGRect(x:0, y:0, width:(image?.size.width)!, height:(image?.size.height)!));
            checkmark.image = image
            checkmark.tintColor = UIColor.systemBlue
            
            cell.accessoryView = checkmark
        }
        
        return cell
    }
    
    func configure_tableView(_ tableView: UITableView,
                             didSelectRowAt indexPath: IndexPath,
                             hideView: () -> (),
                             completion: (String) -> ()) {

        let nowGooType = gooTypeList[indexPath.row]
        self.updateModel_nowGooType(nowGooType: nowGooType)
        hideView()
        tableView.reloadData()
        completion(nowGooType.gooName)
    }
    
}
