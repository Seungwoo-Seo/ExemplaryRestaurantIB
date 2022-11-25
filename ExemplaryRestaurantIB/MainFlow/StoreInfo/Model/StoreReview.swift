//
//  StoreReview.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/16.
//

import Foundation

struct StoreReview: Codable {
    
    let identifier: String
    let reviewImageCount: Int
    let userName: String
    let starScore: Int
    let reviewText: String
        
}

struct FinalStoreReview {
    
    let userName: String
    let starScore: Int
    let reviewImageList: [UIImage]
    let reviewText: String
    
}
