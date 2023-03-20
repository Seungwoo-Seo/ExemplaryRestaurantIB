//
//  UserReviewViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/22.
//

import UIKit
import SnapKit
import FirebaseDatabase
import FirebaseAuth

class UserReviewViewController: UIViewController {
    
    lazy var userReviewTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserReviewCell.self, forCellReuseIdentifier: "UserReviewCell")
        
        return tableView
    }()
    
    
    // MARK: ViewModel
    let vm = UserReviewViewModel()
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
            
        setupUI()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        vm.viewWillAppear(self) { [weak self] alert in
            self?.present(alert, animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        vm.viewWillDisappear()
    }
    
}

extension UserReviewViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return vm.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return vm.tableView(tableView,
                            cellForRowAt: indexPath,
                            delegate: self)
    }
    
}

extension UserReviewViewController: UserReviewCellDelegate {
    
    func didTapStoreNameButton(_ sender: UIButton, cell: UserReviewCell) {
        vm.didTapStoreNameButton(sender, cell: cell) {
            self.navigationController?.pushViewController($0, animated: true)
        }
    }
    
    func didTapUserReviewDeleteButton(_ sender: UIButton, cell: UserReviewCell) {
        vm.didTapUserReviewDeleteButton(sender, cell: cell, tableView: userReviewTableView) {
            self.present($0, animated: true)
        }
    }
    
}

// MARK: private
private extension UserReviewViewController {
    
    func setupUI() {
        // navigation
        self.navigationItem.title = "리뷰내역"
    }
    
    func setupLayout() {
        [userReviewTableView].forEach { view.addSubview($0) }
        
        userReviewTableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
}
