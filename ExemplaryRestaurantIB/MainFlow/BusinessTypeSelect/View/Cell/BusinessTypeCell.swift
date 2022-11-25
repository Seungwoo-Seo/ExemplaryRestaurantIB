//
//  BusinessTypeCell.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/23.
//

import UIKit

class BusinessTypeCell: UICollectionViewCell {
    
    @IBOutlet weak var businessTypeImageView: UIImageView!
    @IBOutlet weak var businessTypeLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
        
}

private extension BusinessTypeCell {
    
    func setupUI() {
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
    }
    
}
