//
//  SearchViewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/10/02.
//

import Foundation

class SearchViewModel {
    
    // MARK: Model
    private var model = SearchModel()
    

    var storeList: [Store] {
        return self.model.storeList
    }
    
    var searchingStoreList: [Store] {
        return self.model.searchingStoreList
    }
    
}

// MARK: Life Cycle
extension SearchViewModel {
    
    func viewDidLoad() {
        self.model.storeList = NetworkManager.shared.storeList
    }

}

// searchResultsUpdating
extension SearchViewModel {
    
    func updateSearchResults(for searchController: UISearchController, completionHandler: (UITableViewController) -> ()) {
        guard let vc = searchController.searchResultsController as? UITableViewController,
              let text = searchController.searchBar.text?.lowercased() else {return}
        
        let searchingStoreList = storeList.filter { $0.name!.lowercased().contains(text) }
        
        self.model.searchingStoreList = searchingStoreList
        
        completionHandler(vc)
    }

    
}

// tableViewDelegate
extension SearchViewModel {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchingStoreList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = searchingStoreList[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, completionHandler: (StoreInfoViewController) -> ()) {
        
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StoreInfoViewController") as? StoreInfoViewController else {return}
        
        let store = searchingStoreList[indexPath.row]
        
        vc.vm.createModel_store(store: store)
        
        completionHandler(vc)
    }
    
}
