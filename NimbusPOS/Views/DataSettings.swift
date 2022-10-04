//
//  DataSettings.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-22.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class DataSettings: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let syncSymbol: UIImageView = {
        let symbol = UIImageView(image: UIImage(named: "ic_sync_48pt"))
        symbol.contentMode = .scaleAspectFit
        symbol.translatesAutoresizingMaskIntoConstraints = false
        symbol.heightAnchor.constraint(equalToConstant: 100).isActive = true
        symbol.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return symbol
    }()
    
    let dataSyncLabel: UILabel = {
        let label = UILabel()
        label.font = MDCTypography.display1Font()
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Data Sync"
        return label
    }()
    
    let syncFrequencyView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 150).isActive = true
        view.widthAnchor.constraint(equalToConstant: 350).isActive = true
        return view
    }()
    
    let syncFrequency: UILabel = {
        let label = UILabel()
        label.font = MDCTypography.subheadFont()
        label.textColor = UIColor.gray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 150).isActive = true
        label.lineBreakMode = .byWordWrapping
        label.text = "Sync Every: "
        return label
    }()
    
    let syncFrequencySelector: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    let orderHistoryView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 150).isActive = true
        view.widthAnchor.constraint(equalToConstant: 350).isActive = true
        return view
    }()
    
    let orderHistoryLimit: UILabel = {
        let label = UILabel()
        label.font = MDCTypography.subheadFont()
        label.textColor = UIColor.gray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 150).isActive = true
        label.lineBreakMode = .byWordWrapping
        label.text = "Local Order History: "
        return label
    }()
    
    let orderHistoryLimitSelector: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    let refreshDataNowButton: MDCRaisedButton = {
        let button = MDCRaisedButton()
        button.setBackgroundColor(UIColor.gray)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("Sync Cloud Data to Local", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 250).isActive = true
        button.addTarget(self, action: #selector(syncDataNow), for: .touchUpInside)
        return button
    }()
    
    let syncFrequencyOptions: [Int] = [1, 60, 180, 720, 1440]
    let syncFrequencyOptionTitles: [Int: String] = [1: "1 min", 60: "1 hour", 180: "3 hours", 720: "Twice Daily", 1440: "Daily"]
    
    let orderHistoryLimitOptions: [Int] = [7, 14, 31] //, 90]
    let orderHistoryLimitOptionTitles: [Int: String] = [7: "7 Days", 14: "14 Days", 31: "31 Days"] //, 90: "90 Days"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        syncFrequencySelector.delegate = self
        syncFrequencySelector.dataSource = self
        
        orderHistoryLimitSelector.delegate = self
        orderHistoryLimitSelector.dataSource = self
        
        self.view.addSubview(syncSymbol)
        self.view.addSubview(dataSyncLabel)
        
        self.view.addSubview(syncFrequencyView)
        self.view.addSubview(orderHistoryView)
        self.view.addSubview(refreshDataNowButton)
        
        syncFrequencyView.addSubview(syncFrequency)
        syncFrequencyView.addSubview(syncFrequencySelector)
        
        orderHistoryView.addSubview(orderHistoryLimit)
        orderHistoryView.addSubview(orderHistoryLimitSelector)
        
        NIMBUS.Devices?.checkForDeviceAuthentication()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        NSLayoutConstraint(item: syncSymbol, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: syncSymbol, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 50).isActive = true
        
        NSLayoutConstraint(item: dataSyncLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: dataSyncLabel, attribute: .top, relatedBy: .equal, toItem: syncSymbol, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
        
        NSLayoutConstraint(item: syncFrequencyView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: syncFrequencyView, attribute: .top, relatedBy: .equal, toItem: dataSyncLabel, attribute: .bottom, multiplier: 1, constant: 50).isActive = true
        
        NSLayoutConstraint(item: orderHistoryView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderHistoryView, attribute: .top, relatedBy: .equal, toItem: syncFrequencyView, attribute: .bottom, multiplier: 1, constant: 25).isActive = true
        
        NSLayoutConstraint(item: refreshDataNowButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: refreshDataNowButton, attribute: .top, relatedBy: .equal, toItem: orderHistoryView, attribute: .bottom, multiplier: 1, constant: 25).isActive = true
        
        NSLayoutConstraint(item: syncFrequency, attribute: .leading, relatedBy: .equal, toItem: syncFrequencyView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: syncFrequency, attribute: .centerY, relatedBy: .equal, toItem: syncFrequencyView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: syncFrequencySelector, attribute: .top, relatedBy: .equal, toItem: syncFrequencyView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: syncFrequencySelector, attribute: .leading, relatedBy: .equal, toItem: syncFrequency, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: syncFrequencySelector, attribute: .trailing, relatedBy: .equal, toItem: syncFrequencyView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: syncFrequencySelector, attribute: .bottom, relatedBy: .equal, toItem: syncFrequencyView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: orderHistoryLimit, attribute: .leading, relatedBy: .equal, toItem: orderHistoryView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderHistoryLimit, attribute: .centerY, relatedBy: .equal, toItem: orderHistoryView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: orderHistoryLimitSelector, attribute: .top, relatedBy: .equal, toItem: orderHistoryView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderHistoryLimitSelector, attribute: .leading, relatedBy: .equal, toItem: orderHistoryLimit, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderHistoryLimitSelector, attribute: .trailing, relatedBy: .equal, toItem: orderHistoryView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderHistoryLimitSelector, attribute: .bottom, relatedBy: .equal, toItem: orderHistoryView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let selectedSyncFrequency = NIMBUS.Data?.deviceSyncFrequency ?? 0
        if let selectedRow = syncFrequencyOptions.index(of: selectedSyncFrequency) {
            syncFrequencySelector.selectRow(selectedRow, inComponent: 0, animated: false)
        }
        
        let selectedLocalOrderHistoryLimit = NIMBUS.Data?.localOrderHistoryLimit ?? 0
        if let selectedRow = orderHistoryLimitOptions.index(of: selectedLocalOrderHistoryLimit) {
            orderHistoryLimitSelector.selectRow(selectedRow, inComponent: 0, animated: false)
        }
    }
    
    func refreshPickers(){
        
    }
    
    func syncDataNow(){
        NIMBUS.Data?.periodicSyncStatus = .Paused
        NIMBUS.Navigation?.restartApp()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == syncFrequencySelector {
            return syncFrequencyOptionTitles.count
        } else if pickerView == orderHistoryLimitSelector {
            return orderHistoryLimitOptionTitles.count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == syncFrequencySelector {
            let option = syncFrequencyOptions[row]
            let rowTitle = syncFrequencyOptionTitles[option]
            return rowTitle
        } else if pickerView == orderHistoryLimitSelector {
            let option = orderHistoryLimitOptions[row]
            let rowTitle = orderHistoryLimitOptionTitles[option]
            return rowTitle
        } else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == syncFrequencySelector {
            NIMBUS.Data?.deviceSyncFrequency = syncFrequencyOptions[row]
        } else if pickerView == orderHistoryLimitSelector {
            NIMBUS.Data?.localOrderHistoryLimit = orderHistoryLimitOptions[row]
        }
    }
}
