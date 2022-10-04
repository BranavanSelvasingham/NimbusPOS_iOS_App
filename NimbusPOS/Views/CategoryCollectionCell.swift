//
//  categoryCollectionCell.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-10.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

class CategoryCollectionCell: UICollectionViewCell {

    var cellCategory: productCategorySchema? {
        didSet {
            categoryNameLabel.text = cellCategory?.name
        }
    }
    
    var categoryNameLabel: UILabel = UILabel()
    
    func initCell(category: productCategorySchema){
        
        categoryNameLabel.textAlignment = .center
        categoryNameLabel.font = MDCTypography.subheadFont()
        self.addSubview(categoryNameLabel)
        
        self.cellCategory = category
        self.layer.cornerRadius = 20
        self.backgroundColor = UIColor.color(fromHexString: (category.color ?? "bdbdbd"))
        
        categoryNameLabel.textColor = UIColor.white
        
        categoryNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: categoryNameLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: categoryNameLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: categoryNameLabel, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: categoryNameLabel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        
        self.setDefaultElevation()
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected
            {
                self.shadowLayer.elevation = .cardPickedUp
                self.shadowLayer.shadowColor = UIColor.cyan.cgColor
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

