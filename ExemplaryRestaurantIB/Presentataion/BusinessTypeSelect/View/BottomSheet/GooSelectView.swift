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
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBackground
        button.setTitle("닫기", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.addTarget(self, action: #selector(didTapCancleButton(_:)), for: .touchUpInside)
        return button
    }()


    var nowGooType: (gooName: String, gooCode: String?) =
    ("서울전체", nil)
    // 해당 행정구명과 매칭해 줄 행정구 별 코드
    var gooTypeList: [(gooName: String, gooCode: String?)]?
        
    // MARK: delegate
    weak var delegate: BottomSheetDelegate?
    
    
    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: action
    @objc func didTapCancleButton(_ button: UIButton) {
        delegate?.didTapCancelButton(button)
    }
    
}

extension GooSelectView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gooTypeList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GooTypeCell", for: indexPath) as? GooTypeCell,
              let gooTypeList = gooTypeList else {return UITableViewCell()}

        cell.gooTypeLabel.text = gooTypeList[indexPath.row].gooName

        if cell.gooTypeLabel.text == nowGooType.gooName {
            cell.gooTypeLabel.textColor = .systemBlue
            let image = UIImage(systemName: "checkmark")
            let checkmark  = UIImageView(frame:CGRect(x:0, y:0, width:(image?.size.width)!, height:(image?.size.height)!));
            checkmark.image = image
            checkmark.tintColor = UIColor.systemBlue

            cell.accessoryView = checkmark
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didTapTableView(tableView, didSelectRowAt: indexPath)
    }
    
}

private extension GooSelectView {
    
    func setupLayout() {
        [
            label,
            tableView,
            cancelButton
        ].forEach { addSubview($0) }
                
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
}


