//
//  StoreContentCell.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2023/01/26.
//

import UIKit
import SnapKit

class StoreContentCell: UITableViewCell {
    
    lazy var showStoreReviewButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "리뷰 보기"
        config.buttonSize = .medium
        
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(didTapShowStoreReviewButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    
    // MARK: delegate
    weak var delegate: StoreContentCelllDelegate?
    
    
    // MARK: init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapShowStoreReviewButton(_ sender: UIButton) {
        delegate?.didTapShowStoreReviewButton(sender)
    }
    
}

private extension StoreContentCell {
    
    func setupLayout() {
        [showStoreReviewButton].forEach { contentView.addSubview($0) }
        
        showStoreReviewButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
}
