//
//  StoreInfoCell.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/10.
//

import UIKit
import SnapKit

class StoreInfoCell: UITableViewCell {
    
    // MARK: View
    lazy var storeNameLabel: UILabel = {
        let label = UILabel()
        label.tintColor = .black
        label.font = .systemFont(ofSize: 25.0, weight: .bold)
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var superStoreEvaluationStackView: SuperStoreEvaluationStackView = {
        let stackView = SuperStoreEvaluationStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.contentMode = .scaleAspectFit
        stackView.spacing = 10.0
        
        return stackView
    }()
    
    lazy var buttonStackView: ButtonStackView = {
        let stackView = ButtonStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.contentMode = .scaleAspectFit
        stackView.spacing = 30.0
        
        return stackView
    }()
    
    lazy var superStoreInfoStackView: SuperStoreInfoStackView = {
        let stackView = SuperStoreInfoStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10.0
        
        return stackView
    }()
    
    
    // MARK: init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension StoreInfoCell {
    
    func setupLayout() {
        [
            storeNameLabel,
            superStoreEvaluationStackView,
            buttonStackView,
            superStoreInfoStackView
        ].forEach { contentView.addSubview($0)}
        
        storeNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        
        superStoreEvaluationStackView.snp.makeConstraints { make in
            make.top.equalTo(storeNameLabel.snp.bottom).offset(10)
            make.centerX.equalTo(storeNameLabel)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(superStoreEvaluationStackView.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        
        superStoreInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(buttonStackView.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
}
