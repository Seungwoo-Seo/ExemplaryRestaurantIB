//
//  StoreSelectViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/08/14.
//

import UIKit
import SnapKit

class StoreSelectViewController: UIViewController {

    // MARK: @IBOutlet
    @IBOutlet weak var storeTableView: UITableView!
    
    
    // MARK: ViewModel
    let vm = StoreSelectViewModel()
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
}

extension StoreSelectViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return vm.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return vm.tableView(tableView, cellForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        vm.tableView(tableView, didSelectRowAt: indexPath) { vc in
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

private extension StoreSelectViewController {
    
    func setupUI() {
        self.storeTableView.register(UINib(nibName: "StoreSelectViewCell", bundle: nil), forCellReuseIdentifier: "StoreSelectViewCell")
    }
    
}
