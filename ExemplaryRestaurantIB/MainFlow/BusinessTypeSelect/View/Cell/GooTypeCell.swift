//
//  GooTypeCell.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/24.
//

import UIKit
import SnapKit

class GooTypeCell: UITableViewCell {
    
    lazy var gooTypeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 17, weight: .regular)
        
        return label
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.gooTypeLabel.textColor = UIColor.black
        self.accessoryView = UIView()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

    }
    
}

private extension GooTypeCell {
    
    func setupLayout() {
        [gooTypeLabel].forEach { self.addSubview($0) }
        
        gooTypeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
        }
    }
    
}
