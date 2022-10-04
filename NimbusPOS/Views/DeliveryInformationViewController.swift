//
//  DeliveryInformationViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-05.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit
import MaterialComponents

class DeliveryInformationViewController: UIViewController, UITextFieldDelegate {
    
    var orderTypeSelectorDelegate: OrderTypeSelectorDelegate?
    var orderViewManagerDelegate: OrderViewManagerDelegate?
    
    var name: MDCTextField = {
        let name = MDCTextField()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.autocapitalizationType = .words
        name.backgroundColor = .white
        name.placeholder = "Name"
        name.widthAnchor.constraint(equalToConstant: 300).isActive = true
        return name
    }()
    var nameController: MDCTextInputControllerOutlined?
    
    var phone: MDCTextField = {
        let phone = MDCTextField()
        phone.translatesAutoresizingMaskIntoConstraints = false
        phone.autocapitalizationType = .words
        phone.backgroundColor = .white
        phone.placeholder = "Phone"
        phone.widthAnchor.constraint(equalToConstant: 300).isActive = true
        return phone
    }()
    var phoneController: MDCTextInputControllerOutlined?
     
    var unitNumber: MDCTextField = {
        let unit = MDCTextField()
        unit.translatesAutoresizingMaskIntoConstraints = false
        unit.autocapitalizationType = .words
        unit.backgroundColor = .white
        unit.placeholder = "Unit"
        unit.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return unit
    }()
    var unitController: MDCTextInputControllerOutlined?
     
    var buzzerNumber: MDCTextField = {
        let buzzer = MDCTextField()
        buzzer.translatesAutoresizingMaskIntoConstraints = false
        buzzer.autocapitalizationType = .words
        buzzer.backgroundColor = .white
        buzzer.placeholder = "Buzzer"
        buzzer.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return buzzer
    }()
    var buzzerController: MDCTextInputControllerOutlined?
     
    var streetNumber: MDCTextField = {
        let streetNumber = MDCTextField()
        streetNumber.translatesAutoresizingMaskIntoConstraints = false
        streetNumber.autocapitalizationType = .words
        streetNumber.backgroundColor = .white
        streetNumber.placeholder = "Street #"
        streetNumber.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return streetNumber
    }()
    var streetNumberController: MDCTextInputControllerOutlined?
     
    var streetName: MDCTextField = {
        let streetName = MDCTextField()
        streetName.translatesAutoresizingMaskIntoConstraints = false
        streetName.autocapitalizationType = .words
        streetName.backgroundColor = .white
        streetName.placeholder = "Street Name"
        streetName.widthAnchor.constraint(equalToConstant: 300).isActive = true
        return streetName
    }()
    var streetNameController: MDCTextInputControllerOutlined?
     
    var city: MDCTextField = {
        let city = MDCTextField()
        city.translatesAutoresizingMaskIntoConstraints = false
        city.autocapitalizationType = .words
        city.backgroundColor = .white
        city.placeholder = "City"
        city.widthAnchor.constraint(equalToConstant: 200).isActive = true
        return city
    }()
    var cityController: MDCTextInputControllerOutlined?
     
    var postalCode: MDCTextField = {
        let postalCode = MDCTextField()
        postalCode.translatesAutoresizingMaskIntoConstraints = false
        postalCode.autocapitalizationType = .words
        postalCode.backgroundColor = .white
        postalCode.placeholder = "Postal Code"
        postalCode.widthAnchor.constraint(equalToConstant: 150).isActive = true
        return postalCode
    }()
    var postalCodeController: MDCTextInputControllerOutlined?
     
    var instructions: MDCTextField = {
        let instructions = MDCTextField()
        instructions.translatesAutoresizingMaskIntoConstraints = false
        instructions.autocapitalizationType = .words
        instructions.backgroundColor = .white
        instructions.placeholder = "Instructions"
        instructions.widthAnchor.constraint(equalToConstant: 500).isActive = true
        return instructions
    }()
    var instructionsController: MDCTextInputControllerOutlined?
     
    let infoStackView: UIStackView = UIStackView()
    
    let infoBlockView: UIView = {
        let block = UIView()
        block.translatesAutoresizingMaskIntoConstraints = false
        return block
    }()
    
    let nameBlock: UIView = {
        let block = UIView()
        block.translatesAutoresizingMaskIntoConstraints = false
        return block
    }()
    let phoneBlock: UIView = {
        let block = UIView()
        block.translatesAutoresizingMaskIntoConstraints = false
        return block
    }()
    let unitBuzzerBlock: UIView = {
        let block = UIView()
        block.translatesAutoresizingMaskIntoConstraints = false
        return block
    }()
    let streetBlock: UIView = {
        let block = UIView()
        block.translatesAutoresizingMaskIntoConstraints = false
        return block
    }()
    let regionBlock: UIView = {
        let block = UIView()
        block.translatesAutoresizingMaskIntoConstraints = false
        return block
    }()
    let instructionsBlock: UIView = {
        let block = UIView()
        block.translatesAutoresizingMaskIntoConstraints = false
        return block
    }()
    
    var startOrderButton: MDCRaisedButton = {
        let startOrderButton = MDCRaisedButton()
        startOrderButton.translatesAutoresizingMaskIntoConstraints = false
        startOrderButton.backgroundColor = UIColor.gray
        startOrderButton.setTitle("Start Order", for: .normal)
        startOrderButton.setTitleColor(UIColor.white, for: .normal)
        startOrderButton.addTarget(self, action: #selector(goToOrdersView), for: .touchUpInside)
        startOrderButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        startOrderButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        return startOrderButton
    }()
    
    var goBackButton: UIButton = {
        let goBackButton = UIButton()
        goBackButton.translatesAutoresizingMaskIntoConstraints = false
        goBackButton.setImage(UIImage(named: "ic_arrow_back"), for: .normal)
        goBackButton.contentMode = .scaleAspectFit
        goBackButton.backgroundColor = UIColor.white
        goBackButton.addTarget(self, action: #selector(backToOrderTypeSelector), for: UIControlEvents.touchUpInside)
        goBackButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        goBackButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return goBackButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        name.delegate = self
        phone.delegate = self
        unitNumber.delegate = self
        buzzerNumber.delegate = self
        streetNumber.delegate = self
        streetName.delegate = self
        city.delegate = self
        postalCode.delegate = self
        instructions.delegate = self
        
        infoStackView.axis = .vertical
        infoStackView.distribution = .equalSpacing
        infoStackView.alignment = .leading
        
        nameBlock.addSubview(name)
        phoneBlock.addSubview(phone)
        unitBuzzerBlock.addSubview(unitNumber)
        unitBuzzerBlock.addSubview(buzzerNumber)
        streetBlock.addSubview(streetNumber)
        streetBlock.addSubview(streetName)
        regionBlock.addSubview(city)
        regionBlock.addSubview(postalCode)
        instructionsBlock.addSubview(instructions)
        
        infoStackView.addArrangedSubview(nameBlock)
        infoStackView.addArrangedSubview(phoneBlock)
        infoStackView.addArrangedSubview(unitBuzzerBlock)
        infoStackView.addArrangedSubview(streetBlock)
        infoStackView.addArrangedSubview(regionBlock)
        infoStackView.addArrangedSubview(instructionsBlock)
        
        self.view.addSubview(infoStackView)
        self.view.addSubview(goBackButton)
        self.view.addSubview(startOrderButton)
        
        nameController = MDCTextInputControllerOutlined(textInput: name)
        phoneController = MDCTextInputControllerOutlined(textInput: phone)
        unitController = MDCTextInputControllerOutlined(textInput: unitNumber)
        buzzerController = MDCTextInputControllerOutlined(textInput: buzzerNumber)
        streetNumberController = MDCTextInputControllerOutlined(textInput: streetNumber)
        streetNameController = MDCTextInputControllerOutlined(textInput: streetName)
        cityController = MDCTextInputControllerOutlined(textInput: city)
        postalCodeController = MDCTextInputControllerOutlined(textInput: postalCode)
        instructionsController = MDCTextInputControllerOutlined(textInput: instructions)
    }
    
    override func viewWillLayoutSubviews() {
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: infoStackView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: infoStackView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.8, constant: 0).isActive = true
        NSLayoutConstraint(item: infoStackView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: name, attribute: .top, relatedBy: .equal, toItem: nameBlock, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: name, attribute: .leading, relatedBy: .equal, toItem: nameBlock, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: name, attribute: .bottom, relatedBy: .equal, toItem: nameBlock, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: phone, attribute: .top, relatedBy: .equal, toItem: phoneBlock, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: phone, attribute: .leading, relatedBy: .equal, toItem: phoneBlock, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: phone, attribute: .bottom, relatedBy: .equal, toItem: phoneBlock, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: unitNumber, attribute: .top, relatedBy: .equal, toItem: unitBuzzerBlock, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: unitNumber, attribute: .leading, relatedBy: .equal, toItem: unitBuzzerBlock, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: unitNumber, attribute: .bottom, relatedBy: .equal, toItem: unitBuzzerBlock, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: buzzerNumber, attribute: .top, relatedBy: .equal, toItem: unitBuzzerBlock, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: buzzerNumber, attribute: .leading, relatedBy: .equal, toItem: unitNumber, attribute: .trailing, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: buzzerNumber, attribute: .bottom, relatedBy: .equal, toItem: unitBuzzerBlock, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: streetNumber, attribute: .top, relatedBy: .equal, toItem: streetBlock, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: streetNumber, attribute: .leading, relatedBy: .equal, toItem: streetBlock, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: streetNumber, attribute: .bottom, relatedBy: .equal, toItem: streetBlock, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: streetName, attribute: .top, relatedBy: .equal, toItem: streetBlock, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: streetName, attribute: .leading, relatedBy: .equal, toItem: streetNumber, attribute: .trailing, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: streetName, attribute: .bottom, relatedBy: .equal, toItem: streetBlock, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: city, attribute: .top, relatedBy: .equal, toItem: regionBlock, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: city, attribute: .leading, relatedBy: .equal, toItem: regionBlock, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: city, attribute: .bottom, relatedBy: .equal, toItem: regionBlock, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: postalCode, attribute: .top, relatedBy: .equal, toItem: regionBlock, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: postalCode, attribute: .leading, relatedBy: .equal, toItem: city, attribute: .trailing, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: postalCode, attribute: .bottom, relatedBy: .equal, toItem: regionBlock, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: instructions, attribute: .top, relatedBy: .equal, toItem: instructionsBlock, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: instructions, attribute: .leading, relatedBy: .equal, toItem: instructionsBlock, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: instructions, attribute: .bottom, relatedBy: .equal, toItem: instructionsBlock, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: goBackButton, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: goBackButton, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        
        NSLayoutConstraint(item: startOrderButton, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: startOrderButton, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
    }
    
    
    func backToOrderTypeSelector(_ sender: Any) {
        orderTypeSelectorDelegate?.backToMainSelector()
    }
    
    func goToOrdersView(_ sender: Any) {
        var info = orderInfoSchema()
        info.orderType = _OrderTypes.Delivery.rawValue
        info.orderName = name.text ?? ""
        info.orderPhone = phone.text ?? ""
        info.unitNumber = unitNumber.text ?? ""
        info.buzzerNumber = buzzerNumber.text ?? ""
        info.streetNumber = streetNumber.text ?? ""
        info.street = streetName.text ?? ""
        info.city = city.text ?? ""
        info.postalCode = postalCode.text ?? ""
        info.instructions = instructions.text ?? ""
        
        orderTypeSelectorDelegate?.setOrderInformation(info: info)
    }
    
    func fillInAnyEnteredOrderTypeInformation(){
        if let orderInfo = NIMBUS.OrderCreation?.orderInformation {
            name.text = orderInfo.orderName
            phone.text = orderInfo.orderPhone
            unitNumber.text = orderInfo.unitNumber
            buzzerNumber.text = orderInfo.buzzerNumber
            streetNumber.text = orderInfo.streetNumber
            streetName.text = orderInfo.street
            city.text = orderInfo.city
            postalCode.text = orderInfo.postalCode
            instructions.text = orderInfo.instructions
        }
    }
}
