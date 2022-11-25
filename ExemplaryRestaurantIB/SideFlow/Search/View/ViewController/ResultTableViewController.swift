//
//  ResultTableViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/10/02.
//

import UIKit

class ResultTableViewController: UITableViewController {

    let viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(navigationController != nil)
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.filteringStoresPropertys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = viewModel.filteringStoresPropertys[indexPath.row].0
        
        return cell
    }

}
