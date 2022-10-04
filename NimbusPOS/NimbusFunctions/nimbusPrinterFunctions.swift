//
//  nimbusPrinterFunctions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-08.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import CoreData

class nimbusPrinterFunctions: NimbusBase {
    override init(master: NimbusFramework?){
        super.init(master: master)
    }
    
    let Printers = PrinterDeviceAPIs()
    
    let epsonDeviceConnectionTypes: [Int32: String] = [EPSONIO_OC_DEVTYPE_BLUETOOTH.rawValue.toInt32(): "BT", EPSONIO_OC_DEVTYPE_TCP.rawValue.toInt32(): "TCP"]
    
    var printerFunctionOptions: [String] = ["None", "Receipt & Cash Drawer", "Kitchen"]
    
    func sendPrintJob(printJob: printObject){
        let builder = Printers.generateEPOSBuilderObject(printLines: printJob.lines, openCashDrawer: printJob.openCashDrawer)
        let printer = printJob.destinationPrinter
        let sendToDeviceName = printer?.deviceName ?? ""
        let sendToDeviceType = epsonDeviceConnectionTypes.first(where: {$0.value == printer?.connectionType})?.key ?? -1
        
        if let builder = builder {
            Printers.sendPrintJob(job: builder , sendToDeviceName: sendToDeviceName, sendToDeviceType: sendToDeviceType)
        }
    }
    
    func getPrinterStatus(printer: Printer) -> String {
        let sendToDeviceName = printer.deviceName ?? ""
        let sendToDeviceType = epsonDeviceConnectionTypes.first(where: {$0.value == printer.connectionType})?.key ?? -1
        
        return Printers.getPrinterStatus(sendToDeviceName: sendToDeviceName, sendToDeviceType: sendToDeviceType)
    }
    
    func getPrinterById(printerId: String) -> Printer? {
        var fetchPrinters = [Printer]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Printer")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "id = %@", printerId)
        
        do {
            fetchPrinters = try managedContext.fetch(fetchRequest) as! [Printer]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchPrinters.first
    }
    
    func getFirstBTPrinter()->Printer?{
        let allPrinters = getAllPrinters()
        return allPrinters.first(where: {$0.connectionType == "BT"})
    }
    
    func getFirstTCPPrinter()->Printer?{
        let allPrinters = getAllPrinters()
        return allPrinters.first(where: {$0.connectionType == "TCP" })
    }
    
    func getFirstFunctionMatchingPrinter(function: String)->Printer?{
        let allPrinters = getAllPrinters()
        if allPrinters.count == 1 {
            return allPrinters.first
        } else {
            return allPrinters.first(where: {$0.function == function }) ?? allPrinters.first(where: {$0.function == "Receipt & Cash Drawer" })
        }
    }
    
    func getPrinterByNameAndConnection(printerName: String, connectionType: String) -> Printer? {
        var fetchPrinters = [Printer]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Printer")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "deviceName = %@ AND connectionType = %@", printerName, connectionType)
        
        do {
            fetchPrinters = try managedContext.fetch(fetchRequest) as! [Printer]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchPrinters.first
    }
    
    func getAllPrinters() -> [Printer]{
        var fetchPrinters = [Printer]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Printer")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            fetchPrinters = try managedContext.fetch(fetchRequest) as! [Printer]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchPrinters
    }
    
    func createNewEpsonPrinter(newDevice: EpsonIoDeviceInfo){
        let printerEntity = NSEntityDescription.entity(forEntityName: "Printer", in: managedContext)!
        
        var printer: Printer
        
        if let device = getPrinterByNameAndConnection(printerName: newDevice.deviceName, connectionType: epsonDeviceConnectionTypes[newDevice.deviceType] ?? " ") {
            //device exists
//            printer = device
        } else {
            printer = NSManagedObject(entity: printerEntity, insertInto: managedContext) as! Printer
            
            printer.id = UUID().uuidString
            printer.deviceName = newDevice.deviceName
            
            printer.connectionType = epsonDeviceConnectionTypes[newDevice.deviceType]
            printer.ipAddress = newDevice.ipAddress
            printer.macAddress = newDevice.macAddress
            printer.printerModel = newDevice.printerName
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func deletePrinterById(printerId: String){
        if let printer = getPrinterById(printerId: printerId){
            deletePrinter(printer: printer)
        }
    }
    
    func deletePrinter(printer: Printer){
        managedContext.delete(printer)
    }
    
    func deleteAllPrinters(){
        deleteAllRecords(entityName: Printer.entity().managedObjectClassName )
    }
    
    func setPrinterFunctionality(printer: Printer, functionality: String){
        printer.function = functionality
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}
