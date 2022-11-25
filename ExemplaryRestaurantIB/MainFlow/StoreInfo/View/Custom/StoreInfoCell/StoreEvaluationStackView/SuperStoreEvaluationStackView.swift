//
//  SuperStoreEvaluationStackView.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/11.
//

import UIKit

class SuperStoreEvaluationStackView: UIStackView {
    
    // MARK: View
    lazy var storeEvaluationStackView0: StoreEvaluationStackView0 = {
        let stackView = StoreEvaluationStackView0(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.contentMode = .scaleAspectFit
        stackView.spacing = 0.0
        
        return stackView
    }()
    
    lazy var storeEvaluationStackView1: StoreEvaluationStackView1 = {
        let stackView = StoreEvaluationStackView1(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.contentMode = .scaleAspectFit
        stackView.spacing = 5.0
        
        return stackView
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

private extension SuperStoreEvaluationStackView {
    
    func setupLayout() {
        [
            storeEvaluationStackView0,
            storeEvaluationStackView1
        ].forEach { addArrangedSubview($0) }
    }
    
}


