//
//  ButtonStackView.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/11.
//

import UIKit

class ButtonStackView: UIStackView {
    
    // MARK: View
    lazy var callButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.setTitle("전화", for: .normal)
        button.setImage(UIImage(systemName: "phone"), for: .normal)
        
        return button
    }()
    
    lazy var jjimButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.tintColor = .red
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.black, for: .selected)
        button.setTitle("찜", for: .normal)
        button.setTitle("짱", for: .selected)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        
        NotificationCenter.default.addObserver(self, selector: #selector(jjimButtonObserver(_:)), name: NSNotification.Name("jjimButtonIsSelected"), object: nil)
        
        return button
    }()
    
    @objc func jjimButtonObserver(_ notification: Notification) {
        guard let isSelected = notification.userInfo?["jjim"] as? Bool else {return}
        if isSelected {
            print("성공1")
            self.jjimButton.isSelected = isSelected
        } else {
            print("성공2")
            self.jjimButton.isSelected = isSelected
        }
    }
    
    lazy var shareButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.setTitle("공유", for: .normal)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        
        return button
    }()
    
    
    
    
    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Setup
private extension ButtonStackView {
    
    func setupLayout() {
        [
            callButton,
            jjimButton,
            shareButton
        ].forEach { addArrangedSubview($0) }
    }
    
}


    

    

