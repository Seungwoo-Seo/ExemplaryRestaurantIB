//
//  StoreEvaluationStackView0.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/11.
//

import UIKit
import SnapKit

final class StoreEvaluationStackView0: UIStackView {
    
    // MARK: View
    lazy var starImageView0: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star")
        imageView.tintColor = .black
        
        return imageView
    }()
    
    lazy var starImageView1: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star")
        imageView.tintColor = .black
        
        return imageView
    }()
    
    lazy var starImageView2: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star")
        imageView.tintColor = .black
        
        return imageView
    }()
    
    lazy var starImageView3: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star")
        imageView.tintColor = .black
        
        return imageView
    }()
    
    lazy var starImageView4: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star")
        imageView.tintColor = .black
        
        return imageView
    }()
    
    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension StoreEvaluationStackView0 {
    
    func setupLayout() {
        [
            starImageView0,
            starImageView1,
            starImageView2,
            starImageView3,
            starImageView4
        ].forEach { addArrangedSubview($0) }
    }
    
}


