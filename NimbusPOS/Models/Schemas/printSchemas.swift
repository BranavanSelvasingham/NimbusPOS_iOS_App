//
//  printSchemas.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-08.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

struct receiptText {
    let text: String
    let fontStyle: Int
    let fontSize: Int
    let underline: Bool
    let bold: Bool
    let inversion: Bool
    let isBarcode: Bool
    let barcodeType: Int
    
    init (text: String?, fontStyle: Int = 0, fontSize: Int = 1, underline: Bool = false, bold: Bool = false, inversion: Bool = false) {
        self.text = text ?? ""
        self.fontStyle = fontStyle
        self.fontSize = fontSize
        self.underline = underline
        self.bold = bold
        self.inversion = inversion
        
        self.isBarcode = false
        self.barcodeType = 1
    }
    
    init (forBarcode barcodeType: Int, barcodeText: String, fontStyle: Int = 0, fontSize: Int = 1, underline: Bool = false, bold: Bool = false, inversion: Bool = false) {
        self.isBarcode = true
        self.barcodeType = barcodeType
        self.text = barcodeText
        self.fontStyle = fontStyle
        self.fontSize = fontSize
        self.underline = underline
        self.bold = bold
        self.inversion = inversion
    }
}

struct receiptLineItem {
    let leftText: receiptText?
    let centerText: receiptText?
    let rightText: receiptText?
    let blankLine: Bool
    let horizontalLine: Bool
    let horizontalLineStyle: Int
    
    init (leftText: receiptText) {
        self.leftText = leftText
        self.centerText = nil
        self.rightText = nil
        self.blankLine = false
        self.horizontalLine = false
        self.horizontalLineStyle = 0
    }
    
    init (centerText: receiptText) {
        self.leftText = nil
        self.centerText = centerText
        self.rightText = nil
        self.blankLine = false
        self.horizontalLine = false
        self.horizontalLineStyle = 0
    }
    
    init (rightText: receiptText){
        self.leftText = nil
        self.centerText = nil
        self.rightText = rightText
        self.blankLine = false
        self.horizontalLine = false
        self.horizontalLineStyle = 0
    }
    
    init (leftText: receiptText, rightText: receiptText){
        self.leftText = leftText
        self.centerText = nil
        self.rightText = rightText
        self.blankLine = false
        self.horizontalLine = false
        self.horizontalLineStyle = 0
    }
    
    init(horizontalLine: Bool = true, horizontalLineStyle: Int = 0){
        self.leftText = nil
        self.centerText = nil
        self.rightText = nil
        self.blankLine = false
        self.horizontalLine = true
        self.horizontalLineStyle = horizontalLineStyle
    }
    
    init(blankLine: Bool = true){
        self.leftText = nil
        self.centerText = nil
        self.rightText = nil
        self.blankLine = true
        self.horizontalLine = false
        self.horizontalLineStyle = 0
    }
}

struct printObject {
    let lines: [receiptLineItem]
    let openCashDrawer: Bool
    let destinationPrinter: Printer?
    
    init(lines: [receiptLineItem], openCashDrawer: Bool, destinationPrinter: Printer?) {
        self.lines = lines
        self.openCashDrawer = openCashDrawer
        self.destinationPrinter = destinationPrinter
    }
}
