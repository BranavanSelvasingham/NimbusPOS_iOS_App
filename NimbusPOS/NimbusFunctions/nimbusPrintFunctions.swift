//
//  nimbusPrintFunctions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-25.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class nimbusPrintFunctions: NimbusBase {
    override init(master: NimbusFramework?){
        super.init(master: master)
    }
    
    let PrinterManager = nimbusPrinterFunctions(master: nil)
    
    private func getBusinessHeader(inclLocationName: Bool = false) -> [receiptLineItem]{
        var businessHeader = [receiptLineItem]()
        
        let businessName = NIMBUS.Business?.getBusinessName() ?? " "
        
        let locationName = NIMBUS.Location?.getLocationName()
        let locationAddress = NIMBUS.Location?.getLocationAddress()
        
        let businessNameLineItem = receiptLineItem(centerText: receiptText(text: businessName, fontSize: 2))
        let locationNameLineItem = receiptLineItem(centerText: receiptText(text: locationName))
        let locationStreetLineItem = receiptLineItem(centerText: receiptText(text: locationAddress?.street))
        let locationCityLineItem = receiptLineItem(centerText: receiptText(text: locationAddress?.city))
        
        businessHeader.append(businessNameLineItem)
        if inclLocationName == true {
            businessHeader.append(locationNameLineItem)
        }
        businessHeader.append(locationStreetLineItem)
        businessHeader.append(locationCityLineItem)
        
        return businessHeader
    }
    
    private func getOrderInfoHeader(order: orderSchema) -> [receiptLineItem]{
        var orderInfo = [receiptLineItem]()
        
        let orderDateAndTime = order.formattedCreatedDate(includeTime: true, longDate: false)
        let orderDateAndTimeLineItem = receiptLineItem(centerText: receiptText(text: orderDateAndTime))
        let orderNumber = order.formattedDailyOrderNumber()
        let orderNumberLineItem = receiptLineItem(rightText: receiptText(text: orderNumber, fontSize: 2, inversion: true))
        
        orderInfo.append(orderDateAndTimeLineItem)
        orderInfo.append(receiptLineItem(blankLine: true))
        orderInfo.append(orderNumberLineItem)
        orderInfo.append(receiptLineItem(horizontalLine: true, horizontalLineStyle: 2))
        
        return orderInfo
    }
    
    private func getOrderTableAndWaiter(order: orderSchema) -> [receiptLineItem] {
        var tableAndWaiterInfo = [receiptLineItem]()
        
        let orderDateAndTime = order.formattedCreatedDate(includeTime: true, longDate: false)
        let orderDateAndTimeLineItem = receiptLineItem(centerText: receiptText(text: orderDateAndTime))
        
        let table = NIMBUS.Tables?.getTableById(tableId: order.tableId ?? " ")
        let tableLabel = "Table: " + (table?.tableLabel ?? "?")
        
        let orderNumber = order.formattedDailyOrderNumber()
        let orderTableAndNumberLineItem = receiptLineItem(leftText: receiptText(text: tableLabel, fontSize: 2), rightText: receiptText(text: orderNumber, fontSize: 2, inversion: true))
        
        let waiter = NIMBUS.Employees?.getEmployeeById(employeeId: order.waiterId ?? " ")
        let waiterName = "by: " + (waiter?.name ?? "?")
        let waiterLineItem = receiptLineItem(leftText: receiptText(text: waiterName, fontSize: 1, inversion: false))
        
        tableAndWaiterInfo.append(orderDateAndTimeLineItem)
        tableAndWaiterInfo.append(receiptLineItem(blankLine: true))
        tableAndWaiterInfo.append(orderTableAndNumberLineItem)
        tableAndWaiterInfo.append(waiterLineItem)
        tableAndWaiterInfo.append(receiptLineItem(horizontalLine: true, horizontalLineStyle: 2))
        
        return tableAndWaiterInfo
    }
    
    private func getOrderItems(order: orderSchema, includeNotes: Bool = false) -> [receiptLineItem]{
        var orderItems = [receiptLineItem]()
        
        func getAddOnItems(addOn: orderItemAddOns) -> [receiptLineItem]{
            var addOnItems = [receiptLineItem]()
            
            let addOnDescription = "   + " + (addOn.name ?? "")
            let addOnPrice = addOn.price?.toString(asMoney: true, toDecimalPlaces: 2) ?? ""
            
            let addOnLine = receiptLineItem(leftText: receiptText(text: addOnDescription), rightText: receiptText(text: addOnPrice))
            addOnItems.append(addOnLine)
            
            return addOnItems
        }
        
        func getNotes(note: String) -> [receiptLineItem]{
            var noteItems = [receiptLineItem]()
            
            let noteText = "   * " + note
            
            let noteLine = receiptLineItem(leftText: receiptText(text: noteText))
            noteItems.append(noteLine)
            
            return noteItems
        }
        
        order.items?.forEach{ item in
            var productDescription = item.product?.name ?? ""
            var productPrice = item.size?.price?.toString(asMoney: true, toDecimalPlaces: 2) ?? ""
            
            let multipleSizes: Bool = (item.product?.sizes?.count ?? 1) > 1 ? true : false
            if multipleSizes == true {
                productDescription = (item.size?.code ?? "") + " - " + productDescription
            }
            
            productPrice = productPrice + " ea."
            
            productDescription = "x" + String(describing: item.quantity) + " " + productDescription
            
            let itemLine = receiptLineItem(leftText: receiptText(text: productDescription), rightText: receiptText(text: productPrice))
            orderItems.append(itemLine)
            
            item.addOns?.forEach{ addOn in
                orderItems.append(contentsOf: getAddOnItems(addOn: addOn))
            }
            
            if includeNotes == true {
                item.notes?.forEach{ note in
                    orderItems.append(contentsOf: getNotes(note: note))
                }
            }
        }
        
        return orderItems
    }
    
    private func getOrderTotals(order: orderSchema) -> [receiptLineItem]{
        var orderTotals = [receiptLineItem]()
        
        let firstHorizontalLine = receiptLineItem(horizontalLine: true, horizontalLineStyle: 1)
        orderTotals.append(firstHorizontalLine)
        
        let subtotalLineItem = receiptLineItem(leftText: receiptText(text: "Subtotal:"), rightText: receiptText(text: order.subtotals?.subtotal?.toString(asMoney: true, toDecimalPlaces: 2)))
        orderTotals.append(subtotalLineItem)
        
        if order.subtotals?.discount ?? 0 > Float(0.0) {
            let discountLineItem = receiptLineItem(leftText: receiptText(text: "Discount:"), rightText: receiptText(text: "-" + (order.subtotals?.discount?.toString(asMoney: true, toDecimalPlaces: 2))!))
            orderTotals.append(discountLineItem)
        }
        
        if order.subtotals?.adjustments ?? 0 > Float(0.0){
            let adjustmentLineItem = receiptLineItem(leftText: receiptText(text: "Adjustment:"), rightText: receiptText(text: "-" + (order.subtotals?.adjustments?.toString(asMoney: true, toDecimalPlaces: 2))!))
            orderTotals.append(adjustmentLineItem)
        }
        
        let taxLineItem = receiptLineItem(leftText: receiptText(text: "Tax:"), rightText: receiptText(text: order.subtotals?.tax?.toString(asMoney: true, toDecimalPlaces: 2)))
        orderTotals.append(taxLineItem)
        
        orderTotals.append(firstHorizontalLine)
        let totalLineItem = receiptLineItem(leftText: receiptText(text: "Total:", bold: true), rightText: receiptText(text: order.subtotals?.total?.toString(asMoney: true, toDecimalPlaces: 2), bold: true))
        orderTotals.append(totalLineItem)
        
        let secondHorizontalLine = receiptLineItem(horizontalLine: true, horizontalLineStyle: 1)
        orderTotals.append(secondHorizontalLine)
        
        return orderTotals
    }
    
    private func getOrderBarcode(order: orderSchema) -> [receiptLineItem]{
        var orderReferences = [receiptLineItem]()
        
        let uniqueOrderNumber = order.uniqueOrderNumber
        let uniqueOrderNumberString = order.formattedUniqueOrderNumber()
        
        let barcodeLineItem = receiptLineItem(centerText: receiptText(forBarcode: 1, barcodeText: String(describing: uniqueOrderNumber!)))
        let uniqueNumberLineItem = receiptLineItem(centerText: receiptText(text: "Order #: " + uniqueOrderNumberString))
        
        //            orderReferences.append(barcodeLineItem)
        
        orderReferences.append(receiptLineItem(blankLine: true))
        orderReferences.append(uniqueNumberLineItem)
        orderReferences.append(receiptLineItem(blankLine: true))
        
        return orderReferences
    }
    
    private func getOrderFooter() -> [receiptLineItem]{
        var orderFooter = [receiptLineItem]()
        
        let locationMessage = NIMBUS.Location?.getLocation()?.receiptMessage ?? ""
        
        let parsedLocationMessage = locationMessage.components(separatedBy: "|")
        parsedLocationMessage.forEach { line in
            let messageLine: String = String(line)
            let locationMessageLineItem = receiptLineItem(centerText: receiptText(text: messageLine))
            orderFooter.append(locationMessageLineItem)
        }
        
        return orderFooter
    }
    
    func printOrderReceipt(order: orderSchema, openDrawer: Bool = false ){
        var printLines = [receiptLineItem]()
        
        //Business Header
        printLines.append(contentsOf: getBusinessHeader())
        
        //Order Info Header
        printLines.append(contentsOf: getOrderInfoHeader(order: order))
        
        //Order Items
        printLines.append(contentsOf: getOrderItems(order: order))
        
        //Order Totals
        printLines.append(contentsOf: getOrderTotals(order: order))
        
        //Order Barcode
        printLines.append(contentsOf: getOrderBarcode(order: order))
        
        //Business Footer
        printLines.append(contentsOf: getOrderFooter())
        
        //Get appropriate printer
        let printer = getPrinterForFunction(functionName: "Receipt & Cash Drawer")
        
        //Send printObject to printer decoder
        let printReceipt = printObject(lines: printLines, openCashDrawer: openDrawer, destinationPrinter: printer)
        
        sendPrintObjectToPrinter(printObject: printReceipt)
    }
    
    func printOrderKitchenSlip(order: orderSchema){
        var printLines = [receiptLineItem]()
        
        printLines.append(receiptLineItem(blankLine: true))
        
        //Table and Waiter Headder
        printLines.append(contentsOf: getOrderTableAndWaiter(order: order))
        
        //Order Items
        printLines.append(contentsOf: getOrderItems(order: order, includeNotes: true))
        
        printLines.append(receiptLineItem(blankLine: true))
        
        //Get appropriate printer
        let printer = getPrinterForFunction(functionName: "Kitchen")
        
        //Send printObject to printer decoder
        let printReceipt = printObject(lines: printLines, openCashDrawer: false, destinationPrinter: printer)
        
        sendPrintObjectToPrinter(printObject: printReceipt)
    }
    
    func sendPrintObjectToPrinter(printObject: printObject ){
        PrinterManager.sendPrintJob(printJob: printObject)
    }
    
    func printDailyReport(reportDate: Date){
        var printLines = [receiptLineItem]()
        
        let reportValues = NIMBUS.Reports?.generatedDailyReportValues(reportDate: reportDate)
        
        func getReportHeader() -> [receiptLineItem]{
            var sectionLineItems = [receiptLineItem]()
            
            let reportDateText = reportDate.toFormattedString(includeTime: false, longDate: true)
            sectionLineItems.append(receiptLineItem(centerText: receiptText(text: "Report for:", fontStyle: 0, fontSize: 1, underline: false, bold: false, inversion: false)))
            sectionLineItems.append(receiptLineItem(centerText: receiptText(text: reportDateText, fontStyle: 0, fontSize: 2, underline: false, bold: true, inversion: false)))
            sectionLineItems.append(receiptLineItem(blankLine: true))
            
            let printedOnDate = Date().toFormattedString(includeTime: true, longDate: false)
            sectionLineItems.append(receiptLineItem(centerText: receiptText(text: "Printed on:" + printedOnDate, fontStyle: 2, fontSize: 1, underline: false, bold: false, inversion: false)))
            
            return sectionLineItems
        }
        
        func getGrandTotalsSection() -> [receiptLineItem]{
            var sectionLineItems = [receiptLineItem]()
            
            sectionLineItems.append(receiptLineItem(leftText: receiptText(text: "Grand Total:") , rightText: receiptText(text: reportValues?.fullSummary?.grandTotal.toString(asMoney: true, toDecimalPlaces: 2))))
            sectionLineItems.append(receiptLineItem(leftText: receiptText(text: "HST:") , rightText: receiptText(text: reportValues?.fullSummary?.taxes.hst?.toString(asMoney: true, toDecimalPlaces: 2))))
            sectionLineItems.append(receiptLineItem(leftText: receiptText(text: "GST:") , rightText: receiptText(text: reportValues?.fullSummary?.taxes.gst?.toString(asMoney: true, toDecimalPlaces: 2))))
            sectionLineItems.append(receiptLineItem(leftText: receiptText(text: "PST:") , rightText: receiptText(text: reportValues?.fullSummary?.taxes.pst?.toString(asMoney: true, toDecimalPlaces: 2))))
            sectionLineItems.append(receiptLineItem(leftText: receiptText(text: "Orders Count:") , rightText: receiptText(text: reportValues?.fullSummary?.ordersCount.toString())))
            
            return sectionLineItems
        }
        
        func getCashTotalsSection() -> [receiptLineItem]{
            var sectionLineItems = [receiptLineItem]()
            
            sectionLineItems.append(receiptLineItem(leftText: receiptText(text: "Cash Total:") , rightText: receiptText(text: reportValues?.cashSummary?.grandTotal.toString(asMoney: true, toDecimalPlaces: 2))))
            sectionLineItems.append(receiptLineItem(leftText: receiptText(text: "HST:") , rightText: receiptText(text: reportValues?.cashSummary?.taxes.hst?.toString(asMoney: true, toDecimalPlaces: 2))))
            sectionLineItems.append(receiptLineItem(leftText: receiptText(text: "GST:") , rightText: receiptText(text: reportValues?.cashSummary?.taxes.gst?.toString(asMoney: true, toDecimalPlaces: 2))))
            sectionLineItems.append(receiptLineItem(leftText: receiptText(text: "PST:") , rightText: receiptText(text: reportValues?.cashSummary?.taxes.pst?.toString(asMoney: true, toDecimalPlaces: 2))))
            sectionLineItems.append(receiptLineItem(leftText: receiptText(text: "Orders Count:") , rightText: receiptText(text: reportValues?.cashSummary?.ordersCount.toString())))
            
            return sectionLineItems
        }
        
        func getCreditAndDebitCardTotalsSection() -> [receiptLineItem]{
            var sectionLineItems = [receiptLineItem]()
            
            sectionLineItems.append(receiptLineItem(leftText: receiptText(text: "Credit & Debit Card Total:") , rightText: receiptText(text: reportValues?.creditDebitCardSummary?.grandTotal.toString(asMoney: true, toDecimalPlaces: 2))))
            sectionLineItems.append(receiptLineItem(leftText: receiptText(text: "HST:") , rightText: receiptText(text: reportValues?.creditDebitCardSummary?.taxes.hst?.toString(asMoney: true, toDecimalPlaces: 2))))
            sectionLineItems.append(receiptLineItem(leftText: receiptText(text: "GST:") , rightText: receiptText(text: reportValues?.creditDebitCardSummary?.taxes.gst?.toString(asMoney: true, toDecimalPlaces: 2))))
            sectionLineItems.append(receiptLineItem(leftText: receiptText(text: "PST:") , rightText: receiptText(text: reportValues?.creditDebitCardSummary?.taxes.pst?.toString(asMoney: true, toDecimalPlaces: 2))))
            sectionLineItems.append(receiptLineItem(leftText: receiptText(text: "Orders Count:") , rightText: receiptText(text: reportValues?.creditDebitCardSummary?.ordersCount.toString())))
            
            return sectionLineItems
        }
        
        func getGiftCardTotalsSection() -> [receiptLineItem]{
            var sectionLineItems = [receiptLineItem]()
            
            sectionLineItems.append(receiptLineItem(leftText: receiptText(text: "Gift Card Redemptions:") , rightText: receiptText(text: reportValues?.giftCardSummary?.grandTotal.toString(asMoney: true, toDecimalPlaces: 2))))
            sectionLineItems.append(receiptLineItem(leftText: receiptText(text: "Redemptions Count:") , rightText: receiptText(text: reportValues?.giftCardSummary?.ordersCount.toString())))
            
            return sectionLineItems
        }
        
        //Business Header
        printLines.append(contentsOf: getBusinessHeader(inclLocationName: true))
        
        printLines.append(receiptLineItem(horizontalLine: true, horizontalLineStyle: 1))
        
        //Daily Report Header
        printLines.append(contentsOf: getReportHeader())
        
        printLines.append(receiptLineItem(horizontalLine: true, horizontalLineStyle: 0))
        
        //Grand Totals Section
        printLines.append(contentsOf: getGrandTotalsSection())
        
        printLines.append(receiptLineItem(horizontalLine: true, horizontalLineStyle: 0))
        
        //Cash Totals Section
        printLines.append(contentsOf: getCashTotalsSection())
        printLines.append(receiptLineItem(blankLine: true))
//        printLines.append(receiptLineItem(horizontalLine: true, horizontalLineStyle: 0))
        
        //Credit and Debit Card Totals Section
        printLines.append(contentsOf: getCreditAndDebitCardTotalsSection())
        printLines.append(receiptLineItem(blankLine: true))
        
//        printLines.append(receiptLineItem(horizontalLine: true, horizontalLineStyle: 0))
        
        //Gift Card Totals Section
        printLines.append(contentsOf: getGiftCardTotalsSection())
        
        printLines.append(receiptLineItem(horizontalLine: true, horizontalLineStyle: 0))
        
        let printer = getPrinterForFunction(functionName: "Receipt & Cash Drawer")
        
        //Send print job
        let printReceipt = printObject(lines: printLines, openCashDrawer: false, destinationPrinter: printer)
        
        sendPrintObjectToPrinter(printObject: printReceipt)
    }
    
    func openCashDrawer(){
        let printer = getPrinterForFunction(functionName: "Receipt & Cash Drawer")
        var printJob = printObject(lines: [], openCashDrawer: true, destinationPrinter: printer)
        PrinterManager.sendPrintJob(printJob: printJob)
    }
    
    func getPrinterForFunction(functionName: String) -> Printer? {
        return PrinterManager.getFirstFunctionMatchingPrinter(function: functionName)
    }
    
    func printTestReceipt(printer: Printer){
        var printLines = [receiptLineItem]()
        let functionLine = "Printer function: " + (printer.function ?? "N/A")
        let deviceNameLine = "Device name: " + (printer.deviceName ?? "N/A")
        let connectionTypeLine = "Connection type: " + (printer.connectionType ?? "N/A")
        
        printLines.append(receiptLineItem(centerText: receiptText(text: "====================================")))
        printLines.append(receiptLineItem(leftText: receiptText(text: functionLine)))
        printLines.append(receiptLineItem(leftText: receiptText(text: deviceNameLine)))
        printLines.append(receiptLineItem(leftText: receiptText(text: connectionTypeLine)))
        printLines.append(receiptLineItem(centerText: receiptText(text: "====================================")))
        
        var printJob = printObject(lines: printLines, openCashDrawer: false, destinationPrinter: printer)
        
        PrinterManager.sendPrintJob(printJob: printJob)
    }
    
    func getAllPrinters() -> [Printer]{
        return PrinterManager.getAllPrinters()
    }
    
}

