//
//  MyChangeCell1.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2023/01/04.
//

import UIKit
import SnapKit

class MyChangeCell1: UITableViewCell {
    
    lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        return stackView
    }()
    
    lazy var emailStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 20
        
        return stackView
    }()
    
    lazy var nowPasswordStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 20
        
        return stackView
    }()
    
    lazy var newPasswordStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 20
        
        return stackView
    }()
    
    lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일"
        label.font = .systemFont(ofSize: 17.0, weight: .bold)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return label
    }()
    
    lazy var email: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14.0, weight: .bold)
        
        return label
    }()

    lazy var nowPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "현재 비밀번호"
        label.font = .systemFont(ofSize: 17.0, weight: .bold)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return label
    }()
    
    lazy var nowPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 14.0, weight: .regular)
        textField.isEnabled = false
        textField.delegate = self
        
        return textField
    }()
    
    lazy var newPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "신규 비밀번호"
        label.font = .systemFont(ofSize: 17.0, weight: .bold)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return label
    }()
    
    lazy var newPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "8-20자 이내"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 14.0, weight: .regular)
        textField.isEnabled = false
        textField.delegate = self
        
        return textField
    }()

    lazy var changeButton: UIButton = {
        let button = UIButton()
        let config = UIButton.Configuration.filled()
        let handler: UIButton.ConfigurationUpdateHandler = { button in
                switch button.state {
                case [.selected, .highlighted]:
                    button.configuration?.title = "취소"
                    button.configuration?.baseBackgroundColor = .darkGray
                    
                case [.normal, .highlighted]:
                    button.configuration?.title = "변경"
                    button.configuration?.baseBackgroundColor = .darkGray
                    
                case .selected:
                    button.configuration?.title = "취소"
                    button.configuration?.baseBackgroundColor = .systemGray3
                    
                default:
                    button.configuration?.title = "변경"
                    button.configuration?.baseBackgroundColor = .systemGray3
                }
        }
        button.configuration = config
        button.configurationUpdateHandler = handler
        button.addTarget(self, action: #selector(didTapChangeButton(_:)), for: .touchUpInside)
        
        return button
    }()
        
    
    let vm = MyChangeViewModel()
    
    
    // MARK: delgate
    weak var delegate: MyChangeCellDelegate?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
        vm.addObserver(nowPasswordTextField, newPasswordTextField)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func didTapChangeButton(_ sender: UIButton) {
        delegate?.didTapChangeButton(sender, nowPasswordTextField: nowPasswordTextField, newPasswordTextField: newPasswordTextField)
    }

}

extension MyChangeCell1: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldDidEndEditing(textField)
    }
    
}

private extension MyChangeCell1 {
    
    func setupLayout() {
        [containerStackView, changeButton].forEach { contentView.addSubview($0) }
        
        [
            emailStackView,
            nowPasswordStackView,
            newPasswordStackView
        ].forEach { containerStackView.addArrangedSubview($0) }
        
        [emailLabel, email].forEach { emailStackView.addArrangedSubview($0) }
        [nowPasswordLabel, nowPasswordTextField].forEach { nowPasswordStackView.addArrangedSubview($0) }
        [newPasswordLabel, newPasswordTextField].forEach { newPasswordStackView.addArrangedSubview($0) }
        
        
        containerStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.trailing.equalTo(nowPasswordLabel.snp.trailing)
        }
        
        nowPasswordLabel.snp.makeConstraints { make in
            make.trailing.equalTo(newPasswordLabel.snp.trailing)
        }
        
        changeButton.snp.makeConstraints { make in
            make.top.equalTo(containerStackView.snp.bottom).offset(10)
            make.trailing.equalTo(containerStackView.snp.trailing)
            make.leading.greaterThanOrEqualToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
        
    }
    
}
