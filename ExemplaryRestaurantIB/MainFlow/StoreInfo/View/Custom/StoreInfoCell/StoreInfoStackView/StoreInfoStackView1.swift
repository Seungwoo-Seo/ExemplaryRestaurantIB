//
//  StoreInfoStackView1.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/13.
//

import UIKit

class StoreInfoStackView1: UIStackView {
    
    // MARK: View
    lazy var selectDayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "지정일자"
        label.font = .systemFont(ofSize: 17.0, weight: .regular)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return label
    }()
    
    lazy var storeSelectDayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 17.0, weight: .regular)
        label.numberOfLines = 0
        label.text = "꽃게탕"
        
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

private extension StoreInfoStackView1 {
    
    func setupLayout() {
        [
            selectDayLabel,
            storeSelectDayLabel
        ].forEach { addArrangedSubview($0) }
    }
    
}

