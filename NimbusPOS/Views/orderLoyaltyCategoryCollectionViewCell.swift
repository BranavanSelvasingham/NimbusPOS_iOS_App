//
//  orderLoyaltyCategoryCollectionViewCell.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-28.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit
import MaterialComponents

class orderLoyaltyCategoryCollectionViewCell: UICollectionViewCell {
    var categoryNameLabel: UILabel = UILabel()
    var categoryKey: String?
    var categoryLabel: String? {
        didSet {
            categoryNameLabel.text = categoryLabel
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        categoryNameLabel.textAlignment = .center
        categoryNameLabel.font = MDCTypography.subheadFont()
        categoryNameLabel.textColor = UIColor.white
        self.addSubview(categoryNameLabel)
        
        self.layer.cornerRadius = 20
        
        self.setDefaultElevation()
        
        categoryNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: categoryNameLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: categoryNameLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: categoryNameLabel, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: categoryNameLabel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initCell(categoryKey: String, categoryLabel: String, color: UIColor){
        self.categoryKey = categoryKey
        self.categoryLabel = categoryLabel
        self.backgroundColor = color
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected
            {
                self.shadowLayer.elevation = .cardPickedUp
                self.shadowLayer.shadowColor = UIColor.cyan.cgColor
                NIMBUS.LoyaltyPrograms?.fetchLoyaltyProgramsForPurchase(type: categoryKey!)
            } else {
                setDefaultElevation()
                self.shadowLayer.shadowColor = UIColor.gray.cgColor
            }
        }
    }
    
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
