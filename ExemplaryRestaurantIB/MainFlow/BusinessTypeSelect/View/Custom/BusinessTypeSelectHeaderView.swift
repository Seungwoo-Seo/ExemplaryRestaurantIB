//
//  BusinessTypeSelectHeaderView.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/23.
//

import UIKit

class BusinessTypeSelectHeaderView: UIView {
    
    // searchBar
    @IBOutlet weak var searchBar: UISearchBar!
    // gooSelectButton
    @IBOutlet weak var gooSelectButton: UIButton!
    // businessTypeSortButton
    @IBOutlet weak var businessTypeSortButton: UIButton!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupUI()
    }
    
}

private extension BusinessTypeSelectHeaderView {
    
    func setupUI() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 15.0
        self.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
    }
    
}
