//
//  MyChangeCell2.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2023/01/04.
//

import UIKit
import SnapKit

class MyChangeCell2: UITableViewCell {
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        return stackView
    }()
    
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        button.addTarget(self, action: #selector(didTapLogoutButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var userDeleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("회원탈퇴", for: .normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        button.addTarget(self, action: #selector(didTapUserDeleteButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    weak var delegate: MyChangeCellDelegate?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapLogoutButton(_ sender: UIButton) {
        delegate?.didTapLogoutButton(sender)
    }
    
    @objc func didTapUserDeleteButton(_ sender: UIButton) {
        delegate?.didTapUserDeleteButton(sender)
    }
    
}

private extension MyChangeCell2 {
    
    func setupLayout() {
        [stackView].forEach { contentView.addSubview($0) }
        
        [
            logoutButton,
            userDeleteButton
        ].forEach { stackView.addArrangedSubview($0) }
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.trailing.bottom.equalToSuperview().inset(20)
        }
    }
    
}
