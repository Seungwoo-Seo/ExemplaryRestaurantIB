//
//  LoginViewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/05.
//

import Foundation
import FirebaseAuth
import PromiseKit
import RxSwift

class LoginViewModel {
    
    private var model = LoginModel()
    
}

extension LoginViewModel {
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, vc: LoginViewController) {
        vc.view.endEditing(true)
    }
    
}

extension LoginViewModel {
        
    func didTapBackButton(_ sender: UIButton, vc: LoginViewController) {
        vc.dismiss(animated: true)
    }
    
    func didTapLoginButton(_ sender: UIButton, vc: LoginViewController, completionHandler: @escaping (UIAlertController) -> ()) {
        
        vc.emailTextField.endEditing(true)
        vc.passwordTextField.endEditing(true)
        
        guard let email = self.model.email,
              let password = self.model.password else {return}
    
        self.signIn(email: email, password: password)
            .done { _ in
                let alert = Alert.confirmAlert(title: "로그인 되었습니다.") { [weak vc] in
                    DispatchQueue.main.async {
                        vc?.dismiss(animated: true)
                    }
                }
                completionHandler(alert)
            }
            .catch { error in
                guard let error = error as? LoginError else {return}
                
                var alert = Alert.confirmAlert(title: "현재 로그인 할 수 없습니다.")
                
                switch error {
                case .emailRegex:
                    alert = Alert.confirmAlert(title: "이메일 형식에 맞게 작성하시오.")
                    completionHandler(alert)
                    
                case .passwordRegex:
                    alert = Alert.confirmAlert(title: "비밀번호 형식이 틀렸습니다. 영어, 숫자, 특수문자를 조합하세요.")
                    completionHandler(alert)
                    
                case .notEmail:
                    alert = Alert.confirmAlert(title: "없는 이메일입니다.")
                    completionHandler(alert)
                    
                case .notPassword:
                    alert = Alert.confirmAlert(title: "틀린 비밀번호입니다.")
                    completionHandler(alert)
                    
                case .cantLogin:
                    completionHandler(alert)
                    
                default:
                    completionHandler(alert)
                }
            }
    }
    
    func didTapUserFindButton(_ sender: UIButton, vc: LoginViewController, completionHandler: @escaping (UIAlertController) -> ()) {
        self.sendPasswordReset(vc)
            .done { _ in
                let alert = Alert.confirmAlert(title: "전송 완료")
                completionHandler(alert)
            }
            .catch { error in
                guard let error = error as? LoginError else {return}
                
                var alert = Alert.confirmAlert(title: "전송 실패")
                
                switch error {
                case .emailRegex:
                    alert = Alert.confirmAlert(title: "이메일 형식에 맞게 작성하시오.")
                    completionHandler(alert)
                    
                case .emailEmpty:
                    alert = Alert.confirmAlert(title: "이메일을 작성하시오.")
                    completionHandler(alert)
                    
                case .sendPasswordReset:
                    completionHandler(alert)
                    
                default:
                    completionHandler(alert)
                }
            }
    }
    
    // 회원가입
    func didTapCreateUserButton(_ sender: UIButton, completionHandler: (UserCreateViewController) -> ()) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserCreateViewController") as? UserCreateViewController else {return}
        
        vc.modalPresentationStyle = .fullScreen
        
        completionHandler(vc)
    }
  
}

// textFieldDelegate
extension LoginViewModel {

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            if textField.text?.isEmpty != true {
                self.model.email = textField.text
            } else {
                self.model.email = nil
            }
            
        } else if textField.tag == 1 {
            if textField.text?.isEmpty != true {
                self.model.password = textField.text
            } else {
                self.model.password = nil
            }
        }
    }

}

private extension LoginViewModel {
    
    enum LoginError: Error {
        case emailRegex
        case passwordRegex
        case notEmail
        case notPassword
        case cantLogin
        case emailEmpty
        case sendPasswordReset
    }
    
    enum Regex: String {
        case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        case password = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,20}"
        case name = "^[가-힇]*$"
    }
    
    func checkRegex(checkText: String, regex: Regex) -> Bool {
        switch regex {
        case .email:
            return NSPredicate(format: "SELF MATCHES %@", regex.rawValue).evaluate(with: checkText)
            
        case .password:
            return NSPredicate(format: "SELF MATCHES %@", regex.rawValue).evaluate(with: checkText)
            
        case .name:
            return NSPredicate(format: "SELF MATCHES %@", regex.rawValue).evaluate(with: checkText)
        }
    }
    
    func signIn(email: String, password: String) -> Promise<Void> {
        return Promise { seal in
            guard self.checkRegex(checkText: email, regex: .email) else {seal.reject(LoginError.emailRegex); return}
            guard self.checkRegex(checkText: password, regex: .password) else {seal.reject(LoginError.passwordRegex); return}
            
            Auth.auth().signIn(withEmail: email, password: password) { _, error in
                if let error = error as? NSError {
                    switch error.code {
                    case 17008: // 이메일 에러
                        seal.reject(LoginError.notEmail)
                        
                    case 17009: // 비밀번호 에러
                        seal.reject(LoginError.notPassword)
                        
                    default:
                        seal.reject(LoginError.cantLogin)
                    }
                } else {
                    seal.fulfill(Void())
                }
            }
        }
    }
    
    func sendPasswordReset(_ vc: LoginViewController) -> Promise<Void> {
        return Promise { seal in
            let alert = UIAlertController(title: "계정 찾기", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            let confirm = UIAlertAction(title: "전송", style: .default) { _ in
                guard let email = alert.textFields?[0].text else {seal.reject(LoginError.emailEmpty); return}
                guard self.checkRegex(checkText: email, regex: .email) else {seal.reject(LoginError.emailRegex); return}
                
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    guard error == nil else {seal.reject(LoginError.sendPasswordReset); return}
                    seal.fulfill(Void())
                }
            }
            
            [cancel, confirm].forEach { alert.addAction($0) }
            
            alert.addTextField { textField in
                textField.placeholder = "이메일을 입력하세요."
            }
         
            vc.present(alert, animated: true)
        }
    }
    
}
