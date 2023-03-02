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
    
    var store: Store?
    
    var coordinate: CLLocationCoordinate2D?
    
    // auth
    var handle: AuthStateDidChangeListenerHandle?
    
    // firebase
    let ref = Database.database().reference()
    
    // storage
    let storageRef = Storage.storage().reference()
    
    var userUID: String?
    
    
    // server
    var storeStarScore: Int = 0
    var storeAverage: Double = 0.0
    var storeReviewCount: Int = 0
    
    
    
    

    // jjimButtonisSelected
    var jjimIsSelected: Bool = false
    
    
    
    // 로그인을 했는지 안했는지 알려줄 프로퍼티
    var checkLogin: Bool = false
    
    
    // 해당 스토어의 리뷰들
    var storeReviewList: [StoreReview] = []
    
    // 각 리뷰에 이미지
    var totalReviewImageList: [String: [UIImage?]] = [:]
    
    // storeReviewcell collectionview 에서 사용할
    var reviewImageList: [UIImage?] = []
    
    
    
    
    
    var finalStoreReviewList: [FinalStoreReview] = []
    
    
    
    
    // MARK: Reivew 관련
    var userImage: UIImage?
    var userName: String?
    var starScore: Int?
    var reviewImage: UIImage?
    var reviewText: String?
    
}



    

