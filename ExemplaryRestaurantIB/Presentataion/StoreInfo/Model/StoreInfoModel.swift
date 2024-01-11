//
//  StoreInfoModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/20.
//

import Foundation
import CoreLocation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

struct StoreInfoModel {
    
    var handle: AuthStateDidChangeListenerHandle?   // Auth
    let ref = Database.database().reference()       // FIR
    let storageRef = Storage.storage().reference()  // FIS
    
    var userUID: String?
    
    // 최종 모범음식점
    var store: Store?
    
    // mapCell
    var coordinate: CLLocationCoordinate2D?
    
    // storeInfoCell
    var reviewAverage: Double = 0.0
    var reviewCount: Int = 0
    var jjimcount: Int = 0
    
    var isJjim: Bool = false
    
    // storeReviewCell
    var isReview: Bool = false
    
    
    var urlList: [URL] = []
    var storeReviewList: [StoreReview] = []
    var containerList: [ContainerStoreReview] = []
    
    
    
    var reviewSnapshots: [DataSnapshot] = []
    
}
