//
//  JjimModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/26.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

struct JjimModel {
    
    let ref = Database.database().reference().child("UserJjimList")
    var handle: AuthStateDidChangeListenerHandle?
    
    var userUID: String?
    
    var storeList: [Store] = []
    
}
