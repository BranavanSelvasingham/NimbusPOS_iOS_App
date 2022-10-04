//
//  loyaltyCardsListTableViewCell.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-21.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit
import MaterialComponents

class LoyaltyCardsListTableViewCell: UITableViewCell {
    var loyaltyCard: LoyaltyCard?{
        didSet {
            refreshLabels()
        }
    }

    var loyaltyCardManagerDelegate: LoyaltyCardManagerDelegate?

    var nameAndDetailSection: UIView = UIView()
    var balanceSection: UIView = UIView()
    var actionSection: UIView = UIView()
    var editButton: MDCFloatingButton = MDCFloatingButton()
    
    var cardProgramNameField: UILabel = UILabel()
    var cardBoughtOnField: UILabel = UILabel()
    var cardBalanceField: UILabel = UILabel()
    
    var cardExpiredLabel: UILabel = {
        let label = UILabel()
        label.text = "EXPIRED"
        label.isHidden = true
        label.font = MDCTypography.titleFont()
        label.textColor = UIColor.red
        label.transform = CGAffineTransform.identity.rotated(by: CGFloat(-Double.pi/4))
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        cardProgramNameField.numberOfLines = 0
        cardProgramNameField.lineBreakMode = .byWordWrapping
        cardProgramNameField.font = MDCTypography.titleFont()

        cardBoughtOnField.numberOfLines = 0
        cardBoughtOnField.lineBreakMode = .byWordWrapping
        cardBoughtOnField.font = MDCTypography.subheadFont()
        
        cardBalanceField.textAlignment = .center
        cardBalanceField.font = MDCTypography.titleFont()
        
        self.nameAndDetailSection.addSubview(cardProgramNameField)
        self.nameAndDetailSection.addSubview(cardBoughtOnField)
        self.nameAndDetailSection.addSubview(cardExpiredLabel)
        self.balanceSection.addSubview(cardBalanceField)
        
        editButton.setImage(UIImage(named: "ic_edit"), for: .normal)
        editButton.setElevation(.raisedButtonResting, for: .normal)
        editButton.backgroundColor = UIColor.white
        editButton.addTarget(self, action: #selector(editCard), for: .touchUpInside)
        
        self.actionSection.addSubview(editButton)
        
        self.contentView.addSubview(nameAndDetailSection)
        self.contentView.addSubview(balanceSection)
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
        NSLayoutConstraint(item: nameAndDetailSection, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.width, multiplier: 0.6, constant: 0).isActive = true
        
        balanceSection.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: balanceSection, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: nameAndDetailSection, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: balanceSection, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: balanceSection, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: balanceSection, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.width, multiplier: 0.28, constant: 0).isActive = true

        actionSection.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: actionSection, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: balanceSection, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: actionSection, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: actionSection, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: actionSection, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        
        cardProgramNameField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: cardProgramNameField, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: nameAndDetailSection, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: gaps).isActive = true
        NSLayoutConstraint(item: cardProgramNameField, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: nameAndDetailSection, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cardProgramNameField, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: nameAndDetailSection, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cardProgramNameField, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: nameAndDetailSection, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        
        cardBoughtOnField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: cardBoughtOnField, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: nameAndDetailSection, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: gaps).isActive = true
        NSLayoutConstraint(item: cardBoughtOnField, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: nameAndDetailSection, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cardBoughtOnField, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: nameAndDetailSection, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cardBoughtOnField, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: nameAndDetailSection, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        
        cardBalanceField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: cardBalanceField, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: balanceSection, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cardBalanceField, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: balanceSection, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cardBalanceField, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: balanceSection, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cardBalanceField, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: balanceSection, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        
        editButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: editButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: actionSection, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: editButton, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: actionSection, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
        
        cardExpiredLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: cardExpiredLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: nameAndDetailSection, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cardExpiredLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: nameAndDetailSection, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
        
    }
    
    func sizeSubviews(){
        nameAndDetailSection.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100))
        balanceSection.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100))
        actionSection.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100))
    
        cardProgramNameField.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100))
        cardBoughtOnField.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100))
        
        cardBalanceField.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100))
        cardExpiredLabel.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 30))
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initCell(card: LoyaltyCard){
        self.loyaltyCard = card
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected == true {
            editButton.isEnabled = true
        } else {
            editButton.isEnabled = false
        }
    }

    func refreshLabels(){
        cardProgramNameField.text = loyaltyCard?.programName()
        cardBoughtOnField.text = "Bought on: " + DateFormatter.localizedString(from: loyaltyCard?.boughtOn as! Date, dateStyle: .short, timeStyle: .short)
        setBalanceFieldValue()
        
        if loyaltyCard?.expired == true {
            cardExpiredLabel.isHidden = false
        } else {
            cardExpiredLabel.isHidden = true
        }
    }
    
    func setBalanceFieldValue(){
        var balanceText = ""
        let programType: String = loyaltyCard?.programType ?? ""
        
        switch  programType {
            case (NIMBUS.Library?.LoyaltyPrograms.Types.Quantity)!:
                balanceText = "+" + String(loyaltyCard?.remainingQuantity ?? 0)
            case (NIMBUS.Library?.LoyaltyPrograms.Types.Coupon)!:
                balanceText = (loyaltyCard?.creditPercent.toString(asMoney: false, toDecimalPlaces: 0) ?? "0") + "%"
            case (NIMBUS.Library?.LoyaltyPrograms.Types.GiftCard)!:
                balanceText = loyaltyCard?.remainingAmount.toString(asMoney: true, toDecimalPlaces: 2) ?? ""
            case (NIMBUS.Library?.LoyaltyPrograms.Types.Tally)!:
                balanceText = "x" + String(loyaltyCard?.tally ?? 0)
            default:
                break
        }
        
        cardBalanceField.text = balanceText
    }
    
    func editCard(){
        if let card = loyaltyCard {
            loyaltyCardManagerDelegate?.openCard(card: card)
        }
    }
}
