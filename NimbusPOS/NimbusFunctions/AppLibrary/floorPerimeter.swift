//
//  floorPerimeter.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-04.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreGraphics

//@IBDesignable

class floorPerimeter: UIView {
    
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 100, height: 100))
        UIColor.blue.setFill()
        path.fill()
        
        let path2 = UIBezierPath(rect: CGRect(x: -100, y: -100, width: 100, height: 100))
        UIColor.blue.setFill()
        path2.fill()
    }
}

