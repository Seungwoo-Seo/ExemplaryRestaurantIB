//
//  Alert.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/12/29.
//

import Foundation

struct Alert {
    
    static func confirmAlert(title: String?) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .cancel)
        alert.addAction(confirm)
        
        return alert
    }
    
    static func confirmAlert(title: String?, message: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .cancel)
        alert.addAction(confirm)
        
        return alert
    }
    
    static func confirmAlert(title: String?, back: @escaping () -> ()) -> UIAlertController {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .cancel) { _ in
            back()
        }
        
        alert.addAction(confirm)
        
        return alert
    }
    
}
