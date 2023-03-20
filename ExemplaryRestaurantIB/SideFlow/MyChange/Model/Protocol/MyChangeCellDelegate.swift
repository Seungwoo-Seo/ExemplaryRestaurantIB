//
//  MyChangeCellDelegate.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2023/01/04.
//

import Foundation

protocol MyChangeCellDelegate: AnyObject {
    
    func textFieldDidEndEditing(_ textField: UITextField)
    
    func didTapProfileImageButton(_ sender: UIButton)
    
    func didTapChangeButton(_ sender: UIButton,
                            nowPasswordTextField: UITextField,
                            newPasswordTextField: UITextField)
    
    func didTapLogoutButton(_ sender: UIButton)
    
    func didTapUserDeleteButton(_ sender: UIButton)
    
}
