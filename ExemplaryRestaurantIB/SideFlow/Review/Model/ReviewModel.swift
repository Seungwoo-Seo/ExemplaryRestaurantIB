//
//  ReviewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/10/11.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

struct ReviewModel {
    
    var handle: AuthStateDidChangeListenerHandle?
    let ref = Database.database().reference()
    let storageRef = Storage.storage().reference()
    
    var storeName: String?
    var storeUID: String?
    var userUID: String?
    var userName: String?
    
    var starScore: Int?
    var reviewText: String? = "음식 맛, 서비스 등 후기를 작성해주세요."
    var reviewImageList: [(UIImage, Int)] = []
    
    
    
    
    
    
    // MARK: Review
    var reviewList: [(Review, [UIImage?])] = []

    
    // ReviewViewController
    // 실시간 데이터베이스에서 유저가 쓴 리뷰에서 이미지 외의 모든 데이터
    var userReviewList: [String: Review]?
    
    // Storage에서 유저가 쓴 리뷰에서 이미지 데이터들
    var userReviewImageList: [String: [UIImage]]?
    
    // 최종 userReview
    var finalUserReviewList: [(Review, [UIImage]?)] = []

}


