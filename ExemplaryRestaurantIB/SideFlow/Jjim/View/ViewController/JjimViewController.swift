//
//  JjimViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/22.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class JjimViewController: UIViewController {
    
    // MARK: @IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: ViewModel
    let vm = JjimViewModel()
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
        setupGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.vm.createModel_handle { [weak self] result in
            guard let self = self else {return}
            
            if result {
                self.vm.readRef_usersJjimList {
                    self.tableView.reloadData()
                }
            }
        }
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.vm.deleteModel_handle()
    }
    
}

extension JjimViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.vm.storeList.count
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "JjimTableViewCell", for: indexPath) as? JjimTableViewCell else {return UITableViewCell()}
        let store = self.vm.storeList[indexPath.row]
        
//        cell.storeNameLabel.text = store.storeName
//        cell.storeMainMenuLabel.text = store.storeMainMenu
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(identifier: "StoreViewController") as? StoreInfoViewController else {return}
        let store = self.vm.storeList[indexPath.row]
    
        vc.vm.createModel_store(store: store)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: Setup
extension JjimViewController: Setup {
    
    func setupUI() {
        setupUI_navigation()
        setupUI_tableView()
    }
    
    func setupLayout() {
        
    }
    
    func setupGesture() {
        
    }
    
}

// MARK: for setupUI
private extension JjimViewController {
    
    func setupUI_navigation() {
        self.navigationItem.title = "찜"
    }
    
    func setupUI_tableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
}
