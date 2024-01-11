//
//  UserReviewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/29.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

struct UserReviewModel {
    
    var handle: AuthStateDidChangeListenerHandle?
    let ref: DatabaseReference = Database.database().reference()
    let storage: Storage = Storage.storage()
    
    var containerList: [ContainerUserReview]?
    var container: ContainerUserReview?
}
