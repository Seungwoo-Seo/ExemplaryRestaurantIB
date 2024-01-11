//
//  UserReviewCellDelegate.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/12/22.
//

import Foundation

protocol UserReviewCellDelegate: AnyObject {
    
    func didTapStoreNameButton(_ sender: UIButton, cell: UserReviewCell)
    
    func didTapUserReviewDeleteButton(_ sender: UIButton, cell: UserReviewCell)
    
}
