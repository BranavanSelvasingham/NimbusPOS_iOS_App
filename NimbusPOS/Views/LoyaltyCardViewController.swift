//
//  LoyaltyCardViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-01.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class LoyaltyCardViewController: UIViewController{
    var card: LoyaltyCard?{
        didSet{
            refreshFields()
        }
    }
    
    var cardProgramNameField: UILabel = UILabel()
    var cardBoughtOnField: UILabel = UILabel()
    var cardBalanceField: SmartTextFieldUpdateView = SmartTextFieldUpdateView ()
    var cardDeactivateButton: MDCRaisedButton = MDCRaisedButton()
    var cardReactivateButton: MDCRaisedButton = MDCRaisedButton()
    
    var snackbarMessage = MDCSnackbarMessage()
    
    override func viewDidLoad() {
        
        cardProgramNameField.font = MDCTypography.titleFont()
        
        cardBoughtOnField.font = MDCTypography.subheadFont()
        
        cardBalanceField.textField.font = MDCTypography.display1Font()
        cardBalanceField.textField.textAlignment = .center
        
        cardBalanceField.saveButton.addTarget(self, action: #selector(updateCardBalance), for: .touchUpInside)
        
        cardDeactivateButton.backgroundColor = UIColor.lightGray
        cardDeactivateButton.setTitle("De-Activate Card", for: .normal)
        cardDeactivateButton.setTitleColor(UIColor.red, for: .normal)
        cardDeactivateButton.setTitleFont(MDCTypography.body2Font(), for: .normal)
        cardDeactivateButton.addTarget(self, action: #selector(deactivateCard), for: .touchUpInside)
        
        cardReactivateButton.backgroundColor = UIColor.lightGray
        cardReactivateButton.setTitle("Activate Card", for: .normal)
        cardReactivateButton.setTitleColor(UIColor.green, for: .normal)
        cardReactivateButton.setTitleFont(MDCTypography.body2Font(), for: .normal)
        cardReactivateButton.addTarget(self, action: #selector(activateCard), for: .touchUpInside)
        
        self.view.addSubview(cardProgramNameField)
        self.view.addSubview(cardBoughtOnField)
        self.view.addSubview(cardBalanceField)
        self.view.addSubview(cardReactivateButton)
        self.view.addSubview(cardDeactivateButton)
    }
    
    override func viewWillLayoutSubviews() {
        let gap: CGFloat = 10
        
        cardProgramNameField.frame = CGRect(origin: CGPoint(x: gap, y: gap), size: CGSize(width: self.view.frame.width - 2 * gap, height: 50))
        
        cardBalanceField.frame.size = CGSize(width: self.view.frame.width*2/3, height: 50)
        cardBalanceField.frame.origin = CGPoint(x: (self.view.frame.width - cardBalanceField.frame.width)/2, y: cardProgramNameField.frame.maxY + gap)
        
        cardBoughtOnField.frame = CGRect(origin: CGPoint(x: gap, y: cardBalanceField.frame.maxY + 3 * gap), size: CGSize(width: self.view.frame.width - 2 * gap, height: 30))
        
        cardReactivateButton.frame = CGRect(origin: CGPoint(x: gap, y: self.view.frame.height - 30 - gap), size: CGSize(width: self.view.frame.width - 2 * gap, height: 30))
        
        cardDeactivateButton.frame = cardReactivateButton.frame
    }
    
    func refreshCard(){
        self.card = NIMBUS.LoyaltyCards?.getLoyaltyCard(byId: card?.id ?? " ")
    }
    
    func refreshFields(){
        cardProgramNameField.text = card?.programName()
        cardBoughtOnField.text = "Bought on: " + DateFormatter.localizedString(from: card?.boughtOn as! Date, dateStyle: .short, timeStyle: .short)
        setBalanceFieldValue()
        
        if card?.expired == true {
            cardReactivateButton.isHidden = false
            cardDeactivateButton.isHidden = true
        } else {
            cardReactivateButton.isHidden = true
            cardDeactivateButton.isHidden = false
        }
    }
    
    func setBalanceFieldValue(){
        var balanceText = ""
        let programType: String = card?.programType ?? ""
        
        switch  programType {
        case (NIMBUS.Library?.LoyaltyPrograms.Types.Quantity)!:
            balanceText = "+" + String(card?.remainingQuantity ?? 0)
        case (NIMBUS.Library?.LoyaltyPrograms.Types.Coupon)!:
            balanceText = (card?.creditPercent.toString(asMoney: false, toDecimalPlaces: 0) ?? "0") + "%"
            cardBalanceField.textField.isEnabled = false
        case (NIMBUS.Library?.LoyaltyPrograms.Types.GiftCard)!:
            balanceText = card?.remainingAmount.toString(asMoney: true, toDecimalPlaces: 2) ?? ""
        case (NIMBUS.Library?.LoyaltyPrograms.Types.Tally)!:
            balanceText = "x" + String(card?.tally ?? 0)
        default:
            break
        }
        
        cardBalanceField.text = balanceText
    }
    
    func updateCardBalance(){
        let balanceText = cardBalanceField.text
        let balance = balanceText?.digitsOnly()
        
        let programType: String = card?.programType ?? ""
        
        switch programType {
        case (NIMBUS.Library?.LoyaltyPrograms.Types.Quantity)!:
            if let card = card {
                var updatedQuantity: Int? = Int(balance ?? "0")
                var expired: Bool = false
                if (updatedQuantity ?? 0) <= 0 {
                    updatedQuantity = 0
                    expired = true
                }
                NIMBUS.LoyaltyCards?.updateQuantityLoyaltyCard(cardId: card.id ?? " ", remainingQuantity: updatedQuantity, expired: expired)
            }
        case (NIMBUS.Library?.LoyaltyPrograms.Types.Coupon)!:
            break
        case (NIMBUS.Library?.LoyaltyPrograms.Types.GiftCard)!:
            if let card = card {
                var updatedAmount: Float? = Float(balance ?? "0")
                var expired: Bool = false
                if (updatedAmount ?? 0) <= 0 {
                    updatedAmount = 0
                    expired = true
                }
                NIMBUS.LoyaltyCards?.updateAmountLoyaltyCard(cardId: card.id ?? " ", remainingAmount: updatedAmount, expired: expired)
            }
        case (NIMBUS.Library?.LoyaltyPrograms.Types.Tally)!:
            if let card = card {
                var updatedTally: Int = Int(balance ?? "0") ?? 0
                if updatedTally < 0 {
                    updatedTally = 0
                }
                NIMBUS.LoyaltyCards?.updateTallyLoyaltyCard(cardId: card.id ?? " ", tally: updatedTally)
            }
        default:
            break
        }
        refreshCard()
    }
    
    func activateCard(){
        let balanceText = cardBalanceField.text
        let balance = balanceText?.digitsOnly()
        
        let programType: String = card?.programType ?? ""
        let active : Bool = false
        
        switch programType {
        case (NIMBUS.Library?.LoyaltyPrograms.Types.Quantity)!:
            if let card = card {
                let updatedQuantity: Int? = Int(balance ?? "0")
                let expired: Bool = false
                if (updatedQuantity ?? 0) <= 0 {
                    snackbarMessage.text = "Enter a valid balance to activate the card"
                    MDCSnackbarManager.show(snackbarMessage)
                } else {
                    NIMBUS.LoyaltyCards?.updateQuantityLoyaltyCard(cardId: card.id ?? " ", remainingQuantity: updatedQuantity, expired: active)
                }
            }
        case (NIMBUS.Library?.LoyaltyPrograms.Types.Coupon)!:
            NIMBUS.LoyaltyCards?.updateLoyaltyCardExpiry(cardId: card?.id ?? " ", expired: active)
        case (NIMBUS.Library?.LoyaltyPrograms.Types.GiftCard)!:
            if let card = card {
                let updatedAmount: Float? = Float(balance ?? "0")
                let expired: Bool = false
                if (updatedAmount ?? 0) <= 0 {
                    snackbarMessage.text = "Enter a valid balance to activate the card"
                    MDCSnackbarManager.show(snackbarMessage)
                } else {
                    NIMBUS.LoyaltyCards?.updateAmountLoyaltyCard(cardId: card.id ?? " ", remainingAmount: updatedAmount, expired: active)
                }
            }
        case (NIMBUS.Library?.LoyaltyPrograms.Types.Tally)!:
            break
        default:
            break
        }
        refreshCard()
    }
    
    func deactivateCard(){
        NIMBUS.LoyaltyCards?.updateLoyaltyCardExpiry(cardId: card?.id ?? " ", expired: true)
        refreshCard()
    }
}
