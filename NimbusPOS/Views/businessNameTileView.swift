//
//  businessNameTileView.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-16.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

class BusinessNameTile: IconAndLabelBlock {
    /**
     Convenience initializer for business name tile
    */
    convenience init(frame: CGRect, blockSize: blockSizes = blockSizes.large, textColor: UIColor = UIColor.white) {
        var businessIcon: UIImage = UIImage()
        var font: UIFont = UIFont()
        if textColor == UIColor.white {
            if blockSize == .small {
                businessIcon = UIImage(named: "ic_business_white_18pt") ?? UIImage()
                font = MDCTypography.subheadFont()
            } else if blockSize == .medium {
                businessIcon = UIImage(named: "ic_business_white_36pt") ?? UIImage()
                font = MDCTypography.titleFont()
            } else {
                businessIcon = UIImage(named: "ic_business_white_48pt") ?? UIImage()
                font = MDCTypography.display1Font()
            }
        } else {
            if blockSize == .small {
                businessIcon = UIImage(named: "ic_business_18pt") ?? UIImage()
                font = MDCTypography.subheadFont()
            } else if blockSize == .medium {
                businessIcon = UIImage(named: "ic_business_36pt") ?? UIImage()
                font = MDCTypography.titleFont()
            } else {
                businessIcon = UIImage(named: "ic_business_48pt") ?? UIImage()
                font = MDCTypography.display1Font()
            }
        }
        
        self.init(frame: frame, iconImage: businessIcon, labelText: "?", labelFont: font, labelTextColor: textColor)
        
        updateName()
    }
    
    func updateName(){
        self.label.text = NIMBUS.Business?.getBusinessName() ?? "?"
        
        if NIMBUS.Business?.getBusinessName() == "" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.updateName()
            })
        }
    }
}
