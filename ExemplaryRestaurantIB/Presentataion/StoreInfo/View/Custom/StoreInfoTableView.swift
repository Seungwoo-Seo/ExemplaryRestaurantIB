//
//  StoreInfoTableView.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/11.
//

import UIKit

class StoreInfoTableView: UITableView {
    
    let vm = StoreInfoViewModel()
        
    override func touchesShouldCancel(in view: UIView) -> Bool {
        vm.touchesShouldCancel(in: view, superTouchesShouldCancel: super.touchesShouldCancel(in: view))
    }
    
}
