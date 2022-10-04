//
//  nimbusOrderCreationCheckoutExtension.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-22.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit

extension nimbusOrderCreationFunctions{
    func initializeOrderPaymentValues(){
        self.orderPayment.method = AcceptedPaymentMethods.cash.key
        
        let pricing = money(exactAmount: self.orderPricing.total ?? 0, paymentType: self.orderPayment.method ?? AcceptedPaymentMethods.defaultMethod.key)
        self.orderPayment.amount = pricing.exactAmount
        
        if self.orderPayment.method == "cash" {
            self.orderPayment.rounding = pricing.rounding ?? 0.00
            self.orderPayment.cashGiven = 0.00
        }
    }
    
    func refreshOrderPayment(){
        let pricing = money(exactAmount: self.orderPricing.total ?? 0, paymentType: self.orderPayment.method ?? AcceptedPaymentMethods.defaultMethod.key)
        self.orderPayment.amount = pricing.exactAmount
        
        if self.orderPayment.method == "cash" {
            self.orderPayment.rounding = pricing.rounding ?? 0.00
        }
    }
    
    func updateCashGiven(given: Float){
        self.orderPayment.cashGiven = given
        self.orderPayment.change = self.orderPayment.cashGiven! - (self.orderPayment.amount! + self.orderPayment.rounding!)
    }
    
    func setPaymentMethod(method: paymentMethodAttributes){
        self.orderPayment.method = method.key
        updateCheckoutPaymentComponents()
    }
    
    func changeAdjustmentPercent(percent: Int){
        let newPercent = self.orderAdjustmentPercent + percent
        if newPercent >= 0 && newPercent <= 100 {
            self.orderAdjustmentPercent += percent
        }
    }
    
    func isOrderReadyForCheckout() -> (Bool, String) {
        var checkoutReady:Bool = true
        var reason: String = ""
        
        if NIMBUS.OrderCreation?.isOrderCartEmpty ?? true {
            checkoutReady = false
            reason = "EMPTY"
            return (checkoutReady, reason)
        }
        
//        if orderInformation?.orderType == _OrderTypes.DineIn.rawValue {
//            if waiter == nil {
//                checkoutReady = false
//                reason = "WAITER"
//                return (checkoutReady, reason)
//            }
//        }
        
        return (checkoutReady, reason)
    }
    
    func createOpenOrder(){
        createAndSaveOpenOrder()
        resetOrder()
        orderViewManagerDelegate?.openRecentOrderModal(withSelfDismiss: true)
    }
    
    func updateOpenOrder(){
        updateAndSaveOpenOrder()
        resetOrder()
        orderViewManagerDelegate?.openRecentOrderModal(withSelfDismiss: true)
    }
    
    func completeOrder(){
        if openOrderMode == _OpenOrderModes.CheckoutOpenOrder {
            completeOpenOrder()
        } else {
            completeNewOrder()
        }
    }
    
    private func completeOpenOrder(){
        completeAndSaveOpenOrder()
        resetOrder()
        orderViewManagerDelegate?.openRecentOrderModal(withSelfDismiss: true)
    }
    
    private func completeNewOrder(){
        completeAndSaveNewOrder()
        resetOrder()
        orderViewManagerDelegate?.openRecentOrderModal(withSelfDismiss: true)
    }
    
    private func updateAndSaveOpenOrder(){
        var order = orderSchema(withManagedObject: openOrder)
        
        order.orderInformation = self.orderInformation
        order.customerId = self.customer?.id
        order.waiterId = self.waiter?.id
        order.tableId = self.table?.id
        
        order.items = self.orderItems
        order.subtotals = self.orderPricing
        
        order.updatedAt = Date()
        
        order.saveToCoreData()
    }
    
    private func createAndSaveOpenOrder(){
        var order = orderSchema()
        
        order._id = UUID().uuidString
        order.businessId = NIMBUS.Business?.getBusinessId()
        order.locationId = NIMBUS.Location?.getLocationId()
        order.status = NIMBUS.Library?.OrderStatus.Created
        
        order.orderInformation = self.orderInformation
        order.customerId = self.customer?.id
        order.waiterId = self.waiter?.id
        order.tableId = self.table?.id
        
        //        order.splitOrders: [String]?
        //        order.originalOrderId: String?
        
        order.items = self.orderItems
        order.subtotals = self.orderPricing
        
        order.dailyOrderNumber = self.dailyOrderNumber
        order.uniqueOrderNumber = self.uniqueOrderNumber
        
        //        order.createdBy: String?
        order.createdAt = Date()
        
        order.timeBucket = timeComponents(createdDate: order.createdAt!)
        
        //        order.updatedBy: String?
        order.updatedAt = Date()
        
        order.saveToCoreData()
    }
    
    private func completeAndSaveOpenOrder(){
        var order = orderSchema(withManagedObject: openOrder)
        
        order.status = NIMBUS.Library?.OrderStatus.Completed
        
        order.orderInformation = self.orderInformation
        order.customerId = self.customer?.id
        order.waiterId = self.waiter?.id
        order.tableId = self.table?.id
        
        order.items = self.orderItems
        order.subtotals = self.orderPricing
        
        self.orderPayment.received = {() -> Float in
            if order.payment?.method == AcceptedPaymentMethods.cash.key {
                return (order.payment?.amount ?? 0.0) + (order.payment?.rounding ?? 0.0)
            } else {
                return order.payment?.amount ?? 0.0
            }
        }()
        order.payment = self.orderPayment
        order.payment?.giftCardTotal = getOrderPaymentGiftCardTotal()
        order.payment?.giftCards = getOrderPaymentGiftCardPayments()
        order.payment?.quantityCards = getOrderPaymentQuantityCardPayment()
        
        order.updatedAt = Date()
        
        order.saveToCoreData()
        updateExistingCards()
        buyNewLoyaltyProgramCards()
        
        if self.printOrderReceipt == true {
            NIMBUS.Print?.printOrderReceipt(order: order, openDrawer: self.openCashDrawer)
        } else if self.openCashDrawer == true {
            NIMBUS.Print?.openCashDrawer()
        }
    }
    
    private func completeAndSaveNewOrder(){
        var order = orderSchema()
        
        order._id = UUID().uuidString
        order.businessId = NIMBUS.Business?.getBusinessId()
        order.locationId = NIMBUS.Location?.getLocationId()
        order.status = NIMBUS.Library?.OrderStatus.Completed
        
        order.orderInformation = self.orderInformation
        order.customerId = self.customer?.id
        order.waiterId = self.waiter?.id
        order.tableId = self.table?.id
        
        //        order.splitOrders: [String]?
        //        order.originalOrderId: String?
        
        order.items = self.orderItems
        order.subtotals = self.orderPricing
        
        order.payment = self.orderPayment
        order.payment?.giftCardTotal = getOrderPaymentGiftCardTotal()
        order.payment?.giftCards = getOrderPaymentGiftCardPayments()
        order.payment?.quantityCards = getOrderPaymentQuantityCardPayment()
        
        if order.payment?.method == AcceptedPaymentMethods.cash.key {
            order.payment?.received = (order.payment?.amount ?? 0.0) + (order.payment?.rounding ?? 0.0)
        } else {
            order.payment?.received = order.payment?.amount ?? 0.0
        }
        
        order.dailyOrderNumber = self.dailyOrderNumber
        order.uniqueOrderNumber = self.uniqueOrderNumber
        
        //        order.createdBy: String?
        order.createdAt = Date()
        
        order.timeBucket = timeComponents(createdDate: order.createdAt!)
        
        //        order.updatedBy: String?
        order.updatedAt = Date()
        
        order.saveToCoreData()
        updateExistingCards()
        buyNewLoyaltyProgramCards()
        
        if self.printOrderReceipt == true {
            NIMBUS.Print?.printOrderReceipt(order: order, openDrawer: self.openCashDrawer)
        } else if self.openCashDrawer == true {
            NIMBUS.Print?.openCashDrawer()
        }
    }
}
