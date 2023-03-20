//
//  UserCreateModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/28.
//

import Foundation
import FirebaseDatabase

struct UserCreateModel {
    
    let ref = Database.database().reference()
    
    var email: String?
    var password: String?
    var passwordAgain: String?
    var name: String?
    
    var emailState = false
    var passwordState = false
    
}
