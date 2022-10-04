//
//  PrinterSettingCell.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-23.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit
import MaterialComponents

class PrinterSettingCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
    let printerMainView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 500).isActive = true
        return view
    }()
    
    let printerVisualSection: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        view.widthAnchor.constraint(equalToConstant: 200).isActive = true
        return view
    }()
    
    let printerDetailView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        return view
    }()
    
    let printerFunctionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    let printerOptionsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return view
    }()
    
    let printerImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage())
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        return imageView
    }()
    
    let activePrinterImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 25
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        return imageView
    }()
    
    let connectionTypeImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage())
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return imageView
    }()
    
    let printerDetailStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let printerFunction: UILabel = {
        let label = UILabel()
        label.font = MDCTypography.titleFont()
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let printerConnectionLabel: UILabel = {
        let label = UILabel()
        label.font = MDCTypography.subheadFont()
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let printerModelLabel: UILabel = {
        let label = UILabel()
        label.font = MDCTypography.subheadFont()
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let printerAddress: UILabel = {
        let label = UILabel()
        label.font = MDCTypography.subheadFont()
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let testPrinterButton: MDCRaisedButton = {
        let button = MDCRaisedButton()
        button.setTitle("Print Test Slip", for: .normal)
        button.isUppercaseTitle = false
        button.backgroundColor = UIColor.gray
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleFont(MDCTypography.titleFont(), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 200).isActive = true
        return button
    }()
    
    let printerStatusLabel: UILabel = {
        let label = UILabel()
        label.font = MDCTypography.subheadFont()
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let refreshPrinterStatusButton: MDCRaisedButton = {
        let button = MDCRaisedButton()
        button.setTitle("Refresh Printer Status", for: .normal)
        button.isUppercaseTitle = false
        button.backgroundColor = UIColor.gray
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleFont(MDCTypography.titleFont(), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 250).isActive = true
        return button
    }()
    
    let functionSelectorLabel: UILabel = {
        let label = UILabel()
        label.font = MDCTypography.titleFont()
        label.textColor = UIColor.gray
        label.text = "Function:"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.widthAnchor.constraint(equalToConstant: 150).isActive = true
        return label
    }()
    
    let functionSelector: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    var printerSettingsDelegate: PrinterSettingsDelegate?
    
    var printer: Printer? {
        didSet {
            refreshLabels()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(printerMainView)
        functionSelector.dataSource = self
        functionSelector.delegate = self
        
        refreshPrinterStatusButton.addTarget(self, action: #selector(getPrinterStatus), for: .touchUpInside)
        testPrinterButton.addTarget(self, action: #selector(testPrinter), for: .touchUpInside)
        
        self.printerMainView.addSubview(printerVisualSection)
        self.printerMainView.addSubview(printerDetailView)
        self.printerMainView.addSubview(printerFunctionView)
        self.printerMainView.addSubview(printerOptionsView)
        
        printerVisualSection.addSubview(printerImageView)
        printerVisualSection.addSubview(connectionTypeImageView)
        printerVisualSection.addSubview(activePrinterImage)
        
        printerDetailView.addSubview(printerDetailStack)
        
        printerDetailStack.addArrangedSubview(printerFunction)
        printerDetailStack.addArrangedSubview(printerModelLabel)
        printerDetailStack.addArrangedSubview(printerConnectionLabel)
        printerDetailStack.addArrangedSubview(printerAddress)
        printerDetailStack.addArrangedSubview(printerStatusLabel)
        
        printerFunctionView.addSubview(functionSelectorLabel)
        printerFunctionView.addSubview(functionSelector)
        
        printerOptionsView.addSubview(refreshPrinterStatusButton)
        printerOptionsView.addSubview(testPrinterButton)
        
        self.contentView.bringSubview(toFront: printerOptionsView)
        
        self.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint(item: printerMainView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: printerMainView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: printerMainView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -10).isActive = true
        
        NSLayoutConstraint(item: printerVisualSection, attribute: .top, relatedBy: .equal, toItem: printerMainView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: printerVisualSection, attribute: .leading, relatedBy: .equal, toItem: printerMainView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: printerVisualSection, attribute: .bottom, relatedBy: .equal, toItem: printerFunctionView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: printerDetailView, attribute: .top, relatedBy: .equal, toItem: printerMainView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: printerDetailView, attribute: .leading, relatedBy: .equal, toItem: printerVisualSection, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: printerDetailView, attribute: .trailing, relatedBy: .equal, toItem: printerMainView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
//        NSLayoutConstraint(item: printerDetailView, attribute: .bottom, relatedBy: .equal, toItem: printerFunctionView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: printerFunctionView, attribute: .leading, relatedBy: .equal, toItem: printerMainView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: printerFunctionView, attribute: .trailing, relatedBy: .equal, toItem: printerMainView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: printerFunctionView, attribute: .bottom, relatedBy: .equal, toItem: printerOptionsView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: printerOptionsView, attribute: .leading, relatedBy: .equal, toItem: printerMainView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: printerOptionsView, attribute: .trailing, relatedBy: .equal, toItem: printerMainView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: printerOptionsView, attribute: .bottom, relatedBy: .equal, toItem: printerMainView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: printerImageView, attribute: .leading, relatedBy: .equal, toItem: printerVisualSection, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: printerImageView, attribute: .centerY, relatedBy: .equal, toItem: printerVisualSection, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: connectionTypeImageView, attribute: .top, relatedBy: .equal, toItem: printerVisualSection, attribute: .top, multiplier: 1, constant: 15).isActive = true
        NSLayoutConstraint(item: connectionTypeImageView, attribute: .centerX, relatedBy: .equal, toItem: printerImageView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: activePrinterImage, attribute: .bottom, relatedBy: .equal, toItem: printerVisualSection, attribute: .bottom, multiplier: 1, constant: -15).isActive = true
        NSLayoutConstraint(item: activePrinterImage, attribute: .centerX, relatedBy: .equal, toItem: printerImageView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: printerDetailStack, attribute: .centerY, relatedBy: .equal, toItem: printerDetailView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: printerDetailStack, attribute: .leading, relatedBy: .equal, toItem: printerDetailView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: printerDetailStack, attribute: .trailing, relatedBy: .equal, toItem: printerDetailView, attribute: .trailing, multiplier: 1, constant: -30).isActive = true

        NSLayoutConstraint(item: functionSelectorLabel, attribute: .leading, relatedBy: .equal, toItem: printerFunctionView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: functionSelectorLabel, attribute: .centerY, relatedBy: .equal, toItem: printerFunctionView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: functionSelector, attribute: .leading, relatedBy: .equal, toItem: functionSelectorLabel, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: functionSelector, attribute: .centerY, relatedBy: .equal, toItem: printerFunctionView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: functionSelector, attribute: .trailing, relatedBy: .equal, toItem: printerFunctionView, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: functionSelector, attribute: .height, relatedBy: .lessThanOrEqual, toItem: printerFunctionView, attribute: .height, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: refreshPrinterStatusButton, attribute: .leading, relatedBy: .equal, toItem: printerOptionsView, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: refreshPrinterStatusButton, attribute: .centerY, relatedBy: .equal, toItem: printerOptionsView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: testPrinterButton, attribute: .trailing, relatedBy: .equal, toItem: printerOptionsView, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: testPrinterButton, attribute: .centerY, relatedBy: .equal, toItem: printerOptionsView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
    }
    
    func updatePrinterModel(){
        printerModelLabel.text = "Printer Model: " + (printer?.printerModel ?? "")
        updatePrinterImage()
    }
    
    func updatePrinterImage(){
        if printer?.printerModel?.starts(with: "TM-m30") == true {
            printerImageView.image = UIImage(named: "TM-m30-black")
        } else {
            printerImageView.image = UIImage(named: "TM-T20-black")
        }
    }
    
    func updateConnectionType(){
        if printer?.connectionType == "BT" {
            connectionTypeImageView.image = UIImage(named: "Bluetooth-logo")
        } else if printer?.connectionType == "TCP" {
            connectionTypeImageView.image = UIImage(named: "wifi-logo-blue")
        }
    }
    
    func refreshLabels(){
        updatePrinterModel()
        
        updateConnectionType()
        
        printerFunction.text = "Printer Function: " + (printer?.function ?? "None")
        printerModelLabel.text = "Printer Model: " + (printer?.printerModel ?? "")
        if printer?.connectionType == "BT"{
            printerConnectionLabel.text = "Connection Type: Bluetooth"
            printerAddress.text = "Address: " + (printer?.deviceName ?? "")
        } else if printer?.connectionType == "TCP" {
            printerConnectionLabel.text = "Connection Type: TCP via WiFi"
            printerAddress.text = "Address: " + (printer?.ipAddress ?? "")
        }
        
        if let selectFunctionPickerRow = NIMBUS.Print?.PrinterManager.printerFunctionOptions.index(of: printer?.function ?? "None" ) {
            functionSelector.selectRow(selectFunctionPickerRow, inComponent: 0, animated: true)
        }
        
        getPrinterStatus()
    }
    
    func testPrinter() {
        NIMBUS.Print?.printTestReceipt(printer: self.printer!)
    }

    func getPrinterStatus(){
        printerStatusLabel.text = "Status: ..."
        updatePrinterReady(status: "Checking")
        let status = NIMBUS.Print?.PrinterManager.getPrinterStatus(printer: self.printer!) ?? ""
        printerStatusLabel.text = "Status: " + status
        updatePrinterReady(status: status)
    }
    
    func updatePrinterReady(status: String){
        if status.contains("Ready") {
            activePrinterImage.image = UIImage(named: "ic_done_white_36pt")
            activePrinterImage.backgroundColor = UIColor.green
        } else if status != "Checking"{
            activePrinterImage.image = UIImage(named: "ic_error_outline_white_36pt")
            activePrinterImage.backgroundColor = UIColor.red
        } else {
            activePrinterImage.image = UIImage()
            activePrinterImage.backgroundColor = UIColor.clear
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return NIMBUS.Print?.PrinterManager.printerFunctionOptions.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return NIMBUS.Print?.PrinterManager.printerFunctionOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let functionality = NIMBUS.Print?.PrinterManager.printerFunctionOptions[row]{
            NIMBUS.Print?.PrinterManager.setPrinterFunctionality(printer: printer!, functionality: functionality)
            printerSettingsDelegate?.reloadPrinterTableData()
        }
    }
    
}
