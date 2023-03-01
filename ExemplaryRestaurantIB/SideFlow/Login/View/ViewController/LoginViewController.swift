//
//  LoginViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/23.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    // MARK: IBOutlet
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    
    // MARK: ViewModel
    let vm = LoginViewModel()
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        vm.touchesBegan(touches, with: event, vc: self)
    }
 
    
    // MARK: IBActions
    @IBAction func didTapBackButton(_ sender: UIButton) {
        vm.didTapBackButton(sender, vc: self)
    }
    
    // 로그인
    @IBAction func didTapLoginButton(_ sender: UIButton) {
        vm.didTapLoginButton(sender, vc: self) { [weak self] in
            self?.present($0, animated: true)
        }
    }
    
    // 계정찾기
    @IBAction func didTapUserFindButton(_ sender: UIButton) {
        vm.didTapUserFindButton(sender, vc: self) { [weak self] in
            self?.present($0, animated: true)
        }
    }
    
    // 회원가입
    @IBAction func didTapCreateUserButton(_ sender: UIButton) {
        vm.didTapCreateUserButton(sender) { [weak self] vc in
            self?.present(vc, animated: true)
        }
    }
        
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        vm.textFieldDidEndEditing(textField)
    }
    
}

private extension LoginViewController {
    
    func setupUI() {
        emailTextField.tag = 0
        emailTextField.delegate = self
        
        passwordTextField.tag = 1
        passwordTextField.placeholder = "비밀번호는 8-20자 이내 영어, 숫자, 특수문자 포함"
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
    }
    
}
