//
//  taxes.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-05.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

private let AllTaxCategories: [taxCategory] = [
        taxCategory(key: "NOT_TAXED", value: "notTaxes", label: "Not Taxes", rule: "notTaxed", taxable: false, country: "CA", region: "ALL", description: "This item is non-taxable, whether sold individually or as part of a larger order."),
        taxCategory(key: "GST_TAX", value: "gstTax", label: "GST Tax", rule: "gstTax", taxable: true, country: "CA", region: "ALL", description: "This item is gst-taxable, whether sold individually or as part of a larger order. No further (provincial) taxes will be applied for these items."),
        taxCategory(key: "RETAIL_TAX", value: "retailTax", label: "Retail Tax", rule: "retailTax", taxable: true, country: "CA", region: "ON", description: "This is a retail item and will be taxed at the standard retail tax rate."),
        taxCategory(key: "PREPARED_MEAL", value: "preparedMeal", label: "Prepared Food and Beverages", rule: "preparedMeal", taxable: true, country: "CA", region: "ON", description: "This item is considered a prepared meal or beverage and a total order amount of less than $4 will carry only a 5% tax rate (HST 13% - 8% rebate). Orders larger than $4 will be taxed ar standard retail tax (HST 13%)."),
        taxCategory(key: "WHOLESALE_PASTRY", value: "wholesalePastry", label: "Wholesale Pastry", rule: "wholesalePastry", taxable: true, country: "CA", region: "ON", description: "This is a pastry item and can be considered a wholesale pastry item when sold in quantities of 6 or more in one order, in which case these items will not be tax-free. Also an order total of less than $4 consisting of these items will also be tax free. Under all other circumstances, it will be taxed at retail tax rate.")
]

private let AllTaxComponentRatesByGeography: [String: [String: [TaxComponentRates]]] =
    ["CA":
        [
            "AB": [TaxComponentRates(key: "gst", label: "GST", rate: 5.00)],
            "ON": [TaxComponentRates(key: "gst", label: "GST", rate: 5.00), TaxComponentRates(key: "hst", label: "HST", rate: 13.00)]
        ]
    ]

private let AllCountryTaxFunctions: [String:[String: (orderItem)->Bool]] =
    [ "CA":
        [
            "isProductRetailTaxable": {(item: orderItem) -> Bool in
                let taxRule = item.taxRule
                return getTaxRule(withKey: taxRule!)!.rule == "retailTax" || (taxRule == "TAXED")
            },
            "isProductGSTTaxable": {(item: orderItem) -> Bool in
                let taxRule = item.taxRule
                return getTaxRule(withKey: taxRule!)!.rule == "gstTax"
            }
        ]
    ]

//Top-level struct//
struct TaxRules {
    var CA = CanadaTaxRules()
}

struct CanadaTaxRules {
    var countryName: String = "Canada"
    var allTaxLabels = ["GST", "PST", "HST"]
    var AB = RegionalTaxRules(regionName: "Alberta",
                              determineTax: AlbertaTaxes)
    
    var ON = RegionalTaxRules(regionName: "Ontario",
                              determineTax: OntarioTaxes)

}

struct taxComponents: Codable {
    var gst: Float?
    var pst: Float?
    var hst: Float?
    
    init(gst: Float? = nil, pst: Float? = nil, hst: Float? = nil) {
        self.gst = gst
        self.pst = pst
        self.hst = hst
    }
}

struct RegionalTaxRules {
    let regionName: String
    let determineTax: () -> (Float, taxComponents)
}

struct TaxComponentRates {
    let key: String
    let label: String
    let rate: Float
}

struct taxCategory {
    let key: String
    let value: String
    let label: String
    let rule: String
    let taxable: Bool
    let country: String
    let region: String
    let description: String
}

private func AlbertaTaxes () -> (Float, taxComponents) {
    var totalTaxes : Float = 0.00
    
    return (totalTaxes, taxComponents())
}

private func OntarioTaxes () -> (Float, taxComponents) {
    func isProductPreparedMeal(item: orderItem) -> Bool {
        let taxRule = item.taxRule
        return getTaxRule(withKey: taxRule!)!.rule == "preparedMeal"
    }
    
    func isProductWholesalePastry(item: orderItem) -> Bool {
        let taxRule = item.taxRule
        return getTaxRule(withKey: taxRule!)!.rule == "wholesalePastry"
    }
    
    let orderItemsTaxable : [orderItem] = getTaxableItems()
    let subtotalOfAllTaxable: Float = orderItemsTaxable.reduce(0.00, addItemTotalToSubtotal)
    
    let retailTax = getTaxRate(country: "CA", region: "ON", taxKey: "hst")
    let gstTaxRate = getTaxRate(country: "CA", region: "ON", taxKey: "gst")
    
    var gstTaxes: Float = 0.00
    var hstTaxes: Float = 0.00
    var totalTaxes: Float = 0.00
    
    //gst only items
    let gstTaxItems = orderItemsTaxable.filter( AllCountryTaxFunctions["CA"]!["isProductGSTTaxable"]! )
    let gstTaxItemsSubtotal = gstTaxItems.reduce(0.00, addItemTotalToSubtotal)
    gstTaxes = calculateDiscountedAdjustedTax(forAmount: gstTaxItemsSubtotal, withTaxRate: gstTaxRate)
    
    totalTaxes += gstTaxes
    
    //retail items
    let retailTaxItems = orderItemsTaxable.filter( AllCountryTaxFunctions["CA"]!["isProductRetailTaxable"]! )
    let retailSubtotal = retailTaxItems.reduce(0.00, addItemTotalToSubtotal)
    
    totalTaxes += calculateDiscountedAdjustedTax(forAmount: retailSubtotal, withTaxRate: retailTax)
    
    //ON Specific tax rules
    let preparedMealItems = orderItemsTaxable.filter( isProductPreparedMeal )
    let preparedMealSubtotal = preparedMealItems.reduce(0.00, addItemTotalToSubtotal)
    
    let wholesalePastryItems = orderItemsTaxable.filter( isProductWholesalePastry )
    let wholesalePastrySubtotal = wholesalePastryItems.reduce(0.00, addItemTotalToSubtotal)
    let wholesalePastryQuantity = wholesalePastryItems.reduce(0, {(quantity, item) -> Int in
        return quantity + (item.quantity ?? 0)
    })
    
    if (preparedMealSubtotal + wholesalePastrySubtotal)<=4.00 {
        let taxAdd = calculateDiscountedAdjustedTax(forAmount: preparedMealSubtotal, withTaxRate: gstTaxRate)
        gstTaxes += taxAdd
        totalTaxes += taxAdd
        
        if wholesalePastryQuantity < 6 {
            let taxAdd2 = calculateDiscountedAdjustedTax(forAmount: wholesalePastrySubtotal, withTaxRate: gstTaxRate)
            gstTaxes += taxAdd2
            totalTaxes += taxAdd2
        }
    } else {
        totalTaxes += calculateDiscountedAdjustedTax(forAmount: preparedMealSubtotal, withTaxRate: retailTax)
        
        if wholesalePastryQuantity < 6 {
            totalTaxes += calculateDiscountedAdjustedTax(forAmount: wholesalePastrySubtotal, withTaxRate: retailTax)
        }
    }
    
    hstTaxes = totalTaxes - gstTaxes

    return (totalTaxes, taxComponents(gst: gstTaxes, hst: hstTaxes))
}

private func getTaxRule(withKey key: String) -> taxCategory? {
    return AllTaxCategories.first(where: {$0.key == key})
}

private func getTaxRate(country: String, region: String, taxKey: String) -> Float {
    let taxRates = AllTaxComponentRatesByGeography[country]![region]
    let taxRate = taxRates?.first{ $0.key == taxKey}
    return taxRate?.rate ?? 0.00
}

private func isProductTaxable(item: orderItem) -> Bool {
    return (getTaxRule(withKey: item.taxRule ?? "" )?.taxable) ?? false
}

private func getTaxableItems() -> [orderItem]{
    let allOrderItems = NIMBUS.OrderCreation?.orderItems
    return allOrderItems?.filter(isProductTaxable) ?? []
}

private func addItemTotalToSubtotal(subtotal: Float, item: orderItem) -> Float {
    return subtotal + (item.total ?? 0.00)
}

private func calculateDiscountedAdjustedTax(forAmount amount: Float, withTaxRate taxRate: Float) -> Float {
    let orderDiscountPercent = NIMBUS.OrderCreation?.getOrderDiscountPercent() ?? 0
    let orderAdjustmentPercent = NIMBUS.OrderCreation?.getAdjustmentPercent() ?? 0
    
    let amountDiscounted = amount * (1.00 - Float(orderDiscountPercent)/100)
    let amountDiscountedAdjusted = amountDiscounted * (1.00 - Float(orderAdjustmentPercent)/100)
    let amountDiscountedAdjustedTaxed = amountDiscountedAdjusted * (taxRate / 100)
    
    return amountDiscountedAdjustedTaxed
}
