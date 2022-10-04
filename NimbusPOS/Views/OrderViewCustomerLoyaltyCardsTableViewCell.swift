//
//  OrderViewCustomerLoyaltyCardsTableViewCell.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-01.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit
import MaterialComponents

class OrderViewCustomerLoyaltyCardsTableViewCell: UITableViewCell {
    var loyaltyCardManagerDelegate: LoyaltyCardManagerDelegate?
    var nameAndDetailSection: UIView = UIView()
    var actionSection: UIView = UIView()
    var applyButton: MDCFloatingButton = MDCFloatingButton()
    
    var cardProgramNameField: UILabel = UILabel()
    var cardBalanceField: UILabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        cardProgramNameField.numberOfLines = 0
        cardProgramNameField.lineBreakMode = .byWordWrapping
        cardProgramNameField.font = MDCTypography.titleFont()
        
        cardBalanceField.textAlignment = .right
        cardBalanceField.font = MDCTypography.subheadFont()
        
        self.nameAndDetailSection.addSubview(cardProgramNameField)
        self.nameAndDetailSection.addSubview(cardBalanceField)
        
        applyButton.setImage(UIImage(named: "ic_done_white"), for: .selected)
        applyButton.setBackgroundColor(UIColor.green, for: .selected)
        applyButton.setTitle("Apply", for: .normal)
        applyButton.setTitleColor(UIColor.lightGray, for: .selected)
        applyButton.setTitleColor(UIColor.lightGray, for: .normal)
        applyButton.setTitle("", for: .selected)
        applyButton.setTitleFont(MDCTypography.captionFont(), for: .normal)
        applyButton.setTitleFont(MDCTypography.captionFont(), for: .selected)
        applyButton.setElevation(.raisedButtonResting, for: .normal)
        applyButton.backgroundColor = UIColor.white
        applyButton.addTarget(self, action: #selector(applyCard), for: .touchUpInside)
        
        self.actionSection.addSubview(applyButton)
        
        self.contentView.addSubview(nameAndDetailSection)
        self.contentView.addSubview(actionSection)
        
        self.contentView.autoresizesSubviews = true
        
        sizeSubviews()
        constrainSubviews()
    }
    
    func constrainSubviews(){
        let gaps: CGFloat = 10
        
        nameAndDetailSection.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: nameAndDetailSection, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: nameAndDetailSection, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: nameAndDetailSection, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: nameAndDetailSection, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.width, multiplier: 0.75, constant: 0).isActive = true
        
        actionSection.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: actionSection, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: nameAndDetailSection, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: actionSection, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: actionSection, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: actionSection, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        
        cardProgramNameField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: cardProgramNameField, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: nameAndDetailSection, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: gaps).isActive = true
        NSLayoutConstraint(item: cardProgramNameField, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: nameAndDetailSection, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cardProgramNameField, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: nameAndDetailSection, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cardProgramNameField, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: nameAndDetailSection, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        
        cardBalanceField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: cardBalanceField, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: nameAndDetailSection, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: gaps).isActive = true
        NSLayoutConstraint(item: cardBalanceField, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: nameAndDetailSection, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cardBalanceField, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: nameAndDetailSection, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cardBalanceField, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: nameAndDetailSection, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: applyButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: actionSection, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: applyButton, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: actionSection, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
    }
    
    func sizeSubviews(){
        nameAndDetailSection.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100))
        actionSection.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100))
        cardProgramNameField.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100))
        cardBalanceField.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100))
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var orderLoyaltyCard: nimbusOrderCreationFunctions.orderLoyaltyCards?{
        didSet {
            refreshLabels()
        }
    }
    
    func initCell(card: nimbusOrderCreationFunctions.orderLoyaltyCards){
        self.orderLoyaltyCard = card
    }
    
    func refreshLabels(){
        cardProgramNameField.text = orderLoyaltyCard?.card.programName()
        setBalanceFieldValue()
        setApplyButtonTitle()
        
        if orderLoyaltyCard?.card.expired == true {
            applyButton.isEnabled = false
        } else {
            applyButton.isEnabled = true
        }
    }
    
    func setBalanceFieldValue(){
        var balanceText = ""
        let programType: String = orderLoyaltyCard?.card.programType ?? ""
        
        switch  programType {
        case (NIMBUS.Library?.LoyaltyPrograms.Types.Quantity)!:
            balanceText = "Balance: " + "+" + String(orderLoyaltyCard?.card.remainingQuantity ?? 0)
        case (NIMBUS.Library?.LoyaltyPrograms.Types.Coupon)!:
            balanceText = "Discount: " + (orderLoyaltyCard?.card.creditPercent?.toString(asMoney: false, toDecimalPlaces: 0) ?? "0") + "%"
        case (NIMBUS.Library?.LoyaltyPrograms.Types.GiftCard)!:
            balanceText = "Balance: " + (orderLoyaltyCard?.card.remainingAmount?.toString(asMoney: true, toDecimalPlaces: 2) ?? "")
        case (NIMBUS.Library?.LoyaltyPrograms.Types.Tally)!:
            balanceText = "Tally: " + "x" + String(orderLoyaltyCard?.card.tally ?? 0)
        default:
            break
        }
        
        cardBalanceField.text = balanceText
    }
    
    func setApplyButtonTitle(){
        applyButton.isSelected = self.orderLoyaltyCard?.apply ?? false
    }
    
    func applyCard(){
        self.orderLoyaltyCard?.apply = !(self.orderLoyaltyCard?.apply ?? false)
        NIMBUS.OrderCreation?.setLoyaltyCardApplyStatus(cardTempId: (self.orderLoyaltyCard?.tempId)!, apply: (self.orderLoyaltyCard?.apply)!)
        setApplyButtonTitle()
    }
}
