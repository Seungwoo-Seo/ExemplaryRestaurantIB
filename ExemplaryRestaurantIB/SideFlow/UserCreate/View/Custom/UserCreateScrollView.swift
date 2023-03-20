//
//  UserCreateScrollView.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/03.
//

import UIKit

class UserCreateScrollView: UIScrollView {
    
    
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UITextField || view is UIButton {
            return true
        }
        
        return super.touchesShouldCancel(in: view)
    }
    
}
