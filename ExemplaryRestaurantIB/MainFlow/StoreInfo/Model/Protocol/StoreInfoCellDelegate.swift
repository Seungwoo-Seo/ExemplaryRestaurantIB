//
//  StoreInfoCellDelegate.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/26.
//

import Foundation

protocol StoreInfoCellDelegate: AnyObject {
    
    func setupUI_callButton(_ sender: UIButton)
    func setupUI_jjimButton(_ sender: UIButton)
    func setupUI_shareButton(_ sender: UIButton)
    
}
