//
//  RadioButton.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/03.
//

import UIKit

class RadioButton: UIButton {
    
    var alternateButton: [RadioButton]?
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1.0
        self.layer.masksToBounds = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        unselectAlternateButtons()
        super.touchesBegan(touches, with: event)
    }
    
    func unselectAlternateButtons() {
        if alternateButton != nil {
            self.isSelected = true
            
            for aButton in alternateButton! {
                aButton.isSelected = false
            }
        } else {
            toggleButton()
        }
    }
    
    func toggleButton() {
        self.isSelected = !isSelected
    }
    
}
