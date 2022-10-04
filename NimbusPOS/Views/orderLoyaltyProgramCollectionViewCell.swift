//
//  orderLoyaltyProgramCollectionViewCell.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-28.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit
import MaterialComponents

class orderLoyaltyProgramCollectionViewCell: UICollectionViewCell {
    var programNameLabel: UILabel = UILabel()
    var programPriceLabel: UILabel = UILabel()
    var loyaltyProgram: loyaltyProgramSchema? {
        didSet {
            programNameLabel.text = loyaltyProgram?.name
            programPriceLabel.text = loyaltyProgram?.price?.toString(asMoney: true, toDecimalPlaces: 2)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        programNameLabel.numberOfLines = 0
        programNameLabel.lineBreakMode = .byWordWrapping
        programNameLabel.font = MDCTypography.titleFont()
        programNameLabel.textColor = UIColor.white
        
        programPriceLabel.font = MDCTypography.titleFont()
        programPriceLabel.textColor = UIColor.white
        programPriceLabel.textAlignment = .right
        
        self.layer.cornerRadius = 3
        
        setDefaultElevation()
        
        self.addSubview(programNameLabel)
        self.addSubview(programPriceLabel)
        
        programNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: programNameLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: programNameLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: programNameLabel, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: programNameLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: 0.7, constant: 0).isActive = true
        
        programPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: programPriceLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: programPriceLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: programNameLabel, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: programPriceLabel, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: programPriceLabel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initCell(program: loyaltyProgramSchema){
        self.loyaltyProgram = program
        self.backgroundColor = program.getProgramColor()
//        self.layer.borderColor = program.getProgramColor().cgColor
//        self.layer.borderWidth = 5
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                NIMBUS.OrderCreation?.addLoyaltyProgramPurchase(loyaltyProgram: loyaltyProgram!, quantity: 1)
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
