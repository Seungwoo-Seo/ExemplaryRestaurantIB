//
//  MyViewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/04.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class MyViewModel {
 
    private var model = MyModel()
    
    private var ref: DatabaseReference {
        return self.model.ref
    }
        
    private var handle: AuthStateDidChangeListenerHandle? {
        return self.model.handle
    }
    
    var userUID: String? {
        return self.model.userUID
    }
    
}

// MARK: model
extension MyViewModel {
    
    // MARK: create
    func createModel_handle(completinoHandler: @escaping (Bool) -> ()) {
        self.model.handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let user = user else {
                completinoHandler(false)
                return
            }
            
            let userUID = user.uid
            self?.createModel_userUID(userUID: userUID)
            completinoHandler(true)
        }
    }
    
    func createModel_userUID(userUID: String) {
        self.model.userUID = userUID
    }
    
    // MARK: delete
    func deleteModel_handle() {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    func deleteModel_userUID() {
        self.model.userUID = nil
    }
    
}

// MARK: ref
extension MyViewModel {
    
    // MARK: read
    func readRef_userName(completionHandler: @escaping (String) -> ()) {
        guard let userUID = self.userUID else {return}
        self.ref.child(userUID).child("userName").getData { error, snapshot in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                let userName = snapshot?.value as? String ?? "Unknown 이름이 없습니다."
                completionHandler(userName)
            }
        }
    }
    
    func readRef_userInfo(completionHandler: @escaping ([String: String]) -> ()) {
        guard let userUID = self.userUID else {return}
        
        self.ref.child(userUID).getData { error, snapshot in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                if let value = snapshot?.value as? [String: String] {
                    completionHandler(value)
                }
            }
        }
    }
    
    // MARK: update
    func updateRef_userName(name: String) {
        guard let userUID = self.userUID else {return}
        
        self.ref.child(userUID).updateChildValues(["userName": name])
    }
    
    func updateRef_userCellphone(cellphone: String) {
        guard let userUID = self.userUID else {return}
        
        self.ref.child(userUID).updateChildValues(["userCellphone": cellphone])
    }
    
    // MARK: delete
    func deleteRef_user() {
        guard let userUID = self.userUID else {return}
        
        self.ref.child(userUID).removeValue()
    }
    
}


// MARK: auth
extension MyViewModel {
    
    func auth_updatePassword(email: String,
                             nowPassword: String,
                             newPassword: String) {
        
        Auth.auth().signIn(withEmail: email, password: nowPassword) { authResult, error in
            if error != nil {
                print("\(error!.localizedDescription)")
            } else {
                Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
                    if let error = error {
                        print("\(error.localizedDescription)")
                    }
                    
                    print("성공")
                }
            }
        }
    }
    
    func auth_signOut(completionHandler: @escaping () -> ()) {
        do {
            try Auth.auth().signOut()
            completionHandler()
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    func auth_userDelete(completionHandler: @escaping () -> ()) {
        let user = Auth.auth().currentUser
        
        user?.delete { [weak self] error in
            if let error = error {
                print(error)
            }
            
            self?.deleteRef_user()
            completionHandler()
        }
    }
}
