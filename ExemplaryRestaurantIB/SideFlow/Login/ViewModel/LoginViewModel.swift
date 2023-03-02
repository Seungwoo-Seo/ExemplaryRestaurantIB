//
//  LoginViewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/05.
//

import Foundation
import FirebaseAuth

class LoginViewModel {
    
    private var model = LoginModel()
    
}

// MARK: auth
extension LoginViewModel {
    
    func auth_signIn(email: String, password: String, completionHandler: @escaping () -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print(error)
            }
            
            completionHandler()
        }
    }
    
}
