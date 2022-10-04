//
//  AddSeatCollectionViewCell.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-13.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit
import MaterialComponents

class AddSeatCollectionViewCell: UICollectionViewCell {
    var addSeatLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSeatLabel.textColor = UIColor.white
        addSeatLabel.font = MDCTypography.subheadFont()
        addSeatLabel.textAlignment = .center
        addSeatLabel.text = "+Seat"
        
        self.contentView.layer.cornerRadius = 20
        self.contentView.backgroundColor = UIColor.lightGray
        self.contentView.addSubview(addSeatLabel)
        self.contentView.bringSubview(toFront: addSeatLabel)
        
        addSeatLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: addSeatLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: addSeatLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: addSeatLabel, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: addSeatLabel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
