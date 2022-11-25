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
    @IBOutlet var nameChangeTextField: UITextField!
    
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var nowPasswordTextField: UITextField!
    @IBOutlet var newPasswordTextField: UITextField!
    @IBOutlet var cellphoneChangeTextField: UITextField!
    
    
    // MARK: ViewModel
    let vm = MyViewModel()
    
    
    // MARK: Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
        setupGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 여기는 일단 유저가 무조건 있어야 옴
        self.vm.createModel_handle { [weak self] result in
            guard let self = self else {return}
            if result {
                self.vm.readRef_userInfo { value in
                    self.nameChangeTextField.text = value["userName"]
                    self.emailLabel.text = value["userEmail"]
                    self.cellphoneChangeTextField.text = value["userCellphone"]
                }
            }
        }
    
    }
    
    
    // MARK: @IBActions
    @IBAction func didTapProfileChangeButton(_ sender: UIButton) {
        print("이건 좀 이후에")
    }
    
    
    @IBAction func didTapChangeButton(_ sender: UIButton) {
        guard let name = self.nameChangeTextField.text else {return}
        self.vm.updateRef_userName(name: name)
        
        if let email = emailLabel.text,
           let nowPassword = nowPasswordTextField.text,
           let newPassword = newPasswordTextField.text {
            self.vm.auth_updatePassword(email: email,
                                        nowPassword: nowPassword,
                                        newPassword: newPassword)
        }
        
        guard let cellphone = self.cellphoneChangeTextField.text else {return}
        self.vm.updateRef_userCellphone(cellphone: cellphone)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func didTapLogout(_ sender: UIButton) {
        self.vm.auth_signOut { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func didTapUserDeleteButton(_ sender: UIButton) {
        self.vm.auth_userDelete { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
}

// MARK: Setup
extension MyChangeViewController: Setup {
    
    func setupUI() {
        setupUI_navigation()
    }
    
    func setupLayout() {
        
    }
    
    func setupGesture() {
        
    }
    
}

// MARK: for setupUI
private extension MyChangeViewController {
    
    func setupUI_navigation() {
        self.navigationItem.title = "내 정보 수정"
    }
    
}
