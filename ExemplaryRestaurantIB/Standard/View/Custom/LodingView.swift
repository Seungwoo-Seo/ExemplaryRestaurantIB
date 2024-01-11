//
//  LodingView.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/12/29.
//

import UIKit
import SnapKit

class LodingView: UIView {
        
    lazy var activityView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .large
        indicator.stopAnimating()
        
        return indicator
    }()
    

    let vm = NetworkManager.shared
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startLoding() {
        vm.startLoding(self, activityView: activityView)
    }
    
    func stopLoding() {
        vm.stopLoding(self, activityView: activityView)
    }
    
}

private extension LodingView {
        
    func setupLayout() {
        [activityView].forEach { self.addSubview($0) }
                
        activityView.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
        }
    
    }
    
}

