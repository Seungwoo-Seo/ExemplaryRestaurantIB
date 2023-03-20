//
//  StoreReviewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2023/01/26.
//

import Foundation
import FirebaseDatabase
import RxSwift

struct StoreReviewModel {
    
    let ref = Database.database().reference()
    let disposeBag = DisposeBag()
    
    var store: Store?
    
    var storeReviewList: [StoreReview] = []
    var imageUrlList: [URL]?
    
}
