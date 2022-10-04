//
//  UIImageViewWithShadow.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-23.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class UIImageViewWithShadow: UIImageView {
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
