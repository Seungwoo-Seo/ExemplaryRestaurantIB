//
//  HazyView.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/12/31.
//

import UIKit

class HazyView: UIView {
        
    // MARK: delegate
    weak var delegate: BottomSheetDelegate?
    
    
    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
     
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: action
    @objc func didTapHazyView(_ tapGesture: UITapGestureRecognizer) {
        delegate?.didTapHazyView(tapGesture)
    }
    
}

private extension HazyView {
    
    func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapHazyView(_:)))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    
}
