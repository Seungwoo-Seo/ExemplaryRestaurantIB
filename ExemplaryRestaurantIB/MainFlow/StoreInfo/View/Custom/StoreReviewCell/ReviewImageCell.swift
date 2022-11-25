//
//  ReviewImageCell.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/17.
//

import UIKit
import SnapKit

class ReviewImageCell: UICollectionViewCell {
    
    lazy var reviewImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Setup
extension ReviewImageCell: Setup {
    
    func setupUI() {
        setupUI_reviewImageView()
    }
    
    func setupLayout() {
        setupLayout_reviewImageView()
    }
    
}

// MARK: for setupUI
private extension ReviewImageCell {
    
    func setupUI_reviewImageView() {
        let imageView = self.reviewImageView
        
        self.contentView.addSubview(imageView)
    }
    
}

// MARK: for setupLayout
private extension ReviewImageCell {
    
    func setupLayout_reviewImageView() {
        reviewImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
}
