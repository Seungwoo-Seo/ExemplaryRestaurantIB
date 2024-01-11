//
//  MyChangeModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2023/01/03.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

struct MyChangeModel {
    
    let ref = Database.database().reference()
    var handle: AuthStateDidChangeListenerHandle?
    let storage = Storage.storage()
    
    var userName: String?
    var userEmail: String?
    var nowPassword: String?
    var newPassword: String?
    
    var isPassword: Bool = false
}
