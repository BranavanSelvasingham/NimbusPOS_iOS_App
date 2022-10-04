//
//  expandedProductSizeCell.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-15.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

class ExpandedProductSizeCell: UICollectionViewCell {
    var productSizeLabel: UILabel = UILabel()

    var cellSize: productSize? {
        didSet {
            productSizeLabel.text = cellSize?.label
        }
    }
    
    func initCell(size: productSize, product: productSchema? ){
        self.cellSize = size
        
        self.backgroundColor = product?.getCategoryColor()
        self.layer.cornerRadius = 3
        productSizeLabel.textColor = UIColor.white
        productSizeLabel.textAlignment = .center
        
        self.addSubview(productSizeLabel)
        
        productSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: productSizeLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 30).isActive = true
        NSLayoutConstraint(item: productSizeLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: productSizeLabel, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: productSizeLabel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -30).isActive = true
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected
            {
                
            } else {
                
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
