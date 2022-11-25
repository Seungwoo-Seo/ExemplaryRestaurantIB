//
//  UserCreateViewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/28.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class UserCreateViewModel {
    
    private var model = UserCreateModel()
    
    private var ref: DatabaseReference {
        return self.model.ref
    }
    
    var email: String? {
        return self.model.email
    }
    
    var password: String? {
        return self.model.password
    }
    
    var passwordAgain: String? {
        return self.model.passwordAgain
    }
    
    var name: String? {
        return self.model.name
    }
    
    var birthDay: String? {
        return self.model.birthDay
    }
    
    var gender: String? {
        return self.model.gender
    }
    
    var cellphone: String? {
        return self.model.cellphone
    }
    
}
    
// MARK: crud model
extension UserCreateViewModel {

    func createModel(email: String,
                     password: String,
                     passwordAgain: String,
                     name: String,
                     birthDay: String,
                     gender: String,
                     cellphone: String) {
        self.model.email = email
        self.model.password = password
        self.model.passwordAgain = passwordAgain
        self.model.name = name
        self.model.birthDay = birthDay
        self.model.gender = gender
        self.model.cellphone = cellphone
    }
    
}

// MARK: ref
extension UserCreateViewModel {
    
    // MARK: create
    func createRef_user(uid: String,
                        email: String,
                        name: String,
                        birthDay: String,
                        gender: String,
                        cellphone: String) {
        // email
        self.ref.child("\(uid)/userEmail").setValue("\(email)")
        // 이름
        self.ref.child("\(uid)/userName").setValue("\(name)")
        // 생년월일
        self.ref.child("\(uid)/userBirthDay").setValue("\(birthDay)")
        // 성별
        self.ref.child("\(uid)/userGender").setValue("\(gender)")
        // 휴대전화
        self.ref.child("\(uid)/userCellphone").setValue("\(cellphone)")
    }
    
    // MARK: read
    func readRef_emailOverlapCheck(email: String, completionHandler: @escaping (Bool) -> ()) {
        
        self.ref.queryOrdered(byChild: "userEmail").queryEqual(toValue: email).observe(.value) { snapshot in
            guard let _ = snapshot.value as? [String: Any] else {
                completionHandler(true)
                return
            }
            completionHandler(false)
        }
    }
    
}

// MARK: auth
extension UserCreateViewModel {
    
    func auth_createUser(completionHandler: @escaping () -> ()) {
        guard let email = self.email,
              let password = self.password,
              //              let passwordAgain = self.passwordAgain,
              let name = self.name,
              let birthDay = self.birthDay,
              let gender = self.gender,
              let cellphone = self.cellphone else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else {return}
            if let error = error {
                // 브릿징 - 브릿징 한 이유는 NSError 의 code를 사용하고 싶어서
                let code = (error as NSError).code
                switch code {
                case 17007:
                    // 왜냐 17007 에러는 계정 중복이기 때문
                    print("이미 있는 아이디 입니다.")
                default:
                    print(error.localizedDescription)
                }
            } else {
                print("가입이 완료되었습니다.")
                guard let uid = authResult?.user.uid else {return}
                
                self.createRef_user(uid: uid,
                                    email: email,
                                    name: name,
                                    birthDay: birthDay,
                                    gender: gender,
                                    cellphone: cellphone)
                
                do {
                    try Auth.auth().signOut()
                }catch {
                    print(error)
                }
                
                // 가입 성공
                completionHandler()
            }
            
        }
    }
    
}

extension UserCreateViewModel {
    
    func effectivenessCheck() {
        
    }
    
}
