//
//  productCollectionCell.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-08.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

class ProductCollectionCell: UICollectionViewCell {
    var cellProduct: productSchema? {
        didSet {
            productCellNameLabel.text = cellProduct?.name
            if (cellProduct?.isGroupObject ?? false) {
                topRightIcon.image = UIImage(named: "ic_view_module_white")
                topRightIcon.isHidden = false
            } else if (cellProduct?.sizes?.count ?? 1) > 1 {
                topRightIcon.image = UIImage(named: "multiple_sizes_squares")
                topRightIcon.isHidden = false
            } else {
                topRightIcon.isHidden = true
            }
            
            
        }
    }
    
    var productCellNameLabel: UILabel = UILabel()
    var topRightIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        return view
    }()
    
    
    func initCell(product: productSchema){
        self.cellProduct = product
        
        self.backgroundColor = cellProduct?.getCategoryColor()
        self.layer.cornerRadius = 3
        setDefaultElevation()
        
        productCellNameLabel.textColor = UIColor.white
        productCellNameLabel.numberOfLines = 0
        productCellNameLabel.lineBreakMode = .byWordWrapping
        productCellNameLabel.textAlignment = .center
        
        self.addSubview(productCellNameLabel)
        self.addSubview(topRightIcon)

        NSLayoutConstraint(item: topRightIcon, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: topRightIcon, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        
        productCellNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: productCellNameLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 30).isActive = true
        NSLayoutConstraint(item: productCellNameLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: productCellNameLabel, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: productCellNameLabel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -30).isActive = true
        
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected
            {
                //
            } else {
                //
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
