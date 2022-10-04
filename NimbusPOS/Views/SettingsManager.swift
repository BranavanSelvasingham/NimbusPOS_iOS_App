//
//  SettingsManager.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-22.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

protocol SettingsManagerDelegate {
    func loadSettingsGroup(settingsGroup: _SettingsGroups)
}

enum _SettingsGroups {
    case Printers
    case Account
    case Location
    case Help
    case Data
}

class SettingsManager: UIViewController, SettingsManagerDelegate {
    var pageView: PageView = PageView()
    let settingsGroupsList: SettingsGroupsList = SettingsGroupsList()
    
    var printerSettings: PrinterSettings = PrinterSettings()
    var locationSettings: LocationSettings = LocationSettings()
    var dataSettings: DataSettings = DataSettings()
    var accountSettings: AccountSettings = AccountSettings()
    var helpPage: HelpPage = HelpPage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageView = PageView(frame: self.view.frame)
        pageView.leftSection.setHeaderTitle(title: "Settings")
        self.view.addSubview(pageView)
        
        loadSettingsGroupsList()
        
    }
    
    func loadSettingsGroupsList(){
        self.addChildViewController(settingsGroupsList)
        pageView.addTableViewToLeftSection(tableView: settingsGroupsList.tableView)
        settingsGroupsList.didMove(toParentViewController: self)
        settingsGroupsList.settingsManagerDelegate = self
        
        self.addChildViewController(printerSettings)
        printerSettings.didMove(toParentViewController: self)
        
        self.addChildViewController(locationSettings)
        locationSettings.didMove(toParentViewController: self)
        
        self.addChildViewController(dataSettings)
        dataSettings.didMove(toParentViewController: self)
        
        self.addChildViewController(accountSettings)
        accountSettings.didMove(toParentViewController: self)
        
        self.addChildViewController(helpPage)
        helpPage.didMove(toParentViewController: self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        

    }
    
    func loadSettingsGroup(settingsGroup: _SettingsGroups){
        switch settingsGroup {
        case .Printers:
            loadPrinterSettings()
        case .Location:
            loadLocationSettings()
        case .Account:
            loadAccountSettings()
        case .Data:
            loadDataSettings()
        case .Help:
            loadHelpSettings()
        }
    }
    
    func loadPrinterSettings(){
        pageView.rightSection.titleLabel.text = "Printers"
        pageView.addDetailViewToRightSection(detailView: printerSettings.view)
    }
    
    func loadLocationSettings(){
        pageView.rightSection.titleLabel.text = "Location"
        pageView.addDetailViewToRightSection(detailView: locationSettings.view)
    }
    
    func loadAccountSettings(){
        pageView.rightSection.titleLabel.text = "Account"
        pageView.addDetailViewToRightSection(detailView: accountSettings.view)
    }
    
    func loadHelpSettings(){
        pageView.rightSection.titleLabel.text = "Help"
        pageView.addDetailViewToRightSection(detailView: helpPage.view)
    }
    
    func loadDataSettings(){
        pageView.rightSection.titleLabel.text = "Data"
        pageView.addDetailViewToRightSection(detailView: dataSettings.view)
    }
    
}
