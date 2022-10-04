//
//  nimbusLoyaltyCardFunctions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-21.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class nimbusLoyaltyCardFunctions: NimbusBase{
    override init(master: NimbusFramework?){
        super.init(master: master)
    }
    
    let loyaltyCardOnServer = LoyaltyCardAPIs()
    
    func syncLoyaltyCardsServerDataToLocal(){
        loyaltyCardOnServer.getAllDocumentsFromServer()
    }
    
    func processServerChangeLog(log: serverChangeLog){
        loyaltyCardOnServer.processChangeLog(log: log)
    }
    
    func convertAllMOCardsToStructs(cardsMO: [LoyaltyCard] ) -> [loyaltyCardSchema] {
        var cards = [loyaltyCardSchema]()
        
        cardsMO.forEach { cardMO in
            cards.append(convertMOCardToStruct(cardMO: cardMO))
        }
        
        return cards
    }
    
    func convertMOCardToStruct(cardMO: LoyaltyCard) -> loyaltyCardSchema {
        return loyaltyCardSchema(withManagedObject: cardMO)
    }
    
    func fetchAllLoyaltyCards() -> [LoyaltyCard]{
        let fetchLoyaltyCards = getLoyaltyCards(withPredicate: nil)
        var sortedLoyaltyCards = fetchLoyaltyCards
        sortedLoyaltyCards = sortedLoyaltyCards.sorted(by: {$0.boughtOn?.compare($1.boughtOn as! Date) == ComparisonResult.orderedDescending})
        return sortedLoyaltyCards
    }
    
    func fetchAllCustomerLoyaltyCards(customer: customerSchema? = nil, customerMO: Customer? = nil) -> [LoyaltyCard]{
        var customerId: String = ""
        
        if let customer = customer {
            customerId = customer._id ?? ""
        } else if let customerMO = customerMO {
            customerId = customerMO.id ?? ""
        }

        let fetchPredicate = NSPredicate(format: "customerId = %@", customerId)
        let fetchLoyaltyCards = getLoyaltyCards(withPredicate: fetchPredicate)
        var sortedLoyaltyCards = fetchLoyaltyCards
        sortedLoyaltyCards = sortedLoyaltyCards.sorted(by: {$0.boughtOn?.compare($1.boughtOn as! Date) == ComparisonResult.orderedDescending})
        return sortedLoyaltyCards
    }
    
    func createNewLoyaltyCard(loyaltyCard: loyaltyCardSchema){
        loyaltyCard.saveToCoreData()
        loyaltyCardOnServer.uploadCard(card: loyaltyCard)
    }
    
    func deleteLoyaltyCard(loyaltyCard: LoyaltyCard){
        managedContext.delete(loyaltyCard)
    }
    
    func deleteLoyaltyCardById(cardId: String){
        if let card = getLoyaltyCard(byId: cardId){
            deleteLoyaltyCard(loyaltyCard: card)
        }
    }
    
    func getLoyaltyCard(byId cardId: String) -> LoyaltyCard? {
        let fetchPredicate = NSPredicate(format: "id = %@", cardId)
        let fetchLoyaltyCards = getLoyaltyCards(withPredicate: fetchPredicate)
        return fetchLoyaltyCards.first
    }
    
    func getLoyaltyCards(withPredicate fetchPredicate: NSPredicate? = nil) -> [LoyaltyCard] {
        var fetchLoyaltyCards = [LoyaltyCard]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LoyaltyCard")
        fetchRequest.returnsObjectsAsFaults = false
        
        if fetchPredicate != nil {
            fetchRequest.predicate = fetchPredicate
        }
        
        do {
            fetchLoyaltyCards = try managedContext.fetch(fetchRequest) as! [LoyaltyCard]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchLoyaltyCards
    }
    
    func updateQuantityLoyaltyCard(cardId: String, remainingQuantity: Int?, expired: Bool? ){
        if let card = getLoyaltyCard(byId: cardId){
            if let remainingQuantity = remainingQuantity {
                card.remainingQuantity = Int16(remainingQuantity)
                if remainingQuantity <= 0 {
                    card.expired = true
                }
            }
            
            if let expired = expired {
                card.expired = expired
            }
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func updateAmountLoyaltyCard(cardId: String, remainingAmount: Float?, expired: Bool?){
        if let card = getLoyaltyCard(byId: cardId){
            if let remainingAmount = remainingAmount {
                card.remainingAmount = remainingAmount
                if remainingAmount <= 0 {
                    card.expired = true
                }
            }
            
            if let expired = expired {
                card.expired = expired
            }
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func updatePercentageLoyaltyCard(cardId: String, expired: Bool?){
        if let card = getLoyaltyCard(byId: cardId){
            if let expired = expired {
                card.expired = expired
            }
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func updateTallyLoyaltyCard(cardId: String, tally: Int){
        if let card = getLoyaltyCard(byId: cardId){
            card.tally = Int16(tally)

            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func updateLoyaltyCardExpiry(cardId: String, expired: Bool){
        if let card = getLoyaltyCard(byId: cardId){
            card.expired = expired
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func isCardExpiredByDaysAndDate(card: loyaltyCardSchema) -> Bool {
        if let program = NIMBUS.LoyaltyPrograms?.getLoyaltyProgramAsStruct(byId: card.programId!) {
            let today: Date = Date()
            if let programExpiryDate = program.expiryDate {
                if today > programExpiryDate {
                    return true
                }
            }
            
            let daysSincePurchase = Calendar.current.dateComponents([.day], from: today, to: card.boughtOn!).day
            if let daysToExpiry = program.expiryDays {
                if daysSincePurchase! > Int(daysToExpiry) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func uploadCardMO(cardMO: LoyaltyCard) -> Bool {
        return loyaltyCardOnServer.uploadCardMO(cardMO: cardMO)
    }
    
    func deleteAllCards(){
        deleteAllRecords(entityName: LoyaltyCard.entity().managedObjectClassName )
    }
    
    func getCustomerCardByProgramId(customerId: String, programId: String) -> LoyaltyCard? {
        let customerPredicate = NSPredicate(format: "customerId = %@", customerId)
        let programIdPredicate = NSPredicate(format: "programId = %@", programId)
        let fetchPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [customerPredicate, programIdPredicate])
        
        let fetchLoyaltyCards = getLoyaltyCards(withPredicate: fetchPredicate)
        
        return fetchLoyaltyCards.first
    }
    
    func getCard(cardId: String? = nil, customerId: String? = nil, programId: String? = nil) -> LoyaltyCard? {
        if let cardId = cardId {
            return getLoyaltyCard(byId: cardId)
        }
        
        if let customerId = customerId, let programId = programId {
            return getCustomerCardByProgramId(customerId: customerId, programId: programId)
        }
        
        return nil
    }
    
    func incrementQuantityCard(cardId: String? = nil, customerId: String? = nil, programId: String? = nil, incrementQuantity: Int){
        if let card = getCard(cardId: cardId, customerId: customerId, programId: programId) {
            card.remainingQuantity += incrementQuantity
        }
    }
    
    func incrementAmountCard(cardId: String? = nil, customerId: String? = nil, programId: String? = nil, incrementAmount: Float){
        if let card = getCard(cardId: cardId, customerId: customerId, programId: programId) {
            card.remainingAmount += incrementAmount
        }
    }
    
    func cancelOrderLoyaltyItems(order: Order){
        let orderAsStruct: orderSchema = orderSchema(withManagedObject: order)
        let allOrderItems = orderAsStruct.items ?? []
        
        var giftCardRedeem = orderAsStruct.payment?.giftCards ?? []
        var quantityCardRedeem = orderAsStruct.payment?.quantityCards ?? []
        var percentageCardRedeem: [String] = []
 
        let customerId = orderAsStruct.customerId ?? " "
        
        if let customer = NIMBUS.Customers?.getCustomerById(id: customerId) {
            allOrderItems.forEach{item in
                if let loyaltyProgramObj = NIMBUS.LoyaltyPrograms?.getLoyaltyProgram(byId: item.product?._id ?? " "){
                    let programType = _LoyaltyProgramTypes(rawValue: loyaltyProgramObj.programType ?? "")
                    if programType == _LoyaltyProgramTypes.Quantity{
                        quantityCardRedeem.append(quantityCardPayment(cardId: nil, programId: loyaltyProgramObj.id, redeemedQuantity: -Int(loyaltyProgramObj.programQuantity)))
                    } else if programType == _LoyaltyProgramTypes.GiftCard {
                        giftCardRedeem.append(giftCardPayment(cardId: nil, programId: loyaltyProgramObj.id, redeemedAmount: -loyaltyProgramObj.programCreditAmount))
                    } else if programType == _LoyaltyProgramTypes.Coupon {
                        percentageCardRedeem.append(loyaltyProgramObj.id ?? " ")
                    }
                }
            }
            
            giftCardRedeem.forEach{giftCard in
                incrementAmountCard(cardId: giftCard.cardId, customerId: customerId, programId: giftCard.programId, incrementAmount: giftCard.redeemedAmount ?? 0)
            }
            
            quantityCardRedeem.forEach{quantityCard in
                incrementQuantityCard(cardId: quantityCard.cardId, customerId: customerId, programId: quantityCard.programId, incrementQuantity: quantityCard.redeemedQuantity ?? 0)
            }
            
            percentageCardRedeem.forEach{percentProgramId in
                if let card = getCard(cardId: nil, customerId: customerId, programId: percentProgramId){
                    updateLoyaltyCardExpiry(cardId: card.id ?? " ", expired: false)
                }
            }
        }
    }
}
