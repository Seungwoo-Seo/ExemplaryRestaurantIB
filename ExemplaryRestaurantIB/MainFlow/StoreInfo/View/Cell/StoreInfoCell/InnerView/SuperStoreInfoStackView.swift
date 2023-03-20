//
//  SuperStoreInfoStackView.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/13.
//

import UIKit
import SnapKit

class SuperStoreInfoStackView: UIStackView {
    
    // MARK: View
    lazy var storeInfoStackView0: StoreInfoStackView0 = {
        let stackView = StoreInfoStackView0(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fill
        stackView.spacing = 10.0
        
        return stackView
    }()

    lazy var storeInfoStackView1: StoreInfoStackView1 = {
        let stackView = StoreInfoStackView1(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fill
        stackView.spacing = 10.0
        
        return stackView
    }()

    lazy var storeInfoStackView2: StoreInfoStackView2 = {
        let stackView = StoreInfoStackView2(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fill
        stackView.spacing = 10.0
        
        return stackView
    }()

    lazy var storeInfoStackView3: StoreInfoStackView3 = {
        let stackView = StoreInfoStackView3(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fill
        stackView.spacing = 10.0
        
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

private extension SuperStoreInfoStackView {
    
    func setupLayout() {
        [
            storeInfoStackView0,
            storeInfoStackView1,
            storeInfoStackView2,
            storeInfoStackView3
        ].forEach { addArrangedSubview($0) }
        
        let mainMenuLabel = storeInfoStackView0.mainMenuLabel
        let selectDayLabel = storeInfoStackView1.selectDayLabel
        let addressLabel = storeInfoStackView2.addressLabel
        let roadAddressLabel = storeInfoStackView3.roadAddressLabel
        
        addressLabel.snp.makeConstraints { make in
            make.trailing.equalTo(roadAddressLabel.snp.trailing)
        }
        
        selectDayLabel.snp.makeConstraints { make in
            make.trailing.equalTo(roadAddressLabel.snp.trailing)
        }
        
        mainMenuLabel.snp.makeConstraints { make in
            make.trailing.equalTo(roadAddressLabel.snp.trailing)
        }
        
    }
    
}

