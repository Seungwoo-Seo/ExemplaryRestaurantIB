//
//  MyChangeTableView.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2023/01/04.
//

import UIKit

class MyChangeTableView: UITableView {
    
    let vm = MyChangeViewModel()
    
    // MARK: override
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        vm.touchesBegan(touches, with: event, tableView: self)
    }
    
}
