//
//  MyModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/04.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

struct MyModel {
    
    let ref = Database.database().reference()
    var handle: AuthStateDidChangeListenerHandle?
    
    var userUID: String?
    var userName: String?
    
}

