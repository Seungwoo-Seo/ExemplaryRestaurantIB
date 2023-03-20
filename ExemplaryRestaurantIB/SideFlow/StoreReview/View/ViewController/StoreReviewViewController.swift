//
//  StoreReviewViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2023/01/26.
//

import UIKit
import SnapKit

class StoreReviewViewController: UIViewController {
    
    lazy var storeReviewTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StoreReviewCell.self, forCellReuseIdentifier: "StoreReviewCell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .white
        refreshControl.tintColor = .darkGray
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        return tableView
    }()
    
    lazy var lodingView: LodingView = {
        let view = LodingView()
        view.backgroundColor = .white
        
        return view
    }()
    
    let vm = StoreReviewViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        vm.viewDidLoad(self)
    }
    
    @objc func refresh() {
        vm.refresh(self)
    }
    
}

extension StoreReviewViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return vm.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return vm.tableView(tableView, cellForRowAt: indexPath)
    }
}

private extension StoreReviewViewController {
    
    func setupLayout() {
        [
            storeReviewTableView,
            lodingView
        ].forEach { view.addSubview($0) }
        
        storeReviewTableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        lodingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
