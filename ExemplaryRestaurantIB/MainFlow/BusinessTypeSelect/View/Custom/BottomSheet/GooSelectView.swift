//
//  GooSelectView.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/23.
//

import UIKit
import SnapKit

class GooSelectView: UIView {
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "지역 선택"
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .bold)
        
        return label
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.register(GooTypeCell.self, forCellReuseIdentifier: "GooTypeCell")
        
        return tableView
    }()
    
    lazy var cancleButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBackground
        button.setTitle("닫기", for: .normal)
        button.setTitleColor(UIColor.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        return button
    }()
    

    
    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension GooSelectView {
    
    private func setupLayout() {
        [
            label,
            tableView,
            cancleButton
        ].forEach { addSubview($0) }
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.leading.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
        }
        
        cancleButton.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    
    
}


