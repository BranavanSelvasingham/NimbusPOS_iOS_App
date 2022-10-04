//
//  money.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-02.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

extension Float {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
    
    func toString(asMoney: Bool, toDecimalPlaces: Int) -> String{
        let amount = self.rounded(toPlaces: toDecimalPlaces)
        let numberFormat = "%." + String(toDecimalPlaces) + "f"
        
        if asMoney {
            return "$ " + String(format: numberFormat, amount)
        } else {
            return String(format: numberFormat, amount)
        }
    }
}

struct money {
    let exactAmount: Float
    let paymentType: String
    let rounding: Float
    let roundedTotal: Float
    
    init(exactAmount: Float, paymentType: String){
        self.exactAmount = exactAmount.rounded(toPlaces: 2)
        self.paymentType = paymentType
        
        if self.paymentType == AcceptedPaymentMethods.cash.key {
            let pennies = Int(self.exactAmount*100) % 5
            if pennies > 0 && pennies <= 2 {
                self.rounding = Float(-pennies)/100
                self.roundedTotal = self.exactAmount + rounding.rounded(toPlaces: 2)
            } else if pennies >= 3 {
                self.rounding = Float(5 - pennies)/100
                self.roundedTotal = self.exactAmount + rounding.rounded(toPlaces: 2)
            } else {
                self.rounding = 0.00
                self.roundedTotal = self.exactAmount
            }
        } else {
            self.rounding = 0.00
            self.roundedTotal = self.exactAmount
        }
    }
}
