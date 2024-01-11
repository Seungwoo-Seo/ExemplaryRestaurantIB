//
//  StoreInfoStackView3.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/13.
//

import UIKit

class StoreInfoStackView3: UIStackView {
    
    // MARK: View
    lazy var roadAddressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "도로명주소"
        label.font = .systemFont(ofSize: 17.0, weight: .regular)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return label
    }()
    
    lazy var storeRoadAddressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 17.0, weight: .regular)
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
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

private extension StoreInfoStackView3 {
    
    func setupLayout() {
        [
            roadAddressLabel,
            storeRoadAddressLabel
        ].forEach { addArrangedSubview($0) }
    }
    
}
