//
//  StarSlider.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/10/12.
//

import UIKit

class StarSlider: UISlider {
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        let width = self.frame.size.width
        let tapPoint = touch.location(in: self)
        let fPercent = tapPoint.x / width
        let nNewValue = self.maximumValue * Float(fPercent)
        if nNewValue != self.value {
            self.value = nNewValue
        }
        
        print("터치")
        
        return true
    }
    
}
