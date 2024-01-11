//
//  ReviewDelete.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2023/01/07.
//

import Foundation

struct ReviewDelete: Decodable {

    let starScore: Int
    let storeUID: String
    let reviewImageURL: [String]?
    let identifier: String
    
}
