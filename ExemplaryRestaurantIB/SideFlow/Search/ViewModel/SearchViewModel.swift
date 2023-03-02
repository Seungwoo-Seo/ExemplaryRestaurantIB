//
//  SearchViewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/10/02.
//

import Foundation

class SearchViewModel {
    
    private var model = SearchModel()
    
    private let shared = StandardViewModel.shared
    
    
    
    var storesPropertys: [(String, String, String)] {
        return model.storesPropertys
    }
    
    var filteringStoresPropertys: [(String, String, String)] {
        return model.filteringStoresPropertys
    }
    
    
    
    func setupStoresPropertys() {
//        model.storesPropertys = shared.pulloutSearchUseStoresPropertys()
    }
    
    
    func setupFilteringStoresPropertys(filteringStoresPropertys: [(String, String, String)]) {
        model.filteringStoresPropertys = filteringStoresPropertys
    }
    
//    func setupResultStore(storePropertys: (String, String, String)) -> Store {
////        let store = shared.pulloutResultStore(storePropertys)
//        return store
//    }
//
    
}
