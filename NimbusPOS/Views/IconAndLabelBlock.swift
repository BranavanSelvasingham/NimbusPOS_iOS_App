//
//  IconAndLabelBlock.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-06-06.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class IconAndLabelBlock: UIView {
    enum blockSizes {
        case small
        case medium
        case large
    }
    
    let icon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /**
     Convenience initializer for block
    */
    convenience init(frame: CGRect, iconImage: UIImage, labelText: String, labelFont: UIFont = MDCTypography.titleFont(), labelTextAlignment: NSTextAlignment = .center, labelTextColor: UIColor = UIColor.white) {
        self.init(frame: frame)
        
        icon.image = iconImage
        label.text = labelText
        label.font = labelFont
        label.textAlignment = labelTextAlignment
        label.textColor = labelTextColor
        
        self.addSubview(icon)
        self.addSubview(label)
        
        NSLayoutConstraint(item: icon, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: icon, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: icon, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50).isActive = true
        
        NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: icon, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

