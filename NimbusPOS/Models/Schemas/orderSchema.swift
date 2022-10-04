//
//  orderSchema.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2017-12-29.
//  Copyright © 2017 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct orderProduct: Codable {
    var _id: String?
    var name: String?
    var sizes: [productSize]?
}

struct orderItemAddOns: Codable {
    var _id: String?
    var name: String?
    var price: Float?
}

struct orderItem: Codable {
    var itemNumber: Decimal?
    var product: orderProduct?
    var seatNumber: Int?
    var sentToKitchen: Bool?
    var isRedeemItem: Bool?
    var isManualRedeem: Bool?
    var variablePrice: Bool?
    var unitBasedPrice: Bool?
    var unitBasedPriceQuantity: Float?
    var unitPrice: Float?
    var unitLabel: String?
    var notes: [String]?
    var size: productSize?
    var addOns: [orderItemAddOns]?
    var quantity: Int = 1
    var redeemed: Int?
    var total: Float?
    
    // local extensions
    var localId: String = UUID().uuidString
    var currentKey: String?
    var isExpanded: Bool = false
    var taxRule: String?
    var isLoyaltyProgram: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case itemNumber
        case product
        case seatNumber
        case sentToKitchen
        case isRedeemItem
        case isManualRedeem
        case variablePrice
        case unitBasedPrice
        case unitBasedPriceQuantity
        case unitPrice
        case unitLabel
        case notes
        case size
        case addOns
        case quantity
        case redeemed
        case total
    }

    public init(from decoder: Decoder) throws {
        let itemValues = try decoder.container(keyedBy: CodingKeys.self)

        itemNumber = try? itemValues.decode( Decimal.self, forKey: .itemNumber)
        product = try? itemValues.decode( orderProduct.self, forKey: .product)
        seatNumber = try? itemValues.decode( Int.self, forKey: .seatNumber)
        sentToKitchen = try? itemValues.decode( Bool.self, forKey: .sentToKitchen)
        isRedeemItem = try? itemValues.decode( Bool.self, forKey: .isRedeemItem)
        isManualRedeem = try? itemValues.decode( Bool.self, forKey: .isManualRedeem)
        variablePrice = try? itemValues.decode( Bool.self, forKey: .variablePrice)
        unitBasedPrice = try? itemValues.decode( Bool.self, forKey: .unitBasedPrice)
        unitBasedPriceQuantity = try? itemValues.decode( Float.self, forKey: .unitBasedPriceQuantity)
        unitPrice = try? itemValues.decode( Float.self, forKey: .unitPrice)
        unitLabel = try? itemValues.decode( String.self, forKey: .unitLabel)
        notes = try? itemValues.decode([String].self, forKey: .notes)
        size = try? itemValues.decode( productSize.self, forKey: .size)
        addOns = try? itemValues.decode([orderItemAddOns].self, forKey: .addOns)
        quantity = try! itemValues.decode( Int.self, forKey: .quantity)
        redeemed = try? itemValues.decode( Int.self, forKey: .redeemed)
        total = try? itemValues.decode( Float.self, forKey: .total)
    }

    init(){
        //
    }

}

struct orderPriceSchema: Codable {
    var subtotal: Float?
    var discount: Float?
    var adjustments: Float?
    var tax: Float?
    var taxComponents: taxComponents?
    var total: Float?
}

struct giftCardPayment: Codable {
    var cardId: String?
    var programId: String?
    var redeemedAmount: Float?
    
    func returnAsDictionary() -> [String: Any]{
        return [
            "cardId": cardId,
            "programId": programId,
            "redeemedAmount": redeemedAmount
        ]
    }
}

struct quantityCardPayment: Codable {
    var cardId: String?
    var programId: String?
    var redeemedQuantity: Int?
    
    func returnAsDictionary() -> [String: Any]{
        return [
            "cardId": cardId,
            "programId": programId,
            "redeemedQuantity": redeemedQuantity
        ]
    }
}

struct paymentInformation: Codable {
    var method: String?
    var amount: Float?
    var giftCardTotal: Float?
    var giftCards: [giftCardPayment]?
    var quantityCards: [quantityCardPayment]?
    var rounding: Float?
    var received: Float?
    var cashGiven: Float?
    var change: Float?
    var tips: Float?
}

struct orderInfoSchema: Codable {
    var orderType: String?
    var orderName: String?
    var orderPhone: String?
    var unitNumber: String?
    var buzzerNumber: String?
    var streetNumber: String?
    var street: String?
    var city: String?
    var postalCode: String?
    var instructions: String?
}

struct orderSchema: Codable {
    var _id: String?
    var businessId: String?
    var locationId: String?
    var status: String?
    var orderInformation: orderInfoSchema?
    var customerId: String?
    var waiterId: String?
    var tableId: String?
    var splitOrders: [String]?
    var originalOrderId: String?
    var items: [orderItem]?
    var subtotals: orderPriceSchema?
    var payment: paymentInformation?
    var dailyOrderNumber: Int?
    var uniqueOrderNumber: Int?
    var createdBy: String?
    var createdAt: Date?
    var timeBucket: timeComponents?
    var updatedBy: String?
    var updatedAt: Date?
    
    init (withJSONDataObject json: [String: Any] = [:], withManagedObject orderMO: Order? = nil){
        if !json.isEmpty {
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601UTC)
                do {
                    let orderObject = try decoder.decode(orderSchema.self, from: data)
                    self = orderObject
                } catch {
                    print(error)
                }
            }
        } else if let orderMO = orderMO {
            var order = orderSchema()

            order._id = orderMO.id
            order.businessId = orderMO.businessId
            order.locationId = orderMO.locationId
            order.status = orderMO.status
            
            //orderInformation
            order.orderInformation = orderInfoSchema()
            order.orderInformation?.orderType = orderMO.orderInfoOrderType
            order.orderInformation?.orderName = orderMO.orderInfoOrderName
            order.orderInformation?.orderPhone = orderMO.orderInfoOrderPhone
            order.orderInformation?.unitNumber = orderMO.orderInfoUnitNumber
            order.orderInformation?.buzzerNumber = orderMO.orderInfoBuzzerNumber
            order.orderInformation?.streetNumber = orderMO.orderInfoStreetNumber
            order.orderInformation?.street = orderMO.orderInfoStreet
            order.orderInformation?.city = orderMO.orderInfoCity
            order.orderInformation?.postalCode = orderMO.orderInfoPostalCode
            order.orderInformation?.instructions = orderMO.orderInfoInstructions
            //
            
            order.customerId = orderMO.customerId
            order.waiterId = orderMO.waiterId
            order.tableId = orderMO.tableId
            order.splitOrders = orderMO.splitOrders
            order.originalOrderId = orderMO.originalOrderId
            
            //subtotal
            order.subtotals = orderPriceSchema()
            order.subtotals?.subtotal = orderMO.orderPricingSubtotal
            order.subtotals?.discount = orderMO.orderPricingDiscount
            order.subtotals?.adjustments = orderMO.orderPricingAdjustments
            order.subtotals?.tax = orderMO.orderPricingTax
            
            order.subtotals?.taxComponents = taxComponents()
            order.subtotals?.taxComponents?.gst = orderMO.orderPricingTaxComponentGST
            order.subtotals?.taxComponents?.pst = orderMO.orderPricingTaxComponentPST
            order.subtotals?.taxComponents?.hst = orderMO.orderPricingTaxComponentHST

            order.subtotals?.total = orderMO.orderPricingTotal
            //
            
            //payment
            order.payment = paymentInformation()
            order.payment?.method = orderMO.paymentMethod 
            order.payment?.amount = orderMO.paymentAmount 
            order.payment?.giftCardTotal = orderMO.paymentGiftCardTotal 
            
            order.payment?.giftCards = [giftCardPayment]()
            if let paymenetGiftCards = orderMO.paymentGiftCards{
                paymenetGiftCards.forEach{giftCard in
                    var card = giftCardPayment()
                    card.cardId = giftCard["cardId"] as? String
                    card.programId = giftCard["programId"] as? String
                    card.redeemedAmount = giftCard["redeemedAmount"] as? Float
                }
            }
            
            order.payment?.quantityCards = [quantityCardPayment]()
            if let paymentQuantityCards = orderMO.paymentQuantityCards {
                paymentQuantityCards.forEach{quantityCard in
                    var card = quantityCardPayment()
                    card.cardId = quantityCard["cardId"] as? String
                    card.programId = quantityCard["programId"] as? String
                    card.redeemedQuantity = quantityCard["redeemedQuantity"] as? Int
                }
            }
            
            order.payment?.rounding = orderMO.paymentRounding
            order.payment?.received = orderMO.paymentReceived 
            order.payment?.cashGiven = orderMO.paymentCashGiven 
            order.payment?.change = orderMO.paymentChange 
            order.payment?.tips = orderMO.paymentTips 
            //
            
            order.dailyOrderNumber = Int(orderMO.dailyOrderNumber)
            order.uniqueOrderNumber = Int(orderMO.uniqueOrderNumber)
            order.createdBy = orderMO.createdBy
            order.createdAt = orderMO.createdAt as? Date
            
            //timeBucket
            order.timeBucket = timeComponents()
            order.timeBucket?.year = Int(orderMO.timeBucketYear)
            order.timeBucket?.month = Int(orderMO.timeBucketMonth)
            order.timeBucket?.day = Int(orderMO.timeBucketDay)
            order.timeBucket?.hour = Int(orderMO.timeBucketHour)
            //
            
            order.updatedBy = orderMO.updatedBy
            order.updatedAt = orderMO.updatedAt as? Date
            
            order.items = [orderItem]()
            if let orderItems = orderMO.items{
                orderItems.forEach{itemNSMO in
                    let itemMO = itemNSMO as! OrderItems
                    var item = orderItem()
                    
                    item.itemNumber = itemMO.itemNumber as Decimal?

                    item.product = orderProduct()
                    item.product?._id = itemMO.orderProductId as? String
                    item.product?.name = itemMO.orderProductName as? String
                    item.product?.sizes = [productSize]()
                    if let orderProductSizes = itemMO.orderProductSizes {
                        orderProductSizes.forEach{size in
                            var prodSize = productSize()
                            prodSize.code = size["code"] as? String
                            prodSize.price = size["price"] as? Float
                            prodSize.label = size["label"] as? String
                            prodSize.sortPosition = size["sortPosition"] as? Int16
                            item.product?.sizes?.append(prodSize)
                        }
                    }
                    
                    item.seatNumber = Int(itemMO.seatNumber)
                    item.sentToKitchen = itemMO.sentToKitchen
                    item.isRedeemItem = itemMO.isRedeemItem
                    item.isManualRedeem = itemMO.isManualRedeem
                    item.variablePrice = itemMO.variablePrice
                    item.unitBasedPrice = itemMO.unitBasedPrice
                    item.unitBasedPriceQuantity = itemMO.unitBasedPriceQuantity
                    item.unitPrice = itemMO.unitPrice
                    item.unitLabel = itemMO.unitLabel
                    item.notes = itemMO.notes as? [String]
                    
                    if let itemSize = itemMO.size {
                        var prodSize = productSize()
                        prodSize.code = itemSize["code"] as? String
                        prodSize.price = itemSize["price"] as? Float
                        prodSize.label = itemSize["label"] as? String
                        prodSize.sortPosition = itemSize["sortPosition"] as? Int16
                        item.size = prodSize
                    }
                    
                    item.quantity = Int(itemMO.quantity)
                    item.redeemed = Int(itemMO.redeemed)
                    item.total = itemMO.total
                    
                    item.addOns = [orderItemAddOns]()
                    if let itemAddOns = itemMO.addOns {
                        itemAddOns.forEach{addOnNS in
                            let addOnMO = addOnNS as! OrderItemAddOns
                            var itemAddOn = orderItemAddOns()

                            itemAddOn._id = addOnMO.id
                            itemAddOn.name = addOnMO.name
                            itemAddOn.price = addOnMO.price

                            item.addOns!.append(itemAddOn)
                        }
                    }
                    order.items!.append(item)
                }
            }

            self = order
        }
    }
    
    func saveToCoreData(enableChangeLog: Bool = true) {
        //TO-DO: check to see if object is complete and ready for save
        DispatchQueue.main.async{
            let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let orderEntity = NSEntityDescription.entity(forEntityName: "Order", in: managedContext)!
            let orderItemEntity = NSEntityDescription.entity(forEntityName: "OrderItems", in: managedContext)!
            let orderItemAddOnEntity = NSEntityDescription.entity(forEntityName: "OrderItemAddOns", in: managedContext)!
            
            if let existingOrder = NIMBUS.OrderManagement?.getOrder(byId: self._id ?? " "){
                //order exists
                managedContext.delete(existingOrder)
            }
            
            var order: Order = NSManagedObject(entity: orderEntity, insertInto: managedContext) as! Order
            
            order.id = self._id
            order.businessId = self.businessId
            order.locationId = self.locationId
            order.status = self.status
            
            //orderInformation
            if let orderType = self.orderInformation?.orderType {order.orderInfoOrderType  = orderType}
            if let orderName = self.orderInformation?.orderName {order.orderInfoOrderName  = orderName}
            if let orderPhone = self.orderInformation?.orderPhone {order.orderInfoOrderPhone  = orderPhone}
            if let unitNumber = self.orderInformation?.unitNumber {order.orderInfoUnitNumber  = unitNumber}
            if let buzzerNumber = self.orderInformation?.buzzerNumber {order.orderInfoBuzzerNumber  = buzzerNumber}
            if let streetNumber = self.orderInformation?.streetNumber {order.orderInfoStreetNumber  = streetNumber}
            if let street = self.orderInformation?.street {order.orderInfoStreet  = street}
            if let city = self.orderInformation?.city {order.orderInfoCity  = city}
            if let postalCode = self.orderInformation?.postalCode {order.orderInfoPostalCode  = postalCode}
            if let instructions = self.orderInformation?.instructions {order.orderInfoInstructions  = instructions}
            //
            
            order.customerId = self.customerId
            order.waiterId = self.waiterId
            order.tableId = self.tableId
            order.splitOrders = self.splitOrders
            order.originalOrderId = self.originalOrderId
            
            //subtotal
            if let subtotal = self.subtotals?.subtotal {
                order.orderPricingSubtotal = subtotal
            }
            if let discount = self.subtotals?.discount {order.orderPricingDiscount = discount}
            if let adjustments = self.subtotals?.adjustments {order.orderPricingAdjustments = adjustments}
            if let tax = self.subtotals?.tax {order.orderPricingTax = tax}
            if let taxComponents = self.subtotals?.taxComponents {
                order.orderPricingTaxComponentGST = taxComponents.gst ?? 0.0
                order.orderPricingTaxComponentPST = taxComponents.pst ?? 0.0
                order.orderPricingTaxComponentHST = taxComponents.hst ?? 0.0
            }
            if let total = self.subtotals?.total {order.orderPricingTotal = total}
            //
            
            //payment
            if let method = self.payment?.method { order.paymentMethod = method}
            if let amount = self.payment?.amount { order.paymentAmount = amount}
            if let giftCardTotal = self.payment?.giftCardTotal { order.paymentGiftCardTotal = giftCardTotal}
            if let giftCards = self.payment?.giftCards {
                order.paymentGiftCards = giftCards.map{$0.returnAsDictionary()}
            }
            if let quantityCards = self.payment?.quantityCards {
                order.paymentQuantityCards = quantityCards.map{$0.returnAsDictionary()}
            }
            if let rounding = self.payment?.rounding { order.paymentRounding = rounding}
            if let received = self.payment?.received { order.paymentReceived = received}
            if let cashGiven = self.payment?.cashGiven { order.paymentCashGiven = cashGiven}
            if let change = self.payment?.change { order.paymentChange = change}
            if let tips = self.payment?.tips { order.paymentTips = tips}
            //
            
            order.dailyOrderNumber = Int32(self.dailyOrderNumber ?? 0)
            order.uniqueOrderNumber = Int64(self.uniqueOrderNumber ?? 0)
            order.createdBy = self.createdBy
            order.createdAt = self.createdAt as NSDate?
            
            //timeBucket
            if let year = self.timeBucket?.year {order.timeBucketYear = Int32(year)}
            if let month = self.timeBucket?.month {order.timeBucketMonth = Int32(month)}
            if let day = self.timeBucket?.day {order.timeBucketDay = Int32(day)}
            if let hour = self.timeBucket?.hour {order.timeBucketHour = Int32(hour)}
            //
            
            order.updatedBy = self.updatedBy
            order.updatedAt = self.updatedAt as NSDate?
            
            self.items?.forEach{item in
                let itemMO = NSManagedObject(entity: orderItemEntity, insertInto: managedContext) as! OrderItems
                
                itemMO.order = order
                if let itemNumber = item.itemNumber {itemMO.itemNumber = itemNumber as NSDecimalNumber}
                if let product = item.product {
                    itemMO.orderProductId = product._id
                    itemMO.orderProductName = product.name
                    if let productSizes = product.sizes {
                        itemMO.orderProductSizes = productSizes.map{ $0.asDictionary() }
                    }
                }
                if let seatNumber = item.seatNumber {itemMO.seatNumber = Int32(seatNumber)}
                if let sentToKitchen = item.sentToKitchen {itemMO.sentToKitchen = sentToKitchen}
                if let isRedeemItem = item.isRedeemItem {itemMO.isRedeemItem = isRedeemItem}
                if let isManualRedeem = item.isManualRedeem {itemMO.isManualRedeem = isManualRedeem}
                if let variablePrice = item.variablePrice {itemMO.variablePrice = variablePrice}
                if let unitBasedPrice = item.unitBasedPrice {itemMO.unitBasedPrice = unitBasedPrice}
                if let unitBasedPriceQuantity = item.unitBasedPriceQuantity {itemMO.unitBasedPriceQuantity = unitBasedPriceQuantity}
                if let unitPrice = item.unitPrice {itemMO.unitPrice = unitPrice}
                if let unitLabel = item.unitLabel {itemMO.unitLabel = unitLabel}
                if let notes = item.notes {itemMO.notes = notes as [String]}
                
                if let size = item.size {itemMO.size = size.asDictionary()}
                
    //            if let quantity = item.quantity {itemMO.quantity = Int32(quantity)}
                itemMO.quantity = Int32(item.quantity)
                if let redeemed = item.redeemed {itemMO.redeemed = Int32(redeemed)}
                if let total = item.total {itemMO.total = total}

                if let addOns = item.addOns {
                    addOns.forEach{addOn in
                        let addOnMO = NSManagedObject(entity: orderItemAddOnEntity, insertInto: managedContext) as! OrderItemAddOns
                        addOnMO.orderItem = itemMO
                        addOnMO.id = addOn._id
                        addOnMO.name = addOn.name
                        addOnMO.price = addOn.price ?? 0.00
                        addOnMO.orderId = order.id
                        addOnMO.itemNumber = item.itemNumber as? NSDecimalNumber
                    }
                }
            }
            
            do {
                NIMBUS.Data?.loggingCoreDataChangesEnabled = enableChangeLog
                try managedContext.save()
                NIMBUS.Data?.loggingCoreDataChangesEnabled = true
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func formattedUniqueOrderNumber() -> String {
        let rawString = String(self.uniqueOrderNumber ?? 1)
        return rawString.insertingReverse(separator: " ", every: 3)
    }
    
    func formattedDailyOrderNumber() -> String {
        let rawString = String(self.dailyOrderNumber ?? 1)
        return ("#" + rawString.insertingReverse(separator: "-", every: 3))
    }
    
    func formattedCreatedDate(includeTime: Bool = true, longDate: Bool = false) -> String {
        if let createdAt = self.createdAt as? NSDate {
            return createdAt.toDateStringWithTime(dateStyle: .short , timeStyle: .short)
        } else {
            return ""
        }
    }
    
    func getOccupiedSeatNumbers() -> [Int] {
        var seats = [Int]()
        if let allOrderItems = self.items {
            allOrderItems.forEach{item in
                if let seatNumber = item.seatNumber {
                    if !seats.contains(seatNumber) {
                        seats.append(seatNumber)
                    }
                }
            }
        }
        seats = seats.sorted(by: {$0 < $1}) // ascending seat number sort
        return seats
    }
    
    func getNumberOfOccupiedSeats() -> Int {
        return getOccupiedSeatNumbers().count
    }
    
    func getOrderItemsForSeat(seatNumber: Int ) -> [orderItem] {
        var seatItems = [orderItem]()
        if let allOrderItems = self.items {
            seatItems = allOrderItems.filter({$0.seatNumber == seatNumber})
        }
        seatItems.sorted(by: {($1.itemNumber ?? 0.0) > ($0.itemNumber ?? 0.0)})
        return seatItems
    }
}
