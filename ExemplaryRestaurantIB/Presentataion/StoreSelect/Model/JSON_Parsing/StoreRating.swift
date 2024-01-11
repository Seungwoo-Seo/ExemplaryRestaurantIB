//
//  StoreRating.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2023/01/01.
//

import Foundation

struct StoreRating: Decodable {
    
    let reviewAverage: Double
    let reviewCount: Int
    let reviewTotal: Int
    
}
