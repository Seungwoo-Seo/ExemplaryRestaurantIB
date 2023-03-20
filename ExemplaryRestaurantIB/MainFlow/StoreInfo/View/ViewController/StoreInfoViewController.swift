//
//  StoreInfoViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/10.
//

import UIKit
import SnapKit

final class StoreInfoViewController: UIViewController {
    
    // MARK: @IBOutlet
    @IBOutlet var tableView: StoreInfoTableView!
    
    // MARK: View
    lazy var lodingView: LodingView = {
        let view = LodingView(frame: .zero)
        view.alpha = 0.0
        view.backgroundColor = .white
        
        return view
    }()
    
    lazy var reviewWriteButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "리뷰 작성하기"
        button.style = .plain
        button.tintColor = .black
        button.target = self
        button.action = #selector(didTapReviewWriteButton(_:))
        
        return button
    }()
    
    
    // MARK: ViewModel
    let vm = StoreInfoViewModel()
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        vm.viewWillAppear(lodingView,
                          navigationVC: navigationController,
                          tableView: tableView) { alert in
            if let alert = alert {
                self.present(alert, animated: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        vm.removeStateDidChangeListener()
    }
    
    
    // MARK: actions
    @objc func didTapReviewWriteButton(_ sender: UIButton) {
        vm.didTapReviewWriteButton(sender) { vc, alert in
            if let vc = vc {
                self.navigationController?.pushViewController(vc, animated: true)
            } else if let alert = alert {
                self.present(alert, animated: true)
            }
        }
    }
    
}

// MARK: tableView
extension StoreInfoViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return vm.numberOfSections(in: tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return vm.tableView(tableView,
                            numberOfRowsInSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return vm.tableView(tableView,
                            cellForRowAt: indexPath,
                            delegate: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return vm.tableView(tableView,
                            heightForRowAt: indexPath)
    }
    
}

// MARK: MapCellDelegate, StoreInfoCellDelegate, StoreReviewCellDelegate
extension StoreInfoViewController: MapCellDelegate, StoreInfoCellDelegate, StoreContentCelllDelegate {
    
    // MapCellDelegate
    func setupUI_mapView(_ mapView: MTMapView) {
        vm.setupUI_mapView(mapView) { [weak self] alert in
            if let alert = alert {
                self?.present(alert, animated: true)
            }
        }
    }
    
    // StoreInfoCellDelegate
    func setupUI_callButton(_ sender: UIButton) {
        vm.setupUI_callButton(sender) {
            self.present($0, animated: true)
        }
    }
    
    func setupUI_jjimButton(_ sender: UIButton) {
        vm.setupUI_jjimButton(sender) {
            self.present($0, animated: true)
        }
    }
    
    func setupUI_shareButton(_ sender: UIButton) {
        vm.setupUI_shareButton(sender, view: view) {
            self.present($0, animated: true, completion: nil)
        }
    }
    
    // StoreContentCelllDelegate
    func didTapShowStoreReviewButton(_ sender: UIButton) {
        vm.didTapShowStoreReviewButton(sender) { vc in
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

// MARK: private
private extension StoreInfoViewController {
    
    func setupUI() {
        self.navigationItem.backButtonTitle = ""
        
        // tableView
        tableView.register(MapCell.self, forCellReuseIdentifier: "MapCell")
        tableView.register(StoreInfoCell.self, forCellReuseIdentifier: "StoreInfoCell")
        tableView.register(StoreContentCell.self, forCellReuseIdentifier: "StoreContentCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setupLayout() {
        [lodingView].forEach { view.addSubview($0) }
        self.navigationItem.rightBarButtonItem = reviewWriteButton
        
        lodingView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
}
