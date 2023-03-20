//
//  MyChangeViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/27.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MyChangeViewController: UIViewController {
    
    // MARK: @IBOutlet
    @IBOutlet var tableView: MyChangeTableView!
    
    // MARK: View
    lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "저장"
        button.style = .plain
        button.tintColor = .black
        button.target = self
        button.action = #selector(didTapSaveButton(_:))
        
        return button
    }()
    
    
    // MARK: ViewModel
    let vm = MyChangeViewModel()
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        vm.viewWillAppear(self) { [weak self] in
            self?.present($0, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        vm.viewWillDisappear()
    }
        
    
    // MARK: action
    @objc func didTapSaveButton(_ sender: UIButton) {
        vm.didTapSaveButton(sender, vc: self) { [weak self] in
            self?.present($0, animated: true)
        }
    }
    
}

extension MyChangeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return vm.numberOfSections(in: tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return vm.tableView(tableView, cellForRowAt: indexPath, delegate: self)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return vm.tableView(tableView, viewForFooterInSection: section)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return vm.tableView(tableView, heightForFooterInSection: section)
    }
        
}

extension MyChangeViewController: MyChangeCellDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        vm.textFieldDidEndEditing(textField)
    }
    
    func didTapProfileImageButton(_ sender: UIButton) {
        vm.didTapProfileImageButton(sender)
    }
    
    func didTapChangeButton(_ sender: UIButton, nowPasswordTextField: UITextField, newPasswordTextField: UITextField) {
        vm.didTapChangeButton(sender, nowPasswordTextField: nowPasswordTextField, newPasswordTextField: newPasswordTextField)
    }
    
    func didTapLogoutButton(_ sender: UIButton) {
        vm.didTapLogoutButton(sender) { alert in
            if let alert = alert {
                self.present(alert, animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func didTapUserDeleteButton(_ sender: UIButton) {
        vm.didTapUserDeleteButton(sender, vc: self) { [weak self] in
            self?.present($0, animated: true)
        }
    }
    
}

private extension MyChangeViewController {
    
    func setupUI() {
        // navigation
        self.navigationItem.title = "내 정보 수정"
        self.navigationItem.setRightBarButton(saveButton, animated: true)
    
        tableView.register(MyChangeCell0.self
                           , forCellReuseIdentifier: "MyChangeCell0")
        tableView.register(MyChangeCell1.self
                           , forCellReuseIdentifier: "MyChangeCell1")
        tableView.register(MyChangeCell2.self
                           , forCellReuseIdentifier: "MyChangeCell2")
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
    
}
