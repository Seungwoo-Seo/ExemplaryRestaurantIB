//
//  Setup.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/10/21.
//

import Foundation

@objc protocol Setup {
    
    @objc optional func setupUI()
    @objc optional func setupLayout()
    @objc optional func setupGesture()
}
