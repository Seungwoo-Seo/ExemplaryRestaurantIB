//
//  BottomSheetDelegate.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/12/31.
//

import Foundation

protocol BottomSheetDelegate: AnyObject {
    
    func didTapHazyView(_ tapGesture: UITapGestureRecognizer)
    func didTapCancelButton(_ button: UIButton)
    func didTapTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    
}
