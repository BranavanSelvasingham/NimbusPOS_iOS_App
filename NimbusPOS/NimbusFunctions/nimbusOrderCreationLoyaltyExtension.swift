//
//  nimbusOrderCreationLoyaltyExtension.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-14.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit

extension nimbusOrderCreationFunctions {
    struct orderLoyaltyCards {
        let tempId: String = UUID().uuidString
        var card: loyaltyCardSchema
        var apply: Bool
        let prePurchase: Bool
        
        init(card: loyaltyCardSchema, apply: Bool, prePurchase: Bool = false) {
            self.card = card
            self.apply = apply
            self.prePurchase = prePurchase
        }
    }
    
    struct loyaltyQuantityCreditBuckets {
        let orderLoyaltyCardTempId: String
        let programId: String
        var remainingQuantity: Int
        let productSet: [programProduct]
        let prePurchase: Bool
    }
    
    struct loyaltyAmountCreditBuckets {
        let orderLoyaltyCardTempId: String
        let programId: String
        var remainingAmount: Float
        let prePurchase: Bool
    }
    
    struct loyaltyPercentageCreditBuckets {
        let orderLoyaltyCardTempId: String
        let programId: String
        var creditPercent: Float
        let appliesTo: String
        let productSet: [programProduct]
        let prePurchase: Bool
    }
    
    struct loyaltyTallyBuckets {
        let orderLoyaltyCardTempId: String
        let programId: String
        var priorTally: Int
        var newTally: Int
        let tallyThreshold: Int
        let productSet: [programProduct]
    }
}

extension nimbusOrderCreationFunctions {
    func getExistingCustomerLoyaltyCards() {
        getCustomerActiveCards()
        
        let existingCards = self.customerLoyaltyCards.map{ card in
            return orderLoyaltyCards(card: card, apply: false)
        }
        
        if !existingCards.isEmpty {
            self.activeCustomerLoyaltyCards = existingCards
        }
    }

    func updateExpiryStatusForExpiredCards() {
        let allCardsMO = NIMBUS.LoyaltyCards?.fetchAllCustomerLoyaltyCards(customerMO: NIMBUS.OrderCreation?.customer) ?? []
        let allCards = NIMBUS.LoyaltyCards?.convertAllMOCardsToStructs(cardsMO: allCardsMO) ?? []
        allCards.forEach{card in
            if let isExpired = NIMBUS.LoyaltyCards?.isCardExpiredByDaysAndDate(card: card){
                if card.expired == false && isExpired == true {
                    NIMBUS.LoyaltyCards?.updateLoyaltyCardExpiry(cardId: card._id!, expired: isExpired)
                }
            }
        }
    }
    
    func getCustomerActiveCards(){
        updateExpiryStatusForExpiredCards()
        let allCardsMO = NIMBUS.LoyaltyCards?.fetchAllCustomerLoyaltyCards(customerMO: NIMBUS.OrderCreation?.customer) ?? []
        let allCards = NIMBUS.LoyaltyCards?.convertAllMOCardsToStructs(cardsMO: allCardsMO) ?? []
        self.customerLoyaltyCards = allCards
        self.customerLoyaltyCards = self.customerLoyaltyCards.filter({$0.expired != true})
    }
    
    func clearCustomerInfo(){
        self.customer = nil
        
        self.activeCustomerLoyaltyCards.removeAll()
        self.activeQuantityLoyalty.removeAll()
        self.activeAmountLoyalty.removeAll()
        self.activePercentageLoyalty.removeAll()
        self.activeTallyCards.removeAll()
        
//        self.prePurchaseLoyaltyCards.removeAll()
        
        deleteAllExistingRedeemItems()
        
        self.paymentDueAmount = 0.00
        
        self.emailReceiptFlag = false
        
        self.orderPayment.cashGiven = nil
    }
    
    func deleteAllExistingRedeemItems() {
        self.orderItems = self.orderItems.filter({!(isThisLoyaltyRedeemItem(item: $0))})
    }
    
    func isThisRedeemItem(item: orderItem) -> Bool {
        return item.isRedeemItem == true
    }
    
    func isThisManualRedeemItem(item: orderItem) -> Bool {
        return item.isManualRedeem == true
    }
    
    func isThisLoyaltyRedeemItem (item: orderItem) -> Bool{
        return isThisRedeemItem(item: item) && !isThisManualRedeemItem(item: item)
    }
    
    func getAllItemKeys() -> [String] {
        let allItemKeys = [String]()
        
        return allItemKeys
    }
    
    func reApplyLoyaltyPrograms(){
        deleteAllExistingRedeemItems()
    
        self.activeQuantityLoyalty.removeAll()
        self.activeAmountLoyalty.removeAll()
        self.activePercentageLoyalty.removeAll()
        self.activeTallyCards.removeAll()
    
        self.paymentDueAmount = 0.00
    
        getLoyaltyPrograms()
    }
    
    func setActiveCustomerLoyaltyCards(with card: orderLoyaltyCards){
        if let index = self.activeCustomerLoyaltyCards.index(where: {$0.tempId == card.tempId}) {
            self.activeCustomerLoyaltyCards[index] = card
        } else {
            self.activeCustomerLoyaltyCards.append(card)
        }
    }
    
    
    func setLoyaltyCardApplyStatus(cardTempId: String, apply: Bool) {
        let programIndex = activeCustomerLoyaltyCards.index(where: {$0.tempId == cardTempId})
        
        if let programIndex = programIndex {
            activeCustomerLoyaltyCards[programIndex].apply = apply
       
            reApplyLoyaltyPrograms()
        
            if apply {
                autoRedeemSingleItemProgram(card: activeCustomerLoyaltyCards[programIndex])
            }
        }
    }
    
    func getActiveCustomerCardBy(tempId: String) -> orderLoyaltyCards? {
        return activeCustomerLoyaltyCards.first(where: {$0.tempId == tempId})
    }
    
    func getAppliedCustomerLoyaltyCards () -> [orderLoyaltyCards] {
        return activeCustomerLoyaltyCards.filter({$0.apply == true})
    }
    
    func getAppliedTallyBasedCustomerLoyaltyCards () -> [orderLoyaltyCards] {
        return activeCustomerLoyaltyCards.filter({$0.apply == true && $0.card.programType == NIMBUS.Library?.LoyaltyPrograms.Types.Tally})
    }
    
    func getLoyaltyPrograms(){
        var appliedLoyaltyCards = getAppliedCustomerLoyaltyCards()
        
        appliedLoyaltyCards.forEach{appliedCard in
            let cardProgramType: String = appliedCard.card.programType ?? ""
            let quantityType: String = (NIMBUS.Library?.LoyaltyPrograms.Types.Quantity)!
            let couponType: String = (NIMBUS.Library?.LoyaltyPrograms.Types.Coupon)!
            let giftCardType: String = (NIMBUS.Library?.LoyaltyPrograms.Types.GiftCard)!
            let tallyType: String = (NIMBUS.Library?.LoyaltyPrograms.Types.Tally)!
            
            switch cardProgramType {
                case quantityType:
                    if (appliedCard.card.remainingQuantity ?? 0) > 0 {
                        appendQuantityCreditBucket(appliedCard: appliedCard)
                    }
                case couponType:
                    if (appliedCard.card.creditPercent ?? 0 ) > 0 {
                        appendPercentageCreditBucket(appliedCard: appliedCard)
                    }
                case giftCardType:
                    if (appliedCard.card.remainingAmount ?? 0) > 0 {
                        appendAmountCreditBucket(appliedCard: appliedCard)
                    }
                case tallyType:
                    appendTallyBucket(appliedCard: appliedCard)
                default: break
            }
        }
        
        checkOrderForLoyaltyCreditItems()
        
        func appendQuantityCreditBucket(appliedCard: orderLoyaltyCards){
            var creditBucket: loyaltyQuantityCreditBuckets
            
            let programDetails = NIMBUS.LoyaltyPrograms?.getLoyaltyProgramAsStruct(byId: appliedCard.card.programId!)

            if let programDetails = programDetails {
                if !((programDetails.products?.isEmpty)!){
                    creditBucket = loyaltyQuantityCreditBuckets(
                            orderLoyaltyCardTempId: appliedCard.tempId,
                            programId: appliedCard.card.programId!,
                            remainingQuantity: Int(appliedCard.card.remainingQuantity ?? 0),
                            productSet: programDetails.products!,
                            prePurchase: appliedCard.prePurchase
                        )
                    
                    self.activeQuantityLoyalty.append(creditBucket)
                } else if !((programDetails.categories?.isEmpty)!){
                    var categoryBasedProductSet = [programProduct]()
                    
                    programDetails.categories?.forEach{ctg in
                        let categoryProducts = NIMBUS.Products?.getProductsByCategory(categoryFilter: ctg.name!)
                        categoryProducts?.forEach{ctgProd in
                            var prod = programProduct()
                            prod.productId = ctgProd._id
                            prod.sizeCodes = ctgProd.sizes.map({
                                (sizes: [productSize]) -> [String] in
                                return sizes.map({$0.code!})
                            })
                            categoryBasedProductSet.append(prod)
                        }
                    }
                    
                    creditBucket = loyaltyQuantityCreditBuckets(
                        orderLoyaltyCardTempId: appliedCard.tempId,
                        programId: appliedCard.card.programId!,
                        remainingQuantity: Int(appliedCard.card.remainingQuantity ?? 0),
                        productSet: categoryBasedProductSet,
                        prePurchase: appliedCard.prePurchase
                    )
                    
                    self.activeQuantityLoyalty.append(creditBucket)
                }
//                print("active quantity cards")
//                dump(self.activeQuantityLoyalty)
            }
        }
        
        func appendAmountCreditBucket(appliedCard: orderLoyaltyCards){
            self.activeAmountLoyalty.append(
                loyaltyAmountCreditBuckets(
                    orderLoyaltyCardTempId: appliedCard.tempId,
                    programId: appliedCard.card.programId!,
                    remainingAmount: appliedCard.card.remainingAmount!,
                    prePurchase: appliedCard.prePurchase
                )
            )
//            print("active amount cards")
//            dump(self.activeAmountLoyalty)
        }
        
        
        func appendPercentageCreditBucket(appliedCard: orderLoyaltyCards){
            if let programDetails = NIMBUS.LoyaltyPrograms?.getLoyaltyProgramAsStruct(byId: appliedCard.card.programId!) {
                var categoryBasedProductSet = [programProduct]()
                
                if !((programDetails.categories?.isEmpty)!){
                    programDetails.categories?.forEach{ctg in
                        let categoryProducts = NIMBUS.Products?.getProductsByCategory(categoryFilter: ctg.name!)
                        categoryProducts?.forEach{ctgProd in
                            var prod = programProduct()
                            prod.productId = ctgProd._id
                            prod.sizeCodes = ctgProd.sizes.map({
                                (sizes: [productSize]) -> [String] in
                                return sizes.map({$0.code!})
                            })
                            categoryBasedProductSet.append(prod)
                        }
                    }
                }
                
                let creditBucket = loyaltyPercentageCreditBuckets(
                    orderLoyaltyCardTempId: appliedCard.tempId,
                    programId: appliedCard.card.programId!,
                    creditPercent: appliedCard.card.creditPercent!,
                    appliesTo: programDetails.appliesTo!,
                    productSet: categoryBasedProductSet,
                    prePurchase: appliedCard.prePurchase
                )
                
                self.activePercentageLoyalty.append(creditBucket)
            }
        }
        
        func appendTallyBucket(appliedCard: orderLoyaltyCards){
            if let programDetails = NIMBUS.LoyaltyPrograms?.getLoyaltyProgramAsStruct(byId: appliedCard.card.programId!) {
                self.activeTallyCards.append(
                    loyaltyTallyBuckets(
                        orderLoyaltyCardTempId: appliedCard.tempId,
                        programId: appliedCard.card._id!,
                        priorTally: Int(appliedCard.card.tally ?? 0),
                        newTally: Int(appliedCard.card.tally ?? 0),
                        tallyThreshold: Int(programDetails.programType?.tally ?? 0),
                        productSet: programDetails.products ?? []
                    )
                )
            }
        }
    }
 
    func checkOrderForLoyaltyCreditItems(){
        if self.customer != nil || !self.activeCustomerLoyaltyCards.isEmpty {
            self.orderItems.forEach{item in
                applyQuantityCards(item: item)
                applyPercentageCards(item: item)
                applyTallyPrograms(item: item)
            }
            applyGiftCards()
            calculateOrderPricing()
            updatePricingLabels()
        }
    }
    
    func applyQuantityCards(item: orderItem){
        let selectedProduct = item.product!
        let selectedSizeCode = item.size!.code!
        let selectedQuantity = item.quantity
        let seatNumber = item.seatNumber!
        
        var currentPrograms = self.activeQuantityLoyalty
        
        if !(currentPrograms.isEmpty){
            
            for i in currentPrograms.indices{
                
                let currentProgramProducts = currentPrograms[i].productSet

                for j in currentProgramProducts.indices {
                    
                    let programProduct = currentProgramProducts[j]
                    
                    if selectedProduct._id == programProduct.productId{
                        
                        if programProduct.sizeCodes!.contains(selectedSizeCode){
                            
                            let redeemItemKey = "Redeem-" + selectedSizeCode + "-" + selectedProduct._id!
 
                            let redeemItem = getItemByKey(itemKey: redeemItemKey, seatNumber: seatNumber)
                            
                            if let redeemItem = redeemItem {
                                if (selectedQuantity > redeemItem.quantity){
                                
                                    let addQuantity = selectedQuantity - redeemItem.quantity
                                    
                                    if((addQuantity <= currentPrograms[i].remainingQuantity) && (currentPrograms[i].remainingQuantity > 0)){
                                        currentPrograms[i].remainingQuantity -= addQuantity
                                        addRedeemItem(item: item, selectedQuantity: selectedQuantity, discountPercent: 1, includeAddOns: false, isManualRedeem: false)
                                    } else if ((addQuantity > currentPrograms[i].remainingQuantity) && (currentPrograms[i].remainingQuantity > 0)) {
                                        let fullQuantity = redeemItem.quantity + currentPrograms[i].remainingQuantity
                                        addRedeemItem(item: item, selectedQuantity: fullQuantity, discountPercent: 1, includeAddOns: false, isManualRedeem: false)
                                        currentPrograms[i].remainingQuantity = 0
                                    } else {
                                        // Do nothing
                                    }
                                } else if (item.quantity < redeemItem.quantity){
                                    let reduceQuantity = redeemItem.quantity - item.quantity
                                    currentPrograms[i].remainingQuantity += reduceQuantity
                                    addRedeemItem(item: item, selectedQuantity: item.quantity, discountPercent: 1, includeAddOns: false, isManualRedeem: false)
                                }
                            }else {
                                if(selectedQuantity <= currentPrograms[i].remainingQuantity){
                                    addRedeemItem(item: item, selectedQuantity: selectedQuantity, discountPercent: 1, includeAddOns: false, isManualRedeem: false)
                                    currentPrograms[i].remainingQuantity -= selectedQuantity
                                } else {
                                    addRedeemItem(item: item, selectedQuantity: currentPrograms[i].remainingQuantity, discountPercent: 1, includeAddOns: false, isManualRedeem: false)
                                    currentPrograms[i].remainingQuantity = 0;
                                }
                
                            }
                        }
                    }
                }
            }

            self.activeQuantityLoyalty = currentPrograms
        }
    }
    
    func applyGiftCards(){
        let orderSubtotals = orderPricing
        
        self.paymentDueAmount = orderSubtotals.total ?? 0

        if self.activeAmountLoyalty.count > 0 {
            for card in self.activeAmountLoyalty.indices {
                if(self.activeAmountLoyalty[card].prePurchase == true){
                    let cardPrice = NIMBUS.LoyaltyPrograms?.getLoyaltyProgramAsStruct(byId: self.activeAmountLoyalty[card].programId)?.price ?? 0
                    if((paymentDueAmount - cardPrice) <= self.activeAmountLoyalty[card].remainingAmount){
                        self.activeAmountLoyalty[card].remainingAmount = self.activeAmountLoyalty[card].remainingAmount - (paymentDueAmount - cardPrice)
                        paymentDueAmount = 0 + cardPrice
                    } else {
                        paymentDueAmount = paymentDueAmount - self.activeAmountLoyalty[card].remainingAmount + cardPrice
                        self.activeAmountLoyalty[card].remainingAmount = 0
                    }
                } else {
                    if(paymentDueAmount <= self.activeAmountLoyalty[card].remainingAmount){
                        self.activeAmountLoyalty[card].remainingAmount -= paymentDueAmount
                        paymentDueAmount = 0
                    } else {
                        paymentDueAmount -= self.activeAmountLoyalty[card].remainingAmount
                        self.activeAmountLoyalty[card].remainingAmount = 0
                    }
                }
            }
        }
    }

    func applyPercentageCards(item: orderItem){
        let selectedProduct = item.product
        let selectedSizeCode = item.size?.code
        let selectedQuantity = item.quantity
        let seatNumber = item.seatNumber
        
        let percentagePrograms = self.activePercentageLoyalty
        
        if !percentagePrograms.isEmpty{
            
            for i in percentagePrograms.indices {
            
                let currentProgramProducts = percentagePrograms[i].productSet
                
                for j in currentProgramProducts.indices {
                
                    let programProduct = currentProgramProducts[j]
                    
                    if (selectedProduct?._id == programProduct.productId){

                        if(programProduct.sizeCodes?.contains(selectedSizeCode!) ?? false){
                            let discountPercent = percentagePrograms[i].creditPercent/100
                            addRedeemItem(item: item, selectedQuantity: item.quantity, discountPercent: discountPercent, includeAddOns: false, isManualRedeem: false)
                        }
                    }
                }
            }
        }
    }
    
    func applyTallyPrograms(item: orderItem){
        let selectedProduct = item.product
        let selectedSizeCode = item.size?.code
        let selectedQuantity = item.quantity
        let seatNumber = item.seatNumber
        
        var tallyPrograms = self.activeTallyCards

        for i in tallyPrograms.indices{
            
            //refresh customer tally to original amount
            tallyPrograms[i].newTally = tallyPrograms[i].priorTally
            
            let currentProgramProducts = tallyPrograms[i].productSet ?? []
            
            for j in currentProgramProducts.indices {

                let programProduct = currentProgramProducts[j];
                
                if selectedProduct?._id == programProduct.productId {
                    
                    if programProduct.sizeCodes?.contains(selectedSizeCode!) ?? false {
                        
                        let redeemItemKey = "Redeem-" + selectedSizeCode! + "-" + (selectedProduct?._id)!
                        
                        let redeemItem = getItemByKey(itemKey: redeemItemKey, seatNumber: seatNumber!)
                        
                        if((redeemItem) != nil){
                            // IN ORDER TO AVOID CONFLICTING REDEEMS, IF THERE IS ALREADY A REDEEM ITEM, DO NOTHING
                        } else {
                            tallyPrograms[i].newTally += item.quantity
                            
                            if(tallyPrograms[i].newTally > tallyPrograms[i].tallyThreshold){
                                
                                addRedeemItem(item: item, selectedQuantity: 1, discountPercent: 1, includeAddOns: false, isManualRedeem: false)
                                
                                tallyPrograms[i].newTally = 0
                            }
                        }
                    }
                }
            }
        }

        self.activeTallyCards = tallyPrograms
    }
    
    func removePrePurchaseLoyaltyCard(programId: String){
        let removeIndex = self.activeCustomerLoyaltyCards.index(where: {$0.card.programId == programId && $0.prePurchase == true})
        
        if let removeIndex = removeIndex {
            self.activeCustomerLoyaltyCards.remove(at: removeIndex)
        }
        
        reApplyLoyaltyPrograms()
    }
    
    func updatePrePurchaseLoyaltyCardQuantities(loyaltyOrderItem: orderItem){
        let programId = loyaltyOrderItem.product?._id ?? " "
        if let program = NIMBUS.LoyaltyPrograms?.getLoyaltyProgram(byId: programId) {
            if var programCard = self.activeCustomerLoyaltyCards.first(where: {$0.card.programId == programId && $0.prePurchase == true}) {
                programCard.card.remainingQuantity = Int16(loyaltyOrderItem.quantity * Int(program.programQuantity))
                programCard.card.remainingAmount = Float(loyaltyOrderItem.quantity) * program.programCreditAmount
                programCard.card.creditPercent = program.programCreditPercent
                setActiveCustomerLoyaltyCards(with: programCard)
            }
        }
    }
    
    func addPrePurchaseLoyaltyCard(loyaltyOrderItem: orderItem, program: loyaltyProgramSchema){
        if let index = self.activeCustomerLoyaltyCards.index(where: {$0.card.programId == program._id && $0.prePurchase == true}){
            //card exists
            updatePrePurchaseLoyaltyCardQuantities(loyaltyOrderItem: loyaltyOrderItem)
        } else {
            var programAsCard = loyaltyCardSchema()
            programAsCard.customerId = self.customer?.id
            programAsCard.programId = program._id
            programAsCard.programType = program.programType?.type
            programAsCard.remainingQuantity = Int16(loyaltyOrderItem.quantity * Int(program.programType?.quantity ?? 0))
            programAsCard.remainingAmount = Float(loyaltyOrderItem.quantity) * (program.programType?.creditAmount ?? 0)
            programAsCard.creditPercent = program.programType?.creditPercentage
            programAsCard.tally = 0
            programAsCard.boughtOn = Date()
            programAsCard.expired = false
            programAsCard.updatedOn = Date()
            
            let orderLoyaltyCard = orderLoyaltyCards(card: programAsCard, apply: false, prePurchase: true)
        
            setActiveCustomerLoyaltyCards(with: orderLoyaltyCard)
        }
    }
    
    private func setPrePurchaseLoyaltyCardApplyStatus(loyaltyOrderItem: orderItem, apply: Bool) {
        let programId = loyaltyOrderItem.product?._id ?? " "
        if let program = NIMBUS.LoyaltyPrograms?.getLoyaltyProgram(byId: programId) {
            if var programCard = self.activeCustomerLoyaltyCards.first(where: {$0.card.programId == programId && $0.prePurchase == true}) {
                programCard.apply = apply
                setActiveCustomerLoyaltyCards(with: programCard)
            }
        }
    }
    
    func getPrePurchaseLoyaltyCard(forOrderItem loyaltyOrderItem: orderItem) -> orderLoyaltyCards? {
        let programId = loyaltyOrderItem.product?._id ?? " "
        if let programCard = self.activeCustomerLoyaltyCards.first(where: {$0.card.programId == programId && $0.prePurchase == true}) {
            return programCard
        }
        return nil
    }
    
    private func applyPrePurchaseLoyaltyCard(loyaltyOrderItem: orderItem){
        setPrePurchaseLoyaltyCardApplyStatus(loyaltyOrderItem: loyaltyOrderItem, apply: true)
    }
    
    private func deApplyPrePurchaseLoyaltyCard(loyaltyOrderItem: orderItem){
        setPrePurchaseLoyaltyCardApplyStatus(loyaltyOrderItem: loyaltyOrderItem, apply: false)
    }
    
    func setPrePurchaseLoyaltyApplyStatus(loyaltyOrderItem: orderItem, apply: Bool){
        let programId = loyaltyOrderItem.product?._id ?? "-"
    
        if apply {
            applyPrePurchaseLoyaltyCard(loyaltyOrderItem: loyaltyOrderItem)
        } else {
            deApplyPrePurchaseLoyaltyCard(loyaltyOrderItem: loyaltyOrderItem)
        }
        
        reApplyLoyaltyPrograms()
        
        if(apply){
            let prePurchaseLoyaltyCard = self.activeCustomerLoyaltyCards.first(where: {$0.card.programId == programId})
            autoRedeemSingleItemProgram(card: prePurchaseLoyaltyCard!)
        }
        
        orderSummaryManagerDelegate?.refreshItemsList()
    }
    
    func autoRedeemSingleItemProgram(card: orderLoyaltyCards){
        if let programAsStruct = NIMBUS.LoyaltyPrograms?.getLoyaltyProgramAsStruct(byId: card.card.programId!) {
            if (programAsStruct.products?.count == 1){
                if(programAsStruct.products![0].sizeCodes?.count == 1){
                    //AUTO REDEEM THAT PRODUCT UNLESS IT'S ALREADY ADDED
                    
                    let candidateProductId = programAsStruct.products![0].productId
                    let candidateProduct = NIMBUS.Products?.getProductById(productId: candidateProductId!)
                    let candidateProductAsStruct = productSchema(withManagedObject: candidateProduct)
                    
                    let candidateSize = candidateProductAsStruct.sizes?.first(where: {$0.code == programAsStruct.products![0].sizeCodes![0] })
                    var candidateKey: String?
                    var existingOrderItem: orderItem?
                    
                    if let candidateSize = candidateSize {
                        candidateKey = candidateSize.code! + "-" + candidateProductAsStruct._id!
                    }
                    
                    if let candidateKey = candidateKey {
                        existingOrderItem =  getItemByKey(itemKey: candidateKey, seatNumber: nil)
                    }
                    
                    if existingOrderItem != nil {
                        //do nothing
                    } else {
                        //add order item
                        if(candidateProductAsStruct != nil && candidateSize != nil) {
                            addSelectedProductToOrderItems(selectedProductItem: candidateProductAsStruct, selectedSize: candidateSize!)
                            checkOrderForLoyaltyCreditItems()
                        }
                    }
                }
            }
        }
    }
    
    func isThisALoyaltyProgram(byId id: String) -> Bool {
        if NIMBUS.LoyaltyPrograms?.getLoyaltyProgramAsStruct(byId: id) != nil {
            return true
        } else {
            return false
        }
    }
    
    func getOrderPaymentGiftCardTotal() -> Float {
        let allGiftCardPayments = getOrderPaymentGiftCardPayments()
        return allGiftCardPayments.reduce(0.00, {(Result, giftCard) -> Float in
            return Result + giftCard.redeemedAmount!
        })
    }
    
    func getOrderPaymentGiftCardPayments() -> [giftCardPayment]{
        var giftCardPayments = [giftCardPayment]()
        self.activeAmountLoyalty.forEach{card in
            var giftCard = giftCardPayment()
            
            giftCard.programId = card.programId
            if let originalCard = getActiveCustomerCardBy(tempId: card.orderLoyaltyCardTempId) {
                giftCard.redeemedAmount = originalCard.card.remainingAmount! - card.remainingAmount
                giftCard.cardId = originalCard.card._id
            }
            
            giftCardPayments.append(giftCard)
        }
        
        return giftCardPayments
    }
    
    func getOrderPaymentQuantityCardPayment() -> [quantityCardPayment]?{
        var quantityCardPayments = [quantityCardPayment]()
        self.activeQuantityLoyalty.forEach {card in
            var quantityCard = quantityCardPayment()
            
            quantityCard.programId = card.programId
            if let originalCard = getActiveCustomerCardBy(tempId: card.orderLoyaltyCardTempId) {
                quantityCard.redeemedQuantity = Int(originalCard.card.remainingQuantity ?? 0) - card.remainingQuantity
                quantityCard.cardId = originalCard.card._id
            }
            
            quantityCardPayments.append(quantityCard)
        }
        return quantityCardPayments
    }
    
    func updateExistingCards(){
        func updateExistingQuantityCards(){
            let existingQuantityCards = self.activeQuantityLoyalty.filter({$0.prePurchase == false})
            existingQuantityCards.forEach{ card in
                let orderCard = getActiveCustomerCardBy(tempId: card.orderLoyaltyCardTempId)
                NIMBUS.LoyaltyCards?.updateQuantityLoyaltyCard(cardId: (orderCard?.card._id)!, remainingQuantity: card.remainingQuantity, expired: nil)
            }
        }
        
        func updateExistingAmountCards(){
            let existingAmountCards = self.activeAmountLoyalty.filter({$0.prePurchase == false})
            existingAmountCards.forEach{ card in
                let orderCard = getActiveCustomerCardBy(tempId: card.orderLoyaltyCardTempId)
                NIMBUS.LoyaltyCards?.updateAmountLoyaltyCard(cardId: (orderCard?.card._id)!, remainingAmount: card.remainingAmount, expired: nil)
            }
        }
        
        func updateExistingPercentageCards(){
            let existingPercentageCards = self.activePercentageLoyalty.filter({$0.prePurchase == false})
            existingPercentageCards.forEach{ card in
                let orderCard = getActiveCustomerCardBy(tempId: card.orderLoyaltyCardTempId)
                NIMBUS.LoyaltyCards?.updatePercentageLoyaltyCard(cardId: (orderCard?.card._id)!, expired: nil)
            }
        }
        
        func updateExistingTallyCards(){
            
            self.activeTallyCards.forEach{ card in
                let orderCard = getActiveCustomerCardBy(tempId: card.orderLoyaltyCardTempId)
                NIMBUS.LoyaltyCards?.updateTallyLoyaltyCard(cardId: (orderCard?.card._id)!, tally: card.newTally)
            }
        }
        
        updateExistingQuantityCards()
        updateExistingAmountCards()
        updateExistingPercentageCards()
        updateExistingTallyCards()
    }
    
    func buyNewLoyaltyProgramCards(){
        //Buy unapplied cards
        let allUnappliedBuyCards = self.activeCustomerLoyaltyCards.filter({$0.prePurchase == true && $0.apply == false})
        allUnappliedBuyCards.forEach{ newCard in
            newCard.card.saveToCoreData()
        }
        
        //Buy applied cards with updated balances
        let allAppliedBuyCards = self.activeCustomerLoyaltyCards.filter({$0.prePurchase == true && $0.apply == true})
        allAppliedBuyCards.forEach{ appliedNewCard in
            let cardProgramType: String = appliedNewCard.card.programType ?? ""
            let quantityType: String = (NIMBUS.Library?.LoyaltyPrograms.Types.Quantity)!
            let couponType: String = (NIMBUS.Library?.LoyaltyPrograms.Types.Coupon)!
            let giftCardType: String = (NIMBUS.Library?.LoyaltyPrograms.Types.GiftCard)!
            let tallyType: String = (NIMBUS.Library?.LoyaltyPrograms.Types.Tally)!
            
            switch cardProgramType {
                case quantityType:
                    addNewAppliedQuantityCard(appliedNewCard: appliedNewCard)
                case giftCardType:
                    addNewAppliedAmountCard(appliedNewCard: appliedNewCard)
                case couponType:
                    addNewAppliedPercentageCard(appliedNewCard: appliedNewCard)
                case tallyType:
                    addNewAppliedTallyCard(appliedNewCard: appliedNewCard)
                default: break
            }
        }
        
        func addNewAppliedQuantityCard(appliedNewCard: orderLoyaltyCards){
            if let appliedQuantityCreditBucket = self.activeQuantityLoyalty.first(where: {$0.orderLoyaltyCardTempId == appliedNewCard.tempId}) {
                var updatedNewCard = appliedNewCard
                updatedNewCard.card.remainingQuantity = Int16(appliedQuantityCreditBucket.remainingQuantity)
                updatedNewCard.card.saveToCoreData()
            }
        }
        
        func addNewAppliedAmountCard(appliedNewCard: orderLoyaltyCards){
            if let appliedAmountCreditBucket = self.activeAmountLoyalty.first(where: {$0.orderLoyaltyCardTempId == appliedNewCard.tempId}) {
                var updatedNewCard = appliedNewCard
                updatedNewCard.card.remainingAmount = Float(appliedAmountCreditBucket.remainingAmount)
                updatedNewCard.card.saveToCoreData()
            }
        }
        
        func addNewAppliedPercentageCard(appliedNewCard: orderLoyaltyCards){
            if let appliedPercentageCreditBucket = self.activePercentageLoyalty.first(where: {$0.orderLoyaltyCardTempId == appliedNewCard.tempId}) {
                var updatedNewCard = appliedNewCard
                updatedNewCard.card.saveToCoreData()
            }
        }
        
        func addNewAppliedTallyCard(appliedNewCard: orderLoyaltyCards){
            if let appliedTallyCreditBucket = self.activeTallyCards.first(where: {$0.orderLoyaltyCardTempId == appliedNewCard.tempId}){
                var updatedNewCard = appliedNewCard
                updatedNewCard.card.tally = Int16(appliedTallyCreditBucket.newTally)
                updatedNewCard.card.saveToCoreData()
            }
        }
    }
}
