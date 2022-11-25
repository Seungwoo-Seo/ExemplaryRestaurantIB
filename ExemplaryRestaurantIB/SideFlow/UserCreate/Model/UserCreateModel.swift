//
//  UserCreateModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/28.
//

import Foundation
import FirebaseDatabase

struct UserCreateModel {
    
    var email: String?
    var password: String?
    var passwordAgain: String?
    var name: String?
    var birthDay: String?
    var gender: String?
    var cellphone: String?
    
    let ref = Database.database().reference().child("UserList")
    
}
