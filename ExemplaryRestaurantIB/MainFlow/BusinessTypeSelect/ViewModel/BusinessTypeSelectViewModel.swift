//
//  BusinessTypeSelectViewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/24.
//

import Foundation
import SnapKit

class BusinessTypeSelectViewModel {
    
    // MARK: Model
    private var model = BusinessTypeSeletModel()
    
    private var gooTypeList: [(gooName: String, gooCode: String?)] {
        return self.model.gooTypeList
    }
    
    private var nowGooType: (gooName: String, gooCode: String?) {
        return self.model.nowGooType
    }
    
    func setupNotification(_ collectionView: UICollectionView) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("fetchDataCompleted"), object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.createModel_businessTypeList()
                collectionView.reloadData()
            }
        }
    }
    
}

// MARK: action
extension BusinessTypeSelectViewModel {

    func didTapMyButton(_ sender: UIBarButtonItem, completionHandler: (MyViewController) -> ()) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyViewController") as? MyViewController else {return}
        
        completionHandler(vc)
    }
    
    func didTapGooSelectButton(_ sender: UIButton,
                               navigationItem: UINavigationItem,
                               view: UIView,
                               hazyView: HazyView,
                               gooSelectView: GooSelectView) {
        
        navigationItem.leftBarButtonItems?.forEach { $0.isEnabled = false }
        navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }
        
        gooSelectView.snp.remakeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.6)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            hazyView.alpha = 0.5
            view.layoutIfNeeded()
        })
        
    }
    
    func didTapNavigationBar(_ sender: UINavigationBar,
                             navigationItem: UINavigationItem,
                             view: UIView,
                             hazyView: HazyView,
                             gooSelectView: GooSelectView) {
        
        navigationItem.leftBarButtonItems?.forEach { $0.isEnabled = true }
        navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = true }
        
        gooSelectView.snp.remakeConstraints { make in
            make.height.equalTo(0)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            hazyView.alpha = 0.0
            view.layoutIfNeeded()
        })
    }
    
}

// MARK: searchBar
extension BusinessTypeSelectViewModel {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar, completionHandler: (SearchViewController) -> ()) {
        searchBar.endEditing(true)
        
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else {return}
        
        completionHandler(vc)
    }
}

// MARK: BottomSheetDelegate
extension BusinessTypeSelectViewModel {
    
    func didTapHazyView(_ tapGesture: UITapGestureRecognizer,
                        vc: BusinessTypeSelectViewController) {
        
        vc.navigationItem.leftBarButtonItems?.forEach { $0.isEnabled = true }
        vc.navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = true }

        
        vc.gooSelectView.snp.remakeConstraints { make in
            make.height.equalTo(0)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: { [weak vc] in
            vc?.hazyView.alpha = 0.0
        })
    }
    
    func didTapCancelButton(_ button: UIButton,
                            vc: BusinessTypeSelectViewController) {
        
        vc.navigationItem.leftBarButtonItems?.forEach { $0.isEnabled = true }
        vc.navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = true }
        
        vc.gooSelectView.snp.remakeConstraints { make in
            make.height.equalTo(0)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: { [weak vc] in
            vc?.hazyView.alpha = 0.0
        })
    }
    
    func didTapTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, vc: BusinessTypeSelectViewController) {
        let nowGooType = model.gooTypeList[indexPath.row]
        updateModel_nowGooType(nowGooType: nowGooType)
        
        vc.navigationItem.leftBarButtonItems?.forEach { $0.isEnabled = true }
        vc.navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = true }
        
        vc.gooSelectView.snp.remakeConstraints { make in
            make.height.equalTo(0)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: { [weak vc] in
            vc?.hazyView.alpha = 0.0
            vc?.view.layoutIfNeeded()
        }) { _ in
            DispatchQueue.main.async { [weak vc] in
                tableView.reloadData()
                vc?.collectionView.reloadData()
                vc?.headerView.gooSelectButton.setTitle(nowGooType.gooName, for: .normal)
            }
        }
    }
    
}

// MARK: collectionView
extension BusinessTypeSelectViewModel {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return model.businessTypeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessTypeCell", for: indexPath) as? BusinessTypeCell else {return UICollectionViewCell()}
        
        let businessType = model.businessTypeList[indexPath.item]
        let imageName = model.businessTypeImageList[businessType] ?? ""
        
        cell.businessTypeImageView.image = UIImage(named: imageName)
        cell.businessTypeLabel.text = businessType
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, completionHandler: (StoreSelectContainerViewController) -> ()) {
        
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StoreSelectContainerViewController") as? StoreSelectContainerViewController else {return}
        
        let businessTypeList = model.businessTypeList
        let currentBusinessType = businessTypeList[indexPath.item]
        let nowGooType = model.nowGooType
        
        vc.vm.createModel(businessTypeList: businessTypeList,
                          currentBusinessType: currentBusinessType,
                          nowGooType: nowGooType)
        
        completionHandler(vc)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemSpacing: CGFloat = 10
        let inset: CGFloat = 10
        let width: CGFloat = (collectionView.frame.width - inset*2 - itemSpacing*2) / 3
        let height: CGFloat = width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? BusinessTypeCell else {return}
                    
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 3, options: [.curveLinear], animations: { cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) })
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? BusinessTypeCell else {return}
                    
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 3, options: [.curveLinear], animations: { cell.transform = CGAffineTransform(scaleX: 1, y: 1) })
    }
    
}

// MARK: gooSelectView.tableView
extension BusinessTypeSelectViewModel {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gooTypeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GooTypeCell", for: indexPath) as? GooTypeCell else {return UITableViewCell()}
        
        cell.gooTypeLabel.text = gooTypeList[indexPath.row].gooName
        
        if cell.gooTypeLabel.text == model.nowGooType.gooName {
            cell.gooTypeLabel.textColor = .systemBlue
            let image = UIImage(systemName: "checkmark")
            let checkmark  = UIImageView(frame:CGRect(x:0, y:0, width:(image?.size.width)!, height:(image?.size.height)!));
            checkmark.image = image
            checkmark.tintColor = UIColor.systemBlue
            
            cell.accessoryView = checkmark
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nowGooType = model.gooTypeList[indexPath.row]
        updateModel_nowGooType(nowGooType: nowGooType)
    }
        
}

// MARK: model crud
private extension BusinessTypeSelectViewModel {
    
    // MARK: create
    func createModel_businessTypeList() {
        guard !StandardViewModel.shared.storeList.isEmpty else {return}
        
        let businessTypeList = StandardViewModel.shared.storeList.map { store in
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
            model.nowGooType = nowGooType
            return
        }
        
        // 지금 선택한게 은평구야
        // ("은평구", 3030490349)
        let storeList = StandardViewModel.shared.storeList.filter { store in
            store.gooCode == gooCode
        }
        
        updateModel_businessTypeList(storeList: storeList)
        model.nowGooType = nowGooType
    }
    
}
