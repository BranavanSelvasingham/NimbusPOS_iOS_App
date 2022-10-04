//
//  nimbusReportsFunctions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-26.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class nimbusReportsFunctions: NimbusBase {
    override init(master: NimbusFramework?){
        super.init(master: master)
    }
    
    var generatedDailyReportValues: dailyReportComponents?
    
    func getDailyReportValuesFor(reportDate: Date) -> dailyReportComponents {
        let report = dailyReportComponents(reportDate: reportDate)
        return report
    }
    
    let AggregateTypes = aggregateByTypes()
    
    struct aggregateByTypes {
        let all = "ALL"
        let cash = AcceptedPaymentMethods.cash.key
        let card = AcceptedPaymentMethods.card.key
        let giftCard = "GIFTCARD"
    }
    
    struct dailyReportComponents {
        let reportDate: Date
        var fullSummary: reportComponents?
        var cashSummary: reportComponents?
        var creditDebitCardSummary: reportComponents?
        var giftCardSummary: reportComponents?
        
        init(reportDate: Date){
            self.reportDate = reportDate
        }
    }
    
    struct reportComponents {
        let grandTotal: Float
        let taxes: taxComponents
        let ordersCount: Int
        
        init(grandTotal: Float, taxes: taxComponents, ordersCount: Int){
            self.grandTotal = grandTotal
            self.taxes = taxes
            self.ordersCount = ordersCount
        }
    }
    
    func buildFetchExpression(expressionName: String, function: String, arguments: [NSExpression], expressionResultType: NSAttributeType) ->NSExpressionDescription{
        // Create an expression description
        var expressionDescription = NSExpressionDescription()
        // Name the column
        expressionDescription.name = expressionName
        // Use an expression to specify what aggregate action we want to take and on which column.
        expressionDescription.expression = NSExpression(forFunction: function, arguments: arguments)
        // Specify the return type we expect
        expressionDescription.expressionResultType = .floatAttributeType
        
        return expressionDescription
    }
    
    func buildReportComponentsFetchExpressions() -> [NSExpressionDescription] {

        var expressionDescriptions = [NSExpressionDescription]()
        
        //** GRAND TOTAL
        expressionDescriptions.append(buildFetchExpression(expressionName: "GrandTotal",
                                                           function: "sum:",
                                                           arguments: [NSExpression(forKeyPath: "orderPricingTotal")],
                                                           expressionResultType: .floatAttributeType))
        
        //** ORDER COUNT
        expressionDescriptions.append(buildFetchExpression(expressionName: "OrderCount",
                                                           function: "count:",
                                                           arguments: [NSExpression(forKeyPath: "id")],
                                                           expressionResultType: .integer16AttributeType))
        
        //** HST TAXES TOTAL
        expressionDescriptions.append(buildFetchExpression(expressionName: "HSTTaxes",
                                                           function: "sum:",
                                                           arguments: [NSExpression(forKeyPath: "orderPricingTaxComponentHST")],
                                                           expressionResultType: .floatAttributeType))

        //** GST TAXES TOTAL
        expressionDescriptions.append(buildFetchExpression(expressionName: "GSTTaxes",
                                                           function: "sum:",
                                                           arguments: [NSExpression(forKeyPath: "orderPricingTaxComponentGST")],
                                                           expressionResultType: .floatAttributeType))
        
        //** PST TAXES TOTAL
        expressionDescriptions.append(buildFetchExpression(expressionName: "PSTTaxes",
                                                           function: "sum:",
                                                           arguments: [NSExpression(forKeyPath: "orderPricingTaxComponentPST")],
                                                           expressionResultType: .floatAttributeType))
        
        //** TAXES TOTAL
        expressionDescriptions.append(buildFetchExpression(expressionName: "TotalTaxes",
                                                           function: "sum:",
                                                           arguments: [NSExpression(forKeyPath: "orderPricingTax")],
                                                           expressionResultType: .floatAttributeType))
        
        //** GIFT CARD REDEMPTIONS
        expressionDescriptions.append(buildFetchExpression(expressionName: "GiftCardRedemptions",
                                                           function: "sum:",
                                                           arguments: [NSExpression(forKeyPath: "paymentGiftCardTotal")],
                                                           expressionResultType: .floatAttributeType))
        
        return expressionDescriptions
    }
    
    func buildReportFetchRequest(reportDate: Date, aggregateBy: String) -> NSFetchRequest<NSFetchRequestResult> {
        var expressionDescriptions = buildReportComponentsFetchExpressions()
        
        var fetchPredicate: NSPredicate?
        var compoundPredicate = [NSPredicate]()
        
        let startOfReportDate = Calendar.current.startOfDay(for: reportDate)
        let startOfReportDatePlus1Day = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: reportDate)!)
        
        compoundPredicate.append(NSPredicate(format: "createdAt >= %@", startOfReportDate as NSDate))
        compoundPredicate.append(NSPredicate(format: "createdAt < %@", startOfReportDatePlus1Day as NSDate))
        
        if aggregateBy == AggregateTypes.cash {
            compoundPredicate.append(NSPredicate(format: "paymentMethod =%@" , aggregateBy))
        } else if aggregateBy == AggregateTypes.card {
            compoundPredicate.append(NSPredicate(format: "paymentMethod =%@" , aggregateBy))
        } else if aggregateBy == AggregateTypes.giftCard {
            compoundPredicate.append(NSPredicate(format: "paymentGiftCardTotal >%i", 0))
        }

        fetchPredicate = NSCompoundPredicate(type: .and, subpredicates: compoundPredicate)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Order")
        request.resultType = .dictionaryResultType
        request.predicate = fetchPredicate
        request.propertiesToFetch = expressionDescriptions
        return request
    }
    
    func fetchReportResults(reportDate: Date, aggregateBy: String) -> [String:AnyObject]?{
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = buildReportFetchRequest(reportDate: reportDate, aggregateBy: aggregateBy)
        
        // Our result is going to be an array of dictionaries.
        var results:[[String:AnyObject]]?
        
        // Perform the fetch. This is using Swfit 2, so we need a do/try/catch
        do {
            results = try managedContext.fetch(request) as? [[String:AnyObject]]
        } catch _ {
            // If it fails, ensure the array is nil
            results = nil
        }

        return results?.first
    }
    
    func calculateReportComponents (aggregateData: [String: AnyObject]?) -> reportComponents {
        var grandTotal: Float = 0
        var taxes: taxComponents = taxComponents()
        var ordersCount: Int = 0
        
        if let aggregateData = aggregateData {
            grandTotal = Float(aggregateData["GrandTotal"] as? NSNumber ?? 0)
            
            ordersCount = Int(aggregateData["OrderCount"] as? Int ?? 0)
            
            let hstTotal: Float = Float(aggregateData["HSTTaxes"] as? NSNumber ?? 0)
            let gstTotal: Float = Float(aggregateData["GSTTaxes"] as? NSNumber ?? 0)
            let pstTotal: Float = Float(aggregateData["PSTTaxes"] as? NSNumber ?? 0)
            taxes = taxComponents(gst: gstTotal, pst: pstTotal, hst: hstTotal)
        }
        
        let report = reportComponents(grandTotal: grandTotal, taxes: taxes, ordersCount: ordersCount)

        return report
    }
    
    func getValuesForComponent(reportDate: Date, aggregateBy: String)-> reportComponents {
        let aggregateData = fetchReportResults(reportDate: reportDate, aggregateBy: aggregateBy)
        return calculateReportComponents(aggregateData: aggregateData)
    }
    
    func calculateReportComponentsForGiftCards(reportDate: Date, aggregateBy: String) -> reportComponents {
        let aggregateData = fetchReportResults(reportDate: reportDate, aggregateBy: aggregateBy)
        
        var grandTotal: Float = 0
        var ordersCount: Int = 0
        
        if let aggregateData = aggregateData {
            grandTotal = aggregateData["GiftCardRedemptions"] as? Float ?? 0
            ordersCount = aggregateData["OrderCount"] as? Int ?? 0
        }
        
        let report = reportComponents(grandTotal: grandTotal, taxes: taxComponents(), ordersCount: ordersCount)
        return report
    }
    
    func generatedDailyReportValues(reportDate: Date) -> dailyReportComponents {
        generatedDailyReportValues = dailyReportComponents(reportDate: reportDate)
        
        generatedDailyReportValues?.fullSummary = getValuesForComponent(reportDate: reportDate, aggregateBy: AggregateTypes.all)
        generatedDailyReportValues?.cashSummary = getValuesForComponent(reportDate: reportDate, aggregateBy: AggregateTypes.cash)
        generatedDailyReportValues?.creditDebitCardSummary = getValuesForComponent(reportDate: reportDate, aggregateBy: AggregateTypes.card)
        generatedDailyReportValues?.giftCardSummary = calculateReportComponentsForGiftCards(reportDate: reportDate, aggregateBy: AggregateTypes.giftCard)

        return generatedDailyReportValues!
    }
    
}
