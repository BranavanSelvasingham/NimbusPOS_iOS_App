//
//  Printers.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-05.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

class PrinterDeviceAPIs {
    var ePOS = EposPrint()
    var defaultPrinter: EpsonIoDeviceInfo?
    
    var BTConnectedPrinters = [EpsonIoDeviceInfo](){
        didSet {
            processPrintersList(printerList: BTConnectedPrinters)
        }
    }
    var TCPConnectedPrinters = [EpsonIoDeviceInfo](){
        didSet {
            processPrintersList(printerList: TCPConnectedPrinters)
        }
    }
    
    var errorStatus: Int32? = 0
    
    init(){
        scanAndStorePrinters()
    }
    
    func scanAndStorePrinters(){
        NIMBUS.Print?.PrinterManager.deleteAllPrinters()
        getPairedBTPrinters()
    }
    
    func processPrintersList(printerList: [EpsonIoDeviceInfo]){
        printerList.forEach{ device in
            NIMBUS.Print?.PrinterManager.createNewEpsonPrinter(newDevice: device)
        }
    }
    
    func getPairedBTPrinters() {
        let deviceType: Int32 = EPSONIO_OC_DEVTYPE_BLUETOOTH.rawValue.toInt32()
        
        errorStatus = EpsonIoFinder.start(deviceType, findOption: nil)
        
        if errorStatus == EPSONIO_OC_SUCCESS.rawValue.toInt32() {
//            print("BT search started successfully")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
                let filterOption: Int32 = EPSONIO_OC_FILTER_NONE.rawValue.toInt32()
                let deviceList = EpsonIoFinder.getDeviceInfoList(&self.errorStatus!, filterOption: filterOption)
                let deviceSet = deviceList as! [EpsonIoDeviceInfo]
                EpsonIoFinder.stop()
//                print("search finished")
                self.BTConnectedPrinters = deviceSet
                self.getConnectedTCPPrinters()
            }
        } else {
            print("Error searching")
            EpsonIoFinder.stop()
        }
    }
    
    func getConnectedTCPPrinters() {
        let deviceType: Int32 = EPSONIO_OC_DEVTYPE_TCP.rawValue.toInt32()
        let option = "255.255.255.255"
        
        EpsonIoFinder.stop()

        errorStatus = EpsonIoFinder.start(deviceType, findOption: option)
        
        if errorStatus == EPSONIO_OC_SUCCESS.rawValue.toInt32() {
//            print("TCP search started successfully")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
                let filterOption: Int32 = EPSONIO_OC_FILTER_NONE.rawValue.toInt32()
                let deviceList = EpsonIoFinder.getDeviceInfoList(&self.errorStatus!, filterOption: filterOption)
                let deviceSet = deviceList as! [EpsonIoDeviceInfo]
                EpsonIoFinder.stop()
//                print("search finished")
                self.TCPConnectedPrinters = deviceSet
            }
            
        } else {
            print("Error searching")
            EpsonIoFinder.stop()
        }
    }
    
    func generateEPOSBuilderObject(printLines: [receiptLineItem], openCashDrawer: Bool = false) -> EposBuilder?{
        let builder = EPOSBuilderGenerator(printLines: printLines, openCashDrawer: openCashDrawer)
        return builder.getBuilder()
    }
    
    func getPrinterStatus(sendToDeviceName: String, sendToDeviceType: Int32) -> String{
        var status: String = ""
        let errorCode = getPrinterErrorCode(sendToDeviceName: sendToDeviceName, sendToDeviceType: sendToDeviceType)
        
        switch errorCode {
        case EPOS_OC_SUCCESS.rawValue.toInt32():
            status += "Ready "
        case EPOS_OC_ERR_OPEN.rawValue.toInt32():
            status += "Error opening connection "
        case EPOS_OC_ERR_CONNECT.rawValue.toInt32():
            status += "Error connecting "
        case EPOS_OC_ERR_OFF_LINE.rawValue.toInt32():
            status += "Printer offline "
        default:
            break
        }

        return status
    }
    
    private func getPrinterErrorCode(sendToDeviceName: String, sendToDeviceType: Int32) -> Int32 {
        var errorCode: Int32?
        var statusCode: UInt = 0
        var battery: UInt = 0
        
        
        let deviceType: Int32
        
        if sendToDeviceType == 258 {
            deviceType = 1
        } else {
            deviceType = 0
        }
        
        var deviceName: String = sendToDeviceName
        if deviceName == "" {
            deviceName = defaultPrinter?.deviceName ?? ""
        }
        
        if ePOS == nil {
            print("ePOS is nil")
        } else {
            errorStatus = ePOS?.closePrinter()
            errorCode = ePOS?.openPrinter(deviceType, deviceName: deviceName, enabled: EPOS_OC_FALSE, interval: EPOS_OC_PARAM_DEFAULT.hashValue, timeout: EPOS_OC_PARAM_DEFAULT.hashValue)
            errorStatus = ePOS?.getStatus(&statusCode, battery: &battery)
            errorStatus = ePOS?.closePrinter()
            return errorCode ?? -1
        }
        
        return -1
    }
    
    func sendPrintJob(job: EposBuilder, sendToDeviceName: String, sendToDeviceType: Int32){
        let deviceType: Int32

        if sendToDeviceType == 258 {
            deviceType = 1
        } else {
            deviceType = 0
        }
        
        var deviceName: String = sendToDeviceName
        if deviceName == "" {
            deviceName = defaultPrinter?.deviceName ?? ""
        }

        var status: UInt = 0
        var battery: UInt = 0
        
        if ePOS == nil {
            print("ePOS is nil")
        } else {
//            errorStatus = ePOS?.closePrinter()
            errorStatus = ePOS?.openPrinter(deviceType, deviceName: deviceName, enabled: EPOS_OC_FALSE, interval: EPOS_OC_PARAM_DEFAULT.hashValue, timeout: EPOS_OC_PARAM_DEFAULT.hashValue)
//            errorStatus = ePOS?.getStatus(&status, battery: &battery)
            
            if errorStatus == Int32(EPOS_OC_SUCCESS.rawValue) {
//                print("Printer connection open")
//                print("status is : ", status)
                if status == EPOS_OC_ST_OFF_LINE {
//                    print("status is offline")
                } else if status == EPOS_OC_ST_NO_RESPONSE {
//                    print("status is no response")
                } else {
//                    print("about to send data")
                    errorStatus = ePOS?.beginTransaction()
                    if errorStatus == Int32(EPOS_OC_SUCCESS.rawValue) {
                        errorStatus = ePOS?.sendData(job, timeout: 1000, status: &status)
                        errorStatus = ePOS?.endTransaction()
                        
                        if status != EPOS_OC_ST_NO_RESPONSE.hashValue {
//                            errorStatus = job.clearCommandBuffer()
                        } else {
//                            print("No response")
                        }
                        errorStatus = job.clearCommandBuffer()
                    }
                }
                errorStatus = ePOS?.closePrinter()
            } else {
//                print("Printer could not be opened")
            }
        }
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
