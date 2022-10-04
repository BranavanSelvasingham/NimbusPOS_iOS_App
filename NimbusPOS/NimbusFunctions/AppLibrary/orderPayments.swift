//
//  orderPayments.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-02.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

struct paymentMethodAttributes {
    let key: String
    let label: String
    let icon: String
}

struct orderPaymentMethods {
    let cash: paymentMethodAttributes
    let card: paymentMethodAttributes
    let loyalty: paymentMethodAttributes
    var defaultMethod: paymentMethodAttributes{
        get {
            return self.card
        }
    }
}

var AcceptedPaymentMethods = orderPaymentMethods(cash: paymentMethodAttributes(key:"cash", label: "Cash", icon: ""),
                                                 card: paymentMethodAttributes(key:"card", label: "Card", icon: ""),
                                                 loyalty: paymentMethodAttributes(key:"loyalty", label: "Loyalty", icon: ""))
