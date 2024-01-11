//
//  StoreInfoCell.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/10.
//

import UIKit
import SnapKit
import Cosmos

class StoreInfoCell: UITableViewCell {
    
    // MARK: View
    lazy var storeNameLabel: UILabel = {            // 가게 이름
        let label = UILabel()
        label.tintColor = .black
        label.font = .systemFont(ofSize: 25.0, weight: .bold)
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var cosmosStackView: UIStackView = {       // comsmosView, reviewCountLabel 스택 뷰
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.contentMode = .scaleAspectFit
        stackView.spacing = 10.0
        
        return stackView
    }()
    
    lazy var cosmosView: CosmosView = {             // 별점, 별점 평균
        let view = CosmosView()
        view.settings.updateOnTouch = false
        view.settings.fillMode = .precise
        view.settings.starSize = 25.0
        view.settings.filledColor = .yellow
        view.settings.filledBorderColor = .black
        view.settings.emptyBorderColor = .black
        view.settings.totalStars = 5
        view.settings.textMargin = 10.0
        view.settings.textColor = .black
        view.settings.textFont = .systemFont(ofSize: 17.0, weight: .bold)
        
        return view
    }()
    
    lazy var reviewCountLabel: UILabel = {          // 리뷰 갯수
        let label = UILabel()
        label.tintColor = .black
        label.font = .systemFont(ofSize: 17.0, weight: .bold)
        label.textAlignment = .center
        
        return label
    }()
    
    
    lazy var buttonStackView: UIStackView = {       // 버튼 스택 뷰
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.contentMode = .scaleAspectFit
        stackView.spacing = 30.0
        
        return stackView
    }()

    lazy var callButton: UIButton = {               // 전화 버튼
        let button = UIButton(configuration: .plain())
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.setTitle("전화", for: .normal)
        button.setImage(UIImage(systemName: "phone"), for: .normal)
        button.addTarget(self, action: #selector(didTapCallButton(_:)), for: .touchUpInside)
        
        return button
    }()
        
    lazy var jjimButton: UIButton = {
        let button = UIButton()
        let config = UIButton.Configuration.plain()
        let handler: UIButton.ConfigurationUpdateHandler = { button in
            switch button.state {
            case [.selected, .highlighted]:
                button.configuration?.image = UIImage(systemName: "heart.fill")
                button.configuration?.baseForegroundColor = .red
                button.configuration?.baseBackgroundColor = .clear
                
            case [.normal, .highlighted]:
                button.configuration?.image = UIImage(systemName: "heart")
                button.configuration?.baseForegroundColor = .red
                
            case .selected:
                button.configuration?.image = UIImage(systemName: "heart.fill")
                button.configuration?.baseForegroundColor = .red
                button.configuration?.baseBackgroundColor = .clear
                
            default:
                button.configuration?.image = UIImage(systemName: "heart")
                button.configuration?.baseForegroundColor = .red
            }
        }
        button.configuration = config
        button.configurationUpdateHandler = handler
        button.addTarget(self, action: #selector(didTapJjimButton(_:)), for: .touchUpInside)
        
        return button
    }()

    lazy var shareButton: UIButton = {              // 공유 버튼
        let button = UIButton(configuration: .plain())
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.setTitle("공유", for: .normal)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.addTarget(self, action: #selector(didTapShareButton(_:)), for: .touchUpInside)
        
        return button
    }()

    
    lazy var superStoreInfoStackView: SuperStoreInfoStackView = {   // 가게 정보 스택 뷰
        let stackView = SuperStoreInfoStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10.0
        
        return stackView
    }()
    
    
    // MARK: ViewModel
    let vm = StoreInfoViewModel()
    
    
    // MARK: delegate
    weak var delegate: StoreInfoCellDelegate?
    
    
    // MARK: init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: actions
    @objc func didTapCallButton(_ sender: UIButton) {
        delegate?.setupUI_callButton(sender)
    }
    
    @objc func didTapJjimButton(_ sender: UIButton) {
        delegate?.setupUI_jjimButton(sender)
    }
    
    @objc func didTapShareButton(_ sender: UIButton) {
        delegate?.setupUI_shareButton(sender)
    }
}

private extension StoreInfoCell {
    
    func setupLayout() {
        [
            cosmosView,
            reviewCountLabel
        ].forEach { cosmosStackView.addArrangedSubview($0) }
        
        [
            callButton,
            jjimButton,
            shareButton
        ].forEach { buttonStackView.addArrangedSubview($0) }
        
        [
            storeNameLabel,
            cosmosStackView,
            buttonStackView,
            superStoreInfoStackView
        ].forEach { contentView.addSubview($0)}
        
        storeNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        
        cosmosStackView.snp.makeConstraints { make in
            make.top.equalTo(storeNameLabel.snp.bottom).offset(20)
            make.centerX.equalTo(storeNameLabel.snp.centerX)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(cosmosStackView.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        
        superStoreInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(buttonStackView.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
}
