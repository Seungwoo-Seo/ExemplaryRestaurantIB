//
//  StoreTableView.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/11.
//

import UIKit

class StoreTableView: UITableView {
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        
        if view.tag == 20090806 {
            return false
        } else if view is UIButton {
            return true
        }
        
        return super.touchesShouldCancel(in: view)
    }
    
}
