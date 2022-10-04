//
//  locationNameTileView.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-17.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

class LocationNameTile: IconAndLabelBlock {
    /**
     Convenience initializer for location name tile
     */
    convenience init(frame: CGRect, blockSize: blockSizes = blockSizes.large) {
        var locationIcon: UIImage = UIImage()
        var font: UIFont = UIFont()
        if blockSize == .small {
            locationIcon = UIImage(named: "ic_location_on_white_18pt") ?? UIImage()
            font = MDCTypography.subheadFont()
        } else if blockSize == .medium {
            locationIcon = UIImage(named: "ic_location_on_white_36pt") ?? UIImage()
            font = MDCTypography.titleFont()
        } else {
            locationIcon = UIImage(named: "ic_location_on_white_48pt") ?? UIImage()
            font = MDCTypography.display1Font()
        }
        
        self.init(frame: frame, iconImage: locationIcon, labelText: "", labelFont: font)
        
        updateName()
    }
    
    func updateName(){
        self.label.text = NIMBUS.Location?.getLocationName() ?? "?"
        
        if NIMBUS.Location?.getLocationName() == "" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.updateName()
            })
        }
    }
}
