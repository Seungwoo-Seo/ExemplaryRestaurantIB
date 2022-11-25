//
//  SearchViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/22.
//
import UIKit

class SearchViewController: UIViewController {
    
    // MARK: View
    var resultsTableController: ResultTableViewController? // 검색 결과 보여줄 컨트롤러
    var searchController: UISearchController? // 검색 컨트롤로
    
    
    // MARK: ViewModel
    let viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(navigationController != nil)
        
        setupUI()
        setupLayout()
        
        viewModel.setupStoresPropertys()
    }
    
}

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let vc = searchController.searchResultsController as? ResultTableViewController else {return}
        
        guard let text = searchController.searchBar.text?.lowercased() else { return }
        
        let filteringStoresPropertys = viewModel.storesPropertys.filter { $0.0.lowercased().contains(text) }
        
        // 이걸 넘기면
        
        vc.viewModel.setupFilteringStoresPropertys(filteringStoresPropertys: filteringStoresPropertys)
        
        viewModel.setupFilteringStoresPropertys(filteringStoresPropertys: filteringStoresPropertys)
        
        vc.tableView.reloadData()
    }
    
}

private extension SearchViewController {
    
    func setupUI() {
        setupResultTableViewController()
        setupSearchController()
        
    }
    
    func setupLayout() {
        
    }
    
    // 하위 뷰
    func setupResultTableViewController() {
        resultsTableController = storyboard?.instantiateViewController(withIdentifier: "ResultTableViewController") as? ResultTableViewController
        resultsTableController?.tableView.delegate = self
    }
    
    // 서치 컨트롤러
    func setupSearchController() {
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController?.searchResultsUpdater = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    
    
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storePropertys = viewModel.filteringStoresPropertys[indexPath.row]
//        let store = viewModel.setupResultStore(storePropertys: storePropertys)
        
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "StoreViewController") as? StoreInfoViewController else {return}
        
//        vc.vm.createModel_store(store: store)
    
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
