//
//  UserReviewImageCell.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/10/27.
//

import UIKit
import SnapKit

class UserReviewImageCell: UICollectionViewCell {
    
    lazy var reviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
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

private extension UserReviewImageCell {
    
    func setupLayout() {
        [reviewImageView].forEach { contentView.addSubview($0) }
        
        reviewImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}

