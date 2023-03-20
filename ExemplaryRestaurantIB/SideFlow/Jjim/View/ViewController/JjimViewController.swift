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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        vm.viewWillAppear(self) { alert in
            if let alert = alert {
                self.present(alert, animated: true)
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        vm.removeStateDidChangeListener()
    }
    
}

extension JjimViewController: UITableViewDataSource, UITableViewDelegate {
    
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

private extension JjimViewController {
    
    func setupUI() {
        // navigation
        self.navigationItem.title = "찜"

        // tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
}
