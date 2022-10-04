//
//  nimbusOrderFunctions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-21.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class nimbusOrderCreationFunctions: NimbusBase {
    var orderViewManagerDelegate: OrderViewManagerDelegate?
    var orderSummaryManagerDelegate: OrderSummaryManagerDelegate?
    var itemOptionsManagerDelegate: itemOptionsManagerDelegate?
    var orderCheckoutManagerDelegate: OrderCheckoutManagerDelegate?
    var orderAdjustmentDelegate: OrderAdjustmentControllerDelegate?
    var orderItemsSelectionManagerDelegate: OrderItemsSelectionManagerDelegate?
    var orderViewCustomerLoyaltyCardsDelegate: OrderViewCustomerLoyaltyCardsDelegate?
    
    override init (master: NimbusFramework?){
        super.init(master: master)
    }
    
    var selectedOrderItem: orderItem?
    
    var itemNumber: Decimal = 1.0
    
    func getNextItemNumber() ->Decimal {
        let currentItemNumber = itemNumber
        itemNumber += 1.0
        return currentItemNumber
    }
    
    func getNextRedeemItemNumber(referenceItemNumber: Decimal) -> Decimal{
        let redeemItems = orderItems.filter({($0.itemNumber! > referenceItemNumber) && (($0.itemNumber! + 1) < referenceItemNumber)})
        let sortedRedeemItems = redeemItems.sorted(by: {$0.itemNumber! < $1.itemNumber!})
        let highestRedeemItem = sortedRedeemItems.first?.itemNumber ?? referenceItemNumber
        return highestRedeemItem + 0.1
    }
    
    var orderInformation: orderInfoSchema?{
        didSet {
            self.orderSummaryManagerDelegate?.orderInformationSet(orderInfo: orderInformation)
        }
    }
    
    var defaultOrderType: _OrderTypes {
        get {
            return _OrderTypes(rawValue: UserDefaults.standard.string(forKey: "defaultOrderType") ?? "") ?? _OrderTypes.Express
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "defaultOrderType")
            UserDefaults.standard.synchronize()
        }
    }
    
    var printOrderReceipt: Bool = true
    var openCashDrawer: Bool = true 
    
    var waiter: Employee? {
        didSet {
            self.orderSummaryManagerDelegate?.waiterSelected(waiter: waiter)
        }
    }
    var table: Table? {
        didSet{
            self.orderSummaryManagerDelegate?.tableSelected(table: table)
            if table != nil {
                table?.seats = table?.defaultSeats ?? 1
                self.orderItemsSelectionManagerDelegate?.showProductsView()
                if self.orderInformation?.orderType != _OrderTypes.DineIn.rawValue {
                    var info = self.orderInformation ?? orderInfoSchema()
                    info.orderType = _OrderTypes.DineIn.rawValue
                    self.orderInformation = info
                }
            }
        }
    }
    
    var seat: seatStruct? {
        didSet {
            orderSummaryManagerDelegate?.refreshItemsList()
        }
    }
    
    func addSeatToTable () {
        table?.seats += 1
        self.orderSummaryManagerDelegate?.tableSelected(table: table!)
    }
    
    var dailyOrderNumber: Int {
        get {
            let deviceNumber = NIMBUS.Devices?.deviceAPIs.deviceNumber
            let now = Date()
            let timeStamp = Int(now.timeIntervalSince(now.startOfDay)/10)
            let orderNumberString = (deviceNumber?.toString() ?? "1") + (String(timeStamp))
            return Int(orderNumberString) ?? 1
        }
    }
    
    var uniqueOrderNumber: Int {
        get {
            let deviceNumber = NIMBUS.Devices?.deviceAPIs.deviceNumber
            let now = Date()
            let timeStamp = Int(now.timeIntervalSinceReferenceDate)
            let orderNumberString = (deviceNumber?.toString() ?? "1") + (String(timeStamp))
            return Int(orderNumberString) ?? 1
        }
    }
    
    var orderAdjustmentPercent: Int = 0 {
        didSet {
            calculateOrderPricing()
            refreshOrderPayment()
            orderAdjustmentDelegate?.setAdjustmentPercent(percent: orderAdjustmentPercent)
        }
    }
    
    func getAdjustmentPercent()->Int {
        return self.orderAdjustmentPercent
    }
    
    var orderDiscountPercent: Int = 0
    
    var orderItems = [orderItem]() {
        didSet {
            orderSummaryManagerDelegate?.refreshItemsList()
            
            //intentionally done as a for loop to not trigger entering a infinite loop
            for (index, item) in orderItems.enumerated() {
                let total =  { () -> Float in
                    var _total = Float(0)
                    var addOnsTotal = Float(0)
                    
                    if let addOns = item.addOns {
                        addOnsTotal += addOns.reduce(Float(0)){ result, item in (item.price! + result)}
                    }
                    
                    if let size = item.size {
                        _total += (size.price! + addOnsTotal) * Float(item.quantity)
                    }
                    
                    return _total
                }()
                orderItems[index].total = total
            }
            
            calculateOrderPricing()
            
            if orderItems.count == 0 {
                orderSummaryManagerDelegate?.orderListEmpty(orderEmpty: true)
            } else {
                orderSummaryManagerDelegate?.orderListEmpty(orderEmpty: false)
            }
        }
    }
    
    var isOrderCartEmpty: Bool! {
        get {
            return self.orderItems.isEmpty
        }
    }
    
    var orderPricing = orderPriceSchema(){
        didSet {
            updatePricingLabels()
        }
    }
    
    func getOrderDiscountPercent () -> Int {
        return self.orderDiscountPercent
    }
    
    var orderPayment = paymentInformation(){
        didSet {
            orderCheckoutManagerDelegate?.setOrderPaymentDetails(orderPayment: orderPayment)
            
            let giftCardTotal = getOrderPaymentGiftCardTotal()
            orderCheckoutManagerDelegate?.giftCardPaySet(giftCardPay: giftCardTotal)
        }
    }
    
    func initializeItemOptionsMenu(delegate: itemOptionsManagerDelegate){
        self.itemOptionsManagerDelegate = delegate
    }
    
    func updatePricingLabels(){
        orderSummaryManagerDelegate?.orderSubtotalsSet(orderSubtotals: orderPricing)
        
        let giftCardTotal = getOrderPaymentGiftCardTotal()
        orderSummaryManagerDelegate?.giftCardPaySet(giftCardPay: giftCardTotal)
    }
    
    func updateCheckoutView(){
        updateCheckoutPaymentComponents()
        orderAdjustmentPercent = 0 
    }
    
    func updateCheckoutPaymentComponents(){
        orderCheckoutManagerDelegate?.refreshOrderPaymentDetails()
    }
    
    func calculateCashRounding(){
        let pricing = money(exactAmount: self.orderPricing.total!, paymentType: self.orderPayment.method!)
        self.orderPayment.rounding = pricing.rounding
    }
    
    func clearCashRounding(){
        self.orderPayment.rounding = 0.00
    }
    
    func calculateOrderPricing(){
//        var discount: Float = 0.0
        var highestPercent: Float = 0
        
        orderPricing.subtotal = addAllItemTotals()
        
        //if any credit percentage based loyalties then get highest percentage
        let couponCards = self.activePercentageLoyalty
        couponCards.forEach {coupon in
            if coupon.appliesTo == "Entire-Purchase"{
                if highestPercent < coupon.creditPercent {
                    highestPercent = coupon.creditPercent
                }
            }
        }
        
        orderPricing.discount = orderPricing.subtotal! * highestPercent/100
        orderPricing.adjustments = orderPricing.subtotal! * Float(orderAdjustmentPercent)/100
        
        let taxes : (Float, taxComponents) = NIMBUS.Library?.Taxes.CA.ON.determineTax() ?? (0.00, taxComponents())
        
        orderPricing.tax = taxes.0
        orderPricing.taxComponents = taxes.1
        orderPricing.total = orderPricing.subtotal! - orderPricing.discount! - orderPricing.adjustments! + orderPricing.tax!
    }
    
    func addAllItemTotals() -> Float {
        var total: Float = 0.00
        total = self.orderItems.reduce(total) {result, item in (item.total! + result)}
        return total
    }
    
    func applyRequestedDiscountFeatures(referenceProductItem: orderItem,
                                       baseRedeemItem: orderItem,
                                       requestedQuantity: Int = 1,
                                       discountPercent: Float = 100,
                                       includeAddOns: Bool) -> orderItem {
        
        var redeemItem = baseRedeemItem
        
        if includeAddOns == true{
            redeemItem.addOns = referenceProductItem.addOns?.map{addOn in
                var mutableAddOn = addOn
                mutableAddOn.price = mutableAddOn.price! * (-1) * (discountPercent/100)
                return mutableAddOn
            }
        }
        
        redeemItem.size = referenceProductItem.size
        redeemItem.size?.price = (redeemItem.size?.price!)! * (-1) * (discountPercent/100)
        
        redeemItem.product?.name = "Redeem -" + (referenceProductItem.product?.name)!
        redeemItem.product?._id = "Redeem-" + generateKey(sizeCode: (referenceProductItem.size?.code)!, productId: (referenceProductItem.product?._id)!, seatNumber: referenceProductItem.seatNumber ?? 1)
        redeemItem.product?.sizes = [redeemItem.size!]
        
        //To do: 
        // get existing item first before adding in the item
        
//        let itemKey = redeemItem.product?._id
//        let existingRedeemItem = getItemByItemKey(itemKey, seatNumber)
        
//        if existingRedeemItem != nil {
//            //just increase the quantity
//        } else {
        
//        }
        
//        redeemItem.total =  { () -> Float in
//            var _total = Float(0)
//
//            if let size = redeemItem.size {
//                _total += size.price! * Float(redeemItem.quantity!)
//            }
//
//            if let addOns = redeemItem.addOns {
//                _total += addOns.reduce(Float(0)){ result, item in (item.price! + result)}
//            }
//            return _total
//        }()
        
        return redeemItem
    }   
    
    func resetOrder(){
        clearCustomerInfo()
        resetOrderTypeInfo()
        
        waiter = nil
        table = nil
        seat = nil
        
        clearOpenOrder()
        
        selectedOrderItem = nil
        orderItems.removeAll()
        clearCashRounding()
        orderAdjustmentPercent = 0
        orderDiscountPercent = 0
        orderPricing = orderPriceSchema()
        orderPayment = paymentInformation()
        resetCheckout()
    }
    
    func resetOrderTypeInfo(){
        orderInformation = orderInfoSchema(orderType: self.defaultOrderType.rawValue, orderName: "", orderPhone: "", unitNumber: "", buzzerNumber: "", streetNumber: "", street: "", city: "", postalCode: "", instructions: "")
    }
    
    func resetCheckout(){
        orderCheckoutManagerDelegate?.refreshOrderPaymentDetails()
        orderViewManagerDelegate?.exitCheckout()
    }

    func expandOrderItemOptions(item: orderItem){
        if let index = getIndexOfOrderItem(byLocalId: item.localId){
            if self.orderItems[index].isExpanded {
                self.orderItems[index].isExpanded = false
            } else {
                self.orderItems[index].isExpanded = true
            }
        }
    }
    
    func getItemSelectedAddOnsOrSubs(item: orderItem, onlyAddOns: Bool = false, onlySubs: Bool = false) -> [orderItemAddOns]?{
        let allItemAddOns = item.addOns
        
        if onlyAddOns {
            return allItemAddOns?.filter{addOn in
                return NIMBUS.AddOns?.isAddOnASubstitution(withAddOnId: addOn._id!) == false
            }
        } else if onlySubs {
            return allItemAddOns?.filter{addOn in
                return NIMBUS.AddOns?.isAddOnASubstitution(withAddOnId: addOn._id!) == true
            }
        }
        
        return [orderItemAddOns]()
    }
    
    func getItemSelectedAddOns(onlyAddOns: Bool = true, onlySubs: Bool = false) -> [orderItemAddOns]? {
        let localId = self.selectedOrderItem?.localId ?? " "
        if let item = getItemByLocalId(localId: localId) {
            if onlyAddOns == true {
                return getItemSelectedAddOnsOrSubs(item: item, onlyAddOns: onlyAddOns, onlySubs: onlySubs)
            } else if onlySubs == true {
                return getItemSelectedAddOnsOrSubs(item: item, onlyAddOns: onlyAddOns, onlySubs: onlySubs)
            }
        }
        return [orderItemAddOns]()
    }
    
    func getItemAssociatedAddOns(onlyAddOns: Bool = true, onlySubs: Bool = false) -> [orderItemAddOns]? {
        let productId = self.selectedOrderItem?.product?._id
        if let productId = productId {
            let addOns = NIMBUS.AddOns?.getProductAssociatedAddOnsAsStructs(productId: productId, onlyAddOns: onlyAddOns, onlySubs: onlySubs)
            return convertAddOnsToOrderItemAddOns(addOns: addOns)
        }
        return [orderItemAddOns]()
    }
    
    func getItemUnassociatedAddOns(onlyAddOns: Bool = true, onlySubs: Bool = false) -> [orderItemAddOns]? {
        let productId = self.selectedOrderItem?.product?._id
        if let productId = productId {
            let addOns = NIMBUS.AddOns?.getProductUnassociatedAddOnsAsStructs(productId: productId, onlyAddOns: onlyAddOns, onlySubs: onlySubs)
            return convertAddOnsToOrderItemAddOns(addOns: addOns)
        }
        return [orderItemAddOns]()
    }

    func convertAddOnsToOrderItemAddOns(addOns: [productAddOnSchema]?) ->[orderItemAddOns]{
        var itemAddOns = [orderItemAddOns]()
        addOns?.forEach {addOn in
            itemAddOns.append(orderItemAddOns(_id: addOn._id!, name: addOn.name, price: addOn.price))
        }
        return itemAddOns
    }
    
    //MARK: Customer and Loyalty related variables
    var customer: Customer? {
        didSet {
            self.orderSummaryManagerDelegate?.customerSelected(customer: customer)
            if customer != nil {
                getExistingCustomerLoyaltyCards()
            }
        }
    }
    
    var customerLoyaltyCards = [loyaltyCardSchema]()
    
    var activeCustomerLoyaltyCards: [orderLoyaltyCards] = [] {
        didSet {
            orderViewCustomerLoyaltyCardsDelegate?.setCustomerCards(customerLoyaltyCards: activeCustomerLoyaltyCards)
        }
    }
    
    var activeQuantityLoyalty: [loyaltyQuantityCreditBuckets] = []
    var activeAmountLoyalty: [loyaltyAmountCreditBuckets] = []
    var activePercentageLoyalty: [loyaltyPercentageCreditBuckets] = []
    var activeTallyCards: [loyaltyTallyBuckets] = []
    
    var paymentDueAmount: Float = 0.00
    
    var emailReceiptFlag: Bool = false
    
    //Load Open Order
    var openOrder: Order? {
        didSet {
            orderViewManagerDelegate?.setOpenOrder(openOrder: openOrder)
        }
    }
    
    var openOrderMode: _OpenOrderModes = .NotOpenOrder {
        didSet {
            orderViewManagerDelegate?.setOpenOrderMode(openOrderMode: openOrderMode)
        }
    }
    var openOrderStruct: orderSchema?
    
    func loadInOpenOrder(openOrderId: String, openOrderMode: _OpenOrderModes){
        if let openOrder = NIMBUS.OrderManagement?.getOrder(byId: openOrderId){
            self.openOrder = openOrder
            self.openOrderStruct = orderSchema(withManagedObject: openOrder)
            self.openOrderMode = openOrderMode
            
            if let customerId = openOrder.customerId {
                self.customer = NIMBUS.Customers?.getCustomerById(id: customerId)
            }
            
            if let waiterId = openOrder.waiterId {
                self.waiter = NIMBUS.Employees?.getEmployeeById(employeeId: waiterId)
            }
            
            if let tableId = openOrder.tableId {
                self.table = NIMBUS.Tables?.getTableById(tableId: tableId)
            }
            
            self.orderInformation = openOrderStruct?.orderInformation
            
            var localOrderItems: [orderItem] = []
            openOrderStruct?.items?.forEach { item in
                var localItem = item
                localItem = populateOrderItemLocalHelperVariables(item: item)
                localOrderItems.append(localItem)
            }
            
            self.orderItems = localOrderItems
        }
    }
    
    private func clearOpenOrder(){
        self.openOrder = nil
        self.openOrderStruct = nil
        self.openOrderMode = .NotOpenOrder
    }
    
}
