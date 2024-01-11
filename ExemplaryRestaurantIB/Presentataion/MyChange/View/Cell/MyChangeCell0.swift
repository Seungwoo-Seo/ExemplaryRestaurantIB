//
//  MyChangeCell0.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2023/01/04.
//

import UIKit
import SnapKit

class MyChangeCell0: UITableViewCell {
    
    lazy var profileImageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "profile2"), for: .normal)
        button.addTarget(self, action: #selector(didTapProfileImageButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var userNameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 14.0, weight: .regular)
        textField.delegate = self
        
        return textField
    }()
    
    
    // MARK: ViewModel
    let vm = MyChangeViewModel()
    
    
    // MARK: delegate
    weak var delegate: MyChangeCellDelegate?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
        vm.addObserver(userNameTextField)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func didTapProfileImageButton(_ sender: UIButton) {
        delegate?.didTapProfileImageButton(sender)
    }
    
}

extension MyChangeCell0: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldDidEndEditing(textField)
    }
    
}

private extension MyChangeCell0 {
    
    func setupLayout() {
        [profileImageButton, userNameTextField].forEach { contentView.addSubview($0) }
        
        profileImageButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }
        
        userNameTextField.snp.makeConstraints { make in
            make.top.equalTo(profileImageButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(70)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
}
