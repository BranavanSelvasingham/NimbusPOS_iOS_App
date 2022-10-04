//
//  SmartSwitch.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-15.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class SmartSwitch: UIView{
    var switchElement: UISwitch = {
        let switchElement = UISwitch()
        switchElement.translatesAutoresizingMaskIntoConstraints = false
        return switchElement
    }()
    
    var switchLabel: UILabel = { () -> UILabel in
        let label = UILabel()
        label.font = MDCTypography.titleFont()
        label.textAlignment = .right
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var switchImageLeft: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    var switchImageRight: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(switchLabel)
        self.addSubview(switchElement)
        self.addSubview(switchImageLeft)
        self.addSubview(switchImageRight)
        
        NSLayoutConstraint(item: switchImageLeft, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: switchImageLeft, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0).isActive = true
//        NSLayoutConstraint(item: switchImageLeft, attribute: .trailing, relatedBy: .equal, toItem: switchElement, attribute: .leading, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: switchImageLeft, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: switchLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: switchLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: switchLabel, attribute: .trailing, relatedBy: .equal, toItem: switchElement, attribute: .leading, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: switchLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: switchElement, attribute: .leading, relatedBy: .equal, toItem: switchImageLeft, attribute: .trailing, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: switchElement, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: switchElement, attribute: .trailing, relatedBy: .equal, toItem: switchImageRight, attribute: .leading, multiplier: 1, constant: -10).isActive = true
        
        NSLayoutConstraint(item: switchImageRight, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
//        NSLayoutConstraint(item: switchImageRight, attribute: .leading, relatedBy: .equal, toItem: switchElement, attribute: .trailing, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: switchImageRight, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: switchImageRight, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
