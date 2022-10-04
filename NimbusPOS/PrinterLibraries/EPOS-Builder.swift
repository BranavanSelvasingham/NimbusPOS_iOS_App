//
//  EPOS-Builder.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-09.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

class EPOSBuilderGenerator {
    
    var printLines: [receiptLineItem],
        openCashDrawer: Bool,
        printerModel: String,
        printerLanguage: Int32,
        builder: EposBuilder?;
    
    //printer specific constants
    let textFontStyleOptions = [EPOS_OC_FONT_A.rawValue.toInt32(), EPOS_OC_FONT_B.rawValue.toInt32(), EPOS_OC_FONT_C.rawValue.toInt32()]
    
    let horizontalStyleOptions = [EPOS_OC_LINE_THIN.rawValue.toInt32(), EPOS_OC_LINE_MEDIUM.rawValue.toInt32(), EPOS_OC_LINE_THICK.rawValue.toInt32(), EPOS_OC_LINE_THIN_DOUBLE.rawValue.toInt32(), EPOS_OC_LINE_MEDIUM_DOUBLE.rawValue.toInt32(), EPOS_OC_LINE_THICK_DOUBLE.rawValue.toInt32()]
    
    var printWidth: Int {
        get {
            // some logic to be based on printer width
            return 620
        }
    }
    
    var errorStatus: Int32? = 0 
    
    init(printLines: [receiptLineItem],
             openCashDrawer: Bool = false,
             printerModel: String = "TM-m10",
             printerLanguage: Int32 = EPOS_OC_MODEL_ANK.rawValue.toInt32()) {
        
        self.printLines = printLines
        self.openCashDrawer = openCashDrawer
        self.printerModel = printerModel
        self.printerLanguage = printerLanguage
        
        builder = EposBuilder(printerModel: printerModel, lang: printerLanguage)
        
    }
    
    func getMaxCharacterWidth(fontStyle: Int, fontSize: Int) -> Int {
        var characterWidth: Int = 0
        let EPSON_FONTA_Character_Width = 48
        let EPSON_FONTB_Character_Width = 57
        let EPSON_FONTC_Character_Width = 64
        
        if fontStyle == 0 {
            characterWidth = Int(EPSON_FONTA_Character_Width/fontSize)
        } else if fontStyle == 1 {
            characterWidth = Int(EPSON_FONTB_Character_Width/fontSize)
        } else if fontStyle == 2 {
            characterWidth = Int(EPSON_FONTC_Character_Width/fontSize)
        }
        
        return characterWidth
    }
    
    func setFontType(fontType: Int){
        if fontType < textFontStyleOptions.count {
            builder?.addTextFont(textFontStyleOptions[fontType])
        }
    }
    
    func setFontSize(fontSize: Int){
        builder?.addTextSize(fontSize, height: fontSize)
    }
    
    func setFontStyle(underline: Bool, bold: Bool, inversion: Bool){
        builder?.addTextStyle(Int32(inversion.hashValue), ul: Int32(underline.hashValue), em: Int32(bold.hashValue), color: EPOS_OC_COLOR_1.rawValue.toInt32())
    }
    
    func getPaddedFiller(paddingCount: Int, paddingCharacter: Character) -> String {
        var paddedString: String = ""
        for i in 1...paddingCount {
            paddedString = paddedString + String(paddingCharacter)
        }
        return paddedString
    }
    
    func leftAndRightPaddedString(left: receiptText, right: receiptText, paddingCharacter: Character = " "){
        let leftText: String = left.text
        let rightText: String = right.text
        var paddedString: String = ""
        var characterColumnWidth: Int = 0
        
        setFontType(fontType: left.fontStyle)
        setFontSize(fontSize: left.fontSize)
        setFontStyle(underline: left.underline, bold: left.bold, inversion: left.inversion)
        errorStatus = builder?.addTextAlign(EPOS_OC_ALIGN_LEFT.rawValue.toInt32())
        errorStatus = builder?.addText(leftText)
        
        characterColumnWidth = getMaxCharacterWidth(fontStyle: left.fontStyle, fontSize: left.fontSize)
        
        if (leftText.count + rightText.count) > characterColumnWidth {
            paddedString = ""
        } else {
            let paddingCount = characterColumnWidth - leftText.count - rightText.count
            paddedString = getPaddedFiller(paddingCount: paddingCount, paddingCharacter: paddingCharacter)
        }
        
        setFontStyle(underline: false, bold: false, inversion: false)
        errorStatus = builder?.addText(paddedString)
        
        setFontStyle(underline: right.underline, bold: right.bold, inversion: right.inversion)
        errorStatus = builder?.addText(rightText)
    }
    
    func setAsHorizontalLine(lineStyle: Int){
        let lineLength: Int = getMaxCharacterWidth(fontStyle: 2, fontSize: 1)
        let line: String
        
        setFontStyle(underline: true, bold: false, inversion: false)
        setFontType(fontType: 2)
        if lineStyle <= 2 {
            line = getPaddedFiller(paddingCount: lineLength, paddingCharacter: " ")
            errorStatus = builder?.addText(line)
        } else {
            line = getPaddedFiller(paddingCount: lineLength, paddingCharacter: " ")
            errorStatus = builder?.addText(line)
            errorStatus = builder?.addText(line)
        }
    }
    
    func setAsBlankLine(){
        // do nothing ("/n will be added later)
    }
    
    func setAsBarcode(barcodeData: String,
                      type: Int32 = EPOS_OC_BARCODE_CODE93.rawValue.toInt32() ,
                      hri: Int32 = EPOS_OC_HRI_BELOW.rawValue.toInt32(),
                      font: Int32 = EPOS_OC_FONT_A.rawValue.toInt32(),
                      width: Int = 400, height: Int = 100){
        errorStatus = builder?.addBarcode(barcodeData, type: type, hri: hri, font: font, width: width, height: height)
    }
    
    func convertReceiptLineToBuilderLines(lineItem: receiptLineItem){
        if let builder = builder {
            errorStatus = builder.addTextFont(EPOS_OC_FONT_A.rawValue.toInt32())
            errorStatus = builder.addTextSize(1, height: 1)
            
            let leftText: String = lineItem.leftText?.text ?? ""
            let centerText: String = lineItem.centerText?.text ?? ""
            let rightText: String = lineItem.rightText?.text ?? ""
            let fontType: Int = lineItem.leftText?.fontStyle ?? lineItem.centerText?.fontStyle ?? lineItem.rightText?.fontStyle ?? 0
            let fontSize: Int = lineItem.leftText?.fontSize ?? lineItem.centerText?.fontSize ?? lineItem.rightText?.fontSize ?? 0
            let underline: Bool = lineItem.leftText?.underline ?? lineItem.centerText?.underline ?? lineItem.rightText?.underline ?? false
            let bold: Bool = lineItem.leftText?.bold ?? lineItem.centerText?.bold ?? lineItem.rightText?.bold ?? false
            let inversion: Bool = lineItem.leftText?.inversion ?? lineItem.centerText?.inversion ?? lineItem.rightText?.inversion ?? false
            let isBarcode: Bool = lineItem.leftText?.isBarcode ?? lineItem.centerText?.isBarcode ?? lineItem.rightText?.isBarcode ?? false
            let isHorizontalLine: Bool = lineItem.horizontalLine
            let isBlankLine: Bool = lineItem.blankLine
            let barcodeType: Int = lineItem.leftText?.barcodeType ?? lineItem.centerText?.barcodeType ?? lineItem.rightText?.barcodeType ?? 0
            
            if isBarcode == true {
                let barcodeData: String = leftText + centerText + rightText
                setAsBarcode(barcodeData: barcodeData)
            
            } else if isBlankLine == true{
                setAsBlankLine()
                
            } else if isHorizontalLine == true {
                setAsHorizontalLine(lineStyle: lineItem.horizontalLineStyle)
                
            } else if rightText != "" && leftText != "" { //add Left and Right Text
                leftAndRightPaddedString(left: lineItem.leftText!, right: lineItem.rightText!)
                
            } else {
                setFontType(fontType: fontType)
                setFontSize(fontSize: fontSize)
                setFontStyle(underline: underline, bold: bold, inversion: inversion)
                
                //add Left Text
                if leftText != "" && rightText == "" {
                    errorStatus = builder.addTextAlign(EPOS_OC_ALIGN_LEFT.rawValue.toInt32())
                    errorStatus = builder.addText(lineItem.leftText?.text)
                }
                    //add Center Text
                else if centerText != "" {
                    errorStatus = builder.addTextAlign(EPOS_OC_ALIGN_CENTER.rawValue.toInt32())
                    errorStatus = builder.addText(lineItem.centerText?.text)
                }
                    //add Right Text
                else if rightText != "" && leftText == "" {
                    errorStatus = builder.addTextAlign(EPOS_OC_ALIGN_RIGHT.rawValue.toInt32())
                    errorStatus = builder.addText(lineItem.rightText?.text)
                }
                
            }
            
            //add Next line
            errorStatus = builder.addText("\n")
            errorStatus = builder.addTextAlign(EPOS_OC_ALIGN_LEFT.rawValue.toInt32())
        }
    }
    
    func setOpenCashDrawer(){
        let drawer1 = EPOS_OC_DRAWER_1.rawValue.toInt32()
        let drawer2 = EPOS_OC_DRAWER_2.rawValue.toInt32()
        let pulse100 = EPOS_OC_PULSE_100.rawValue.toInt32()
        
        errorStatus = builder?.addPulse(drawer1, time: pulse100)
        errorStatus = builder?.addPulse(drawer2, time: pulse100)
    }
    
    func getBuilder() -> EposBuilder? {
        if !printLines.isEmpty {
            //builder initialization
            errorStatus = builder?.addTextSmooth(EPOS_OC_TRUE)
            
            //add print lines
            printLines.forEach{ receiptLine in
                convertReceiptLineToBuilderLines(lineItem: receiptLine)
            }
            
            errorStatus = builder?.addText("\n")
            errorStatus = builder?.addText("\n")
            
            //Cut receipt
            errorStatus = builder?.addCut(Int32(EPOS_OC_CUT_FEED.rawValue))
        }
        
        if openCashDrawer == true {
            setOpenCashDrawer()
        }
    
        return builder
    }
    
//    func errorStatusTranslator(error: Int32){
//        switch error {
//        case EPOS_OC_SUCCESS.rawValue.toInt32():
//            break
//        case EPOS_OC_ST_PRINT_SUCCESS:
//            print("Print success")
//        case EPOS_OC_ST_OFF_LINE:
//            print("Off line")
//        case EPOS_OC_ST_NO_RESPONSE:
//            print("No response")
//        case EPOS_OC_ST_WAIT_ON_LINE:
//            print("wait on line")
//        case EPOS_OC_ST_BUZZER:
//            print("Buzzer")
//        case EPOS_OC_ST_PAPER_FEED:
//            print("paper feed")
//        case EPOS_OC_ST_UNRECOVER_ERR:
//            print("unrecover error")
//        case EPOS_OC_ST_AUTORECOVER_ERR:
//            print("autorecover error")
//        default:
//            print(error)
//        }
//    }
}
