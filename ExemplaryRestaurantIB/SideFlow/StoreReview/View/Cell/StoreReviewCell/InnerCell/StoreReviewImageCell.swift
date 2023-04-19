//
//  StoreReviewImageCell.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2023/01/25.
//

import UIKit
import SnapKit

class StoreReviewImageCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        
        return imageView
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension StoreReviewImageCell {
    
    func setupLayout() {
        [imageView].forEach { contentView.addSubview($0) }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
