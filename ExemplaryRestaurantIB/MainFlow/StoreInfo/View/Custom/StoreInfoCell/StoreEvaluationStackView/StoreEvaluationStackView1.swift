//
//  StoreEvaluationStackView1.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/11.
//

import UIKit

class StoreEvaluationStackView1: UIStackView {
    
    // MARK: View
    lazy var storeScoreAverageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 17.0, weight: .bold)
        label.text = "0.0"
        
        return label
    }()
    
    lazy var storeReviewCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 17.0, weight: .bold)
        label.text = "0"
        
        return label
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

private extension StoreEvaluationStackView1 {
    
    func setupLayout() {
        [
            storeScoreAverageLabel,
            storeReviewCountLabel
        ].forEach { addArrangedSubview($0) }
    }
    
}


