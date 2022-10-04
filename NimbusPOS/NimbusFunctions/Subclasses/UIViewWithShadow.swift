//
//  UIViewWithShadow.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-21.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class UIViewWithShadow: UIView {
    override class var layerClass: AnyClass {
        return MDCShadowLayer.self
    }
    
    var shadowLayer: MDCShadowLayer {
        return self.layer as! MDCShadowLayer
    }
    
    func setDefaultElevation() {
        self.shadowLayer.elevation = .cardResting
    }
}
