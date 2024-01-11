//
//  PhotoCell.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/10/09.
//

import UIKit
import SnapKit

class PhotoCell: UICollectionViewCell {
    
    lazy var thumnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        
        return imageView
    }()
    
    lazy var thumnailImageDeleteButton: UIButton = {
        let button = UIButton(type: .close)
        let config = UIButton.Configuration.plain()
        button.configuration = config
        button.addTarget(self, action: #selector(didTapThumnailImageDeleteButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    
    weak var delegate: ReviewWriteCellDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapThumnailImageDeleteButton(_ sender: UIButton) {
        delegate?.didTapThumnailImageDeleteButton(sender)
    }
    
}

private extension PhotoCell {
    
    func setupLayout() {
        [thumnailImageView, thumnailImageDeleteButton].forEach { contentView.addSubview($0) }
        
        thumnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        thumnailImageDeleteButton.snp.makeConstraints { make in
            make.top.equalTo(thumnailImageView.snp.top)
            make.trailing.equalTo(thumnailImageView.snp.trailing)
        }
    }
    
}

