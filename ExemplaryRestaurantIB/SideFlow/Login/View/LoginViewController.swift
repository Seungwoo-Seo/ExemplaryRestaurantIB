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
        
    }
    
 
    // MARK: IBActions
    @IBAction func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func didTapLoginButton(_ sender: UIButton) {
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {return}
                
        self.vm.auth_signIn(email: email, password: password) {
            self.dismiss(animated: true)
        }
    }
    
    // 이메일 찾기
    @IBAction func didTapFindEmailButton(_ sender: UIButton) {
    }
    
    // 비밀번호 찾기
    @IBAction func didTapFindPasswordButton(_ sender: UIButton) {
        
    }
    
    // 회원가입
    @IBAction func didTapCreateUserButton(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "UserCreateViewController") as? UserCreateViewController else {return}
        vc.modalPresentationStyle = .fullScreen
        
        present(vc, animated: true)
    }
    
    // 구글로 로그인
    @IBAction func didTapGoogleLoginButton(_ sender: UIButton) {
    }
    
    // 애플로 로그인
    @IBAction func didTapAppleLoginButton(_ sender: UIButton) {
    }
    
}
