//
//  StoreSelectModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/19.
//

import Foundation
import FirebaseDatabase

struct StoreSelectModel {
 
    let ref: DatabaseReference = Database.database().reference()
    
    var businessTypeList: [String] = []
    var currentBusinessType: String = ""
    var nowGooType: (gooName: String, gooCode: String?) = ("", nil)
    
    var viewControllers: [UIViewController] = []
    
    var storeList: [Store] = []
    var containerList: [ContainerStoreRating] = []
}
