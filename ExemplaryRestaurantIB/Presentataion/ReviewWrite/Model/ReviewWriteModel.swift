//
//  ReviewWriteModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/10/11.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

struct ReviewWriteModel {
    
    var handle: AuthStateDidChangeListenerHandle?
    let ref = Database.database().reference()
    let storageRef = Storage.storage().reference()
    
    // 유저 이름
    var userName: String?
    // 스토어 식별자
    var storeUID: String?
    // 업소 이름
    var storeName: String?
    
    // 별점
    var starScore: Double?
    // 리뷰내용
    var reviewText: String?
    // 리뷰 이미지
    var photoList: [Photo]?
}


