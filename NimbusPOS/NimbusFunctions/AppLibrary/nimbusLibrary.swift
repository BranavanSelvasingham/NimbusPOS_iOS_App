//
//  nimbusLibrary.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-06.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation


class nimbusLibrary: NimbusBase {
    let Taxes = TaxRules()
//    let OrderTypes = orderTypes()
    let OrderStatus = orderStatus()
    let LoyaltyPrograms = loyaltyProgramStandards()
    
    override init (master: NimbusFramework?){
        super.init(master: master)
    }
    
//    struct orderTypes{
//        let Express = "Express"
//        let DineIn = "Dine-In"
//        let TakeOut = "Take-Out"
//        let Delivery = "Delivery"
//    }
    
    struct orderStatus {
        let Created = "Created"
        let Completed = "Completed"
        let Cancelled = "Cancelled"
    }

    struct loyaltyProgramStandards {
        let programAsProductCategoryLabel = "_Loyalty_Programs"
        let Types = loyaltyProgramTypes()
    }
    
    struct loyaltyProgramTypes {
        let Quantity = "Quantity"
        let Coupon = "Percentage"
        let GiftCard = "Amount"
        let Tally = "Tally"
    }
}

enum _OrderStatus: String {
    case Created = "Created"
    case Completed = "Completed"
    case Cancelled = "Cancelled"
}

enum _LoyaltyProgramTypes: String {
    case Quantity = "Quantity"
    case Coupon = "Percentage"
    case GiftCard = "Amount"
    case Tally = "Tally"
}

enum _OrderTypes: String {
    case Express = "Express"
    case DineIn =  "Dine-In"
    case TakeOut = "Take-Out"
    case Delivery = "Delivery"
}

enum _OpenOrderModes {
    case NotOpenOrder
    case UpdateOpenOrder
    case CheckoutOpenOrder
}

