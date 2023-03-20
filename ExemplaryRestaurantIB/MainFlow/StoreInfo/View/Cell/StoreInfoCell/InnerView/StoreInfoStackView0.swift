//
//  StoreInfoStackView0.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/13.
//

import UIKit

class StoreInfoStackView0: UIStackView {
    
    // MARK: View
    lazy var mainMenuLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "메인메뉴"
        label.font = .systemFont(ofSize: 17.0, weight: .regular)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        return label
    }()
    
    lazy var storeMainMenuLabel: UILabel = {
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

private extension StoreInfoStackView0 {

    func setupLayout() {
        [
            mainMenuLabel,
            storeMainMenuLabel
        ].forEach { addArrangedSubview($0) }
    }
    
}


