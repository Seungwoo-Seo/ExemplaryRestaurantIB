//
//  UserCreateViewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/28.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import PromiseKit
import Lottie

class UserCreateViewModel {
    
    private var model = UserCreateModel()
    
    private var ref: DatabaseReference {
        return self.model.ref
    }
    
}

extension UserCreateViewModel {
 
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, vc: UserCreateViewController){
        vc.view.endEditing(true)
    }
    
}
    
extension UserCreateViewModel {
    
    func didTapBackButton(_ sender: UIButton, completionHandler: () -> ()) {
        completionHandler()
    }
    
    func didTapEmailOverlapCheckButton(_ sender: UIButton, animationView: AnimationView, completionHandler: @escaping (UIAlertController) -> ()) {
        if let email = model.email {
            self.ref.child("UserList").queryOrdered(byChild: "userEmail").queryEqual(toValue: email).observeSingleEvent(of: .value, with: { snapshot in
                guard let _ = snapshot.value as? [String: Any] else {
                    
                    let alert = Alert.confirmAlert(title: "사용 가능") { [weak animationView] in
                        animationView?.isHidden = false
                        animationView?.play(toFrame: 39) { _ in
                            animationView?.pause()
                        }
                    }
                    self.model.emailState = true
                    completionHandler(alert)
                    return
                }
            
                animationView.isHidden = true
                
                let alert = Alert.confirmAlert(title: "중복된 아이디(이메일)입니다.")
                self.model.emailState = false
                completionHandler(alert)
            })
        } else {
            animationView.stop()
            
            let alert = Alert.confirmAlert(title: "아이디(이메일)을 작성해주세요.")
            self.model.emailState = false
            completionHandler(alert)
        }
    }
    
    func didTapUserCreateButton(_ sender: UIButton, nameTextField: UITextField, vc: UserCreateViewController, completionHandler: @escaping (UIAlertController) -> ()) {
        if model.emailState && model.passwordState {
            guard model.password == model.passwordAgain else {
                let alert = Alert.confirmAlert(title: "비밀번호가 같지 않습니다.")
                completionHandler(alert)
                return
            }
            
            if nameTextField.isEditing {
                nameTextField.resignFirstResponder()
            }
            
            guard let email = model.email,
                  let password = model.password,
                  let name = model.name else {return}
            
            firstly {
                self.createUser(email: email, password: password)
            }.then { userUID in
                self.createFIR_UserList(userUID, email: email, name: name)
            }.done { _ in
                let alert = Alert.confirmAlert(title: "가입이 완료되었습니다.") {
                    vc.dismiss(animated: true)
                }
                completionHandler(alert)
            }.catch { error in
                let alert = Alert.confirmAlert(title: "현재 회원가입을 할 수 없습니다.")
                completionHandler(alert)
            }
        }
    }
    
    private func createUser(email: String, password: String) -> Promise<String> {
        return Promise { seal in
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                guard error == nil else {seal.reject(UserCreateError.userCreateError); return}
                
                let userUID = authResult!.user.uid
                seal.fulfill(userUID)
            }
        }
    }
    
    private func createFIR_UserList(_ userUID: String, email: String, name: String) -> Promise<Void> {
        return Promise { seal in
            let setValue: [String: Any] = [
                "userName": name,
                "userEmail": email,
                "jjimCount": 0,
                "reviewCount": 0
            ]
            
            self.ref.child("UserList").child(userUID).setValue(setValue) { error, _ in
                guard error == nil else {seal.reject(UserCreateError.userListError); return}
                do {
                    try Auth.auth().signOut()
                    seal.fulfill(Void())
                } catch {
                    seal.reject(UserCreateError.userListError)
                }
            }
        }
    }
    
    enum UserCreateError: Error {
        case userCreateError
        case userListError
    }
    
}

extension UserCreateViewModel {
    
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, overlapButton: UIButton, animationView: AnimationView) -> Bool {
        
        if textField.tag == 0 {
            guard let text = textField.text else {return false}
            
            var checkText: String
            
            if range.length != 0 {
                checkText = String(text.dropLast(range.length))
            } else {
                checkText = text + string
            }

            if checkRegex(checkText: checkText, regex: .email) {
                overlapButton.isEnabled = true
                model.emailState = true
                model.email = checkText
            } else {
                overlapButton.isEnabled = false
                model.emailState = false
                model.email = nil
            }
            
        } else if textField.tag == 2 {
            guard let text = textField.text else {return false}
            
            var checkText: String
            
            if range.length != 0 {
                checkText = String(text.dropLast(range.length))
            } else {
                checkText = text + string
            }

            if checkRegex(checkText: checkText, regex: .password) {
                if model.password == checkText {
                    animationView.play(toFrame: 39) { _ in
                        animationView.pause()
                    }
                    model.passwordAgain = checkText
                    model.passwordState = true
                } else {
                    animationView.stop()
                    model.passwordAgain = nil
                    model.passwordState = false
                }
                
            } else {
                animationView.stop()
                model.passwordAgain = nil
                model.passwordState = false
            }
        }
            
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, completionHandler: (UIAlertController) -> ()) {
        if textField.tag == 0 {
            guard model.emailState else {model.email = nil; return}
            model.email = textField.text
            
        } else if textField.tag == 1 {
            guard let checkText = textField.text else {return}
            if checkRegex(checkText: checkText, regex: .password) {
                model.password = checkText
            } else {
                let alert = Alert.confirmAlert(title: "비밀번호 형식이 틀렸습니다. 영어, 숫자, 특수문자를 조합하세요.") { textField.text = nil }
                completionHandler(alert)
            }
        } else if textField.tag == 3 {
            guard let checkText = textField.text else {return}
            if checkRegex(checkText: checkText, regex: .name) {
                model.name = checkText
            } else {
                let alert = Alert.confirmAlert(title: "한글만 가능합니다.") { textField.text = nil }
                completionHandler(alert)
            }
        }
    }
    
}
