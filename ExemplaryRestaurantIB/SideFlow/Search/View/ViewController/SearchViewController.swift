//
//  SearchViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/22.
//
import UIKit

class SearchViewController: UIViewController {
    
    // 검색 컨트롤러
    lazy var searchController: UISearchController = {
        let vc = UISearchController(searchResultsController: resultsTableController)
        
        return vc
    }()
    
    lazy var resultsTableController: UITableViewController = {
        let vc = UITableViewController(style: .plain)
        vc.tableView.delegate = self
        vc.tableView.dataSource = self
       
        return vc
    }()
    
    
    // MARK: ViewModel
    let vm = SearchViewModel()
    
    
    // MARK: Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
        
        vm.viewDidLoad()
    }
    
}

extension SearchViewController: UISearchResultsUpdating {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return false
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        vm.updateSearchResults(for: searchController) { vc in
            vc.tableView.reloadData()
        }
    }
    
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return vm.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return vm.tableView(tableView, cellForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        vm.tableView(tableView, didSelectRowAt: indexPath) { [weak self] vc in
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

private extension SearchViewController {
    
    func setupUI() {
        // navigation
        self.navigationItem.backButtonTitle = ""
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // searchController
        searchController.searchResultsUpdater = self
    }
    
    func setupLayout() {
        navigationItem.searchController = searchController
    }
    
}
