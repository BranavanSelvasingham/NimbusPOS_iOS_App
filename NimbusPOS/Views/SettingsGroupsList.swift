//
//  SettingsGroupsList.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-22.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class SettingsGroupsList: UITableViewController {
    var settingsManagerDelegate: SettingsManagerDelegate?
    
    struct settingsGroupStruct {
        var label: String
        var image: UIImage?
        var settingsGroup: _SettingsGroups
    }
    
    let SettingsGroups: [settingsGroupStruct] = [
        settingsGroupStruct(label: "Printers", image: UIImage(named: "ic_print"), settingsGroup: .Printers),
        settingsGroupStruct(label: "Location", image: UIImage(named: "ic_location_on"), settingsGroup: .Location),
        settingsGroupStruct(label: "Data", image: UIImage(named: "ic_storage"), settingsGroup: .Data),
        settingsGroupStruct(label: "Account", image: UIImage(named: "ic_account_circle"), settingsGroup: .Account),
        settingsGroupStruct(label: "Help", image: UIImage(named: "ic_help"), settingsGroup: .Help)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self , forCellReuseIdentifier: "cell")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsGroups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = SettingsGroups[indexPath.row].label
        cell.textLabel?.font = MDCTypography.titleFont()
        cell.imageView?.image = SettingsGroups[indexPath.row].image ?? UIImage()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        settingsManagerDelegate?.loadSettingsGroup(settingsGroup: SettingsGroups[indexPath.row].settingsGroup)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}
