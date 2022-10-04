//
//  substitutionOptions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-28.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SubstitutionsOptionsView: AddOnsOptionsView{
    override func getSectionTitle(forSection section: Int)->String {
        let sectionTitles = ["Selected Substitutions: (click to remove)", "Associated Substitutions:", "General Substitutions:"]
        return sectionTitles[section]
    }
    
    override func refreshAddOnsData() {
        refreshSubsData()
    }
    
    func refreshSubsData(){
        self.selectedAddOnsList = NIMBUS.OrderCreation?.getItemSelectedAddOns(onlyAddOns: false, onlySubs: true) ?? []
        self.associatedAddOnsList = NIMBUS.OrderCreation?.getItemAssociatedAddOns(onlyAddOns: false, onlySubs: true) ?? []
        self.genericAddOnsList = NIMBUS.OrderCreation?.getItemUnassociatedAddOns(onlyAddOns: false, onlySubs: true) ?? []

        self.addOnsTableView.reloadData()
    }
}
