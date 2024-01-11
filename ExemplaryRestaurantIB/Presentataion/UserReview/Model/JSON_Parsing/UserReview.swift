//
//  UserReview.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/10/21.
//

import Foundation

struct UserReview: Decodable {
    
    let storeName: String
    let storeUID: String
    let starScore: Int
    let reviewText: String
    let reviewImageURL: [String]?
    let identifier: String
    let timeStamp: Int
    
}
