//
//  StoreInfoCellDelegate.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/14.
//

import UIKit

protocol StoreInfoCellDelegate: AnyObject {
    
    func storeInfoCell(nameLabel: UILabel)
    func storeInfoCell(evaluationStackView: SuperStoreEvaluationStackView)
    func storeInfoCell(buttonStackView: ButtonStackView)
    func storeInfoCell(infoStackView: SuperStoreInfoStackView)
    
}
