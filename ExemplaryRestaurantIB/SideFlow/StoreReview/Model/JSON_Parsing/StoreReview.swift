//
//  StoreReview.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/16.
//

import Foundation

struct StoreReview: Decodable {
    
    let userUID: String
    let userName: String
    let starScore: Int
    let reviewText: String
//    let reviewImageListIsEmpty: Bool
    let timeStamp: Int
    let reviewImageURL: [String]?
    
}
