//
//  BusinessTypeSelectHeaderView.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/23.
//

import UIKit

class BusinessTypeSelectHeaderView: UIView {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var gooSelectButton: UIButton!
    @IBOutlet weak var businessTypeSortButton: UIButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupUI()
    }
    
}

private extension BusinessTypeSelectHeaderView {
    
    func setupUI() {
        clipsToBounds = true
        layer.cornerRadius = 15.0
        layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
    }
    
}
