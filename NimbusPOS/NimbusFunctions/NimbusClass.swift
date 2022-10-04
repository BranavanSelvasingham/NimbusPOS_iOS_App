//
//  NimbusClass.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-10.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

class NimbusFramework {
    var Navigation: nimbusNavigationFunctions?
    var Business: nimbusBusinessFunctions?
    var Location: nimbusLocationFunctions?
    var Style: nimbusStyleFunctions?
    var Data: nimbusDataFunctions?
    var Products: nimbusProductFunctions?
    var Categories: nimbusCategoriesFunctions?
    var AddOns: nimbusAddOnsFunctions?
    var OrderCreation: nimbusOrderCreationFunctions?
    var OrderManagement: nimbusOrderManagementFunctions?
    var Customers: nimbusCustomerFunctions?
    var Tables: nimbusTablesFunctions?
    var LoyaltyCards: nimbusLoyaltyCardFunctions?
    var LoyaltyPrograms: nimbusLoyaltyProgramFunctions?
    var Employees: nimbusEmployeesFunctions?
    var EmployeeHours: nimbusEmployeeHoursFunctions?
    var Notes: nimbusNotesFunctions?
    var Reports: nimbusReportsFunctions?
    var Library: nimbusLibrary?
    var Print: nimbusPrintFunctions?
    var Devices: nimbusDeviceFunctions?
    
    func construct_objects(master: NimbusFramework){
        Library = nimbusLibrary(master: master)
        Business = nimbusBusinessFunctions(master: master)
        Location = nimbusLocationFunctions(master: master)
        Navigation = nimbusNavigationFunctions(master: master)
        Style = nimbusStyleFunctions(master: master)
        Data = nimbusDataFunctions(master:master)
        Products = nimbusProductFunctions(master: master)
        Categories = nimbusCategoriesFunctions(master: master)
        AddOns = nimbusAddOnsFunctions(master: master)
        OrderCreation = nimbusOrderCreationFunctions(master: master)
        OrderManagement = nimbusOrderManagementFunctions(master: master)
        Customers = nimbusCustomerFunctions(master: master)
        Tables = nimbusTablesFunctions(master: master)
        LoyaltyCards = nimbusLoyaltyCardFunctions(master: master)
        LoyaltyPrograms = nimbusLoyaltyProgramFunctions(master: master)
        Employees = nimbusEmployeesFunctions(master: master)
        EmployeeHours = nimbusEmployeeHoursFunctions(master: master)
        Notes = nimbusNotesFunctions(master: master)
        Reports = nimbusReportsFunctions(master: master)
        Print = nimbusPrintFunctions(master: master)
        Devices = nimbusDeviceFunctions(master: master)
    }
}

var NIMBUS = NimbusFramework()

