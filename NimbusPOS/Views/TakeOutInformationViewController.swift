//
//  TakeOutInformationViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-05.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit
import MaterialComponents

class TakeOutInformationViewController: UIViewController, UITextFieldDelegate {
    var startOrderButton: MDCRaisedButton = {
        let startOrderButton = MDCRaisedButton()
        startOrderButton.translatesAutoresizingMaskIntoConstraints = false
        startOrderButton.backgroundColor = UIColor.gray
        startOrderButton.setTitle("Start Order", for: .normal)
        startOrderButton.setTitleColor(UIColor.white, for: .normal)
        startOrderButton.addTarget(self, action: #selector(goToOrdersView), for: .touchUpInside)
        return startOrderButton
    }()
    
    var goBackButton: UIButton = {
        let goBackButton = UIButton()
        goBackButton.translatesAutoresizingMaskIntoConstraints = false
        goBackButton.setImage(UIImage(named: "ic_arrow_back"), for: .normal)
        goBackButton.contentMode = .scaleAspectFit
        goBackButton.backgroundColor = UIColor.white
        goBackButton.addTarget(self, action: #selector(backToOrderTypeSelector), for: UIControlEvents.touchUpInside)
        goBackButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        goBackButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return goBackButton
    }()
    
    var infoStackView: UIStackView = {
        let infoStackView = UIStackView()
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        infoStackView.axis = .vertical
        infoStackView.distribution = .equalSpacing
        return infoStackView
    }()
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = MDCTypography.titleFont()
        titleLabel.backgroundColor = UIColor.white
        titleLabel.textColor = UIColor.gray
        titleLabel.textAlignment = .center
        titleLabel.text = "Take-Out Info:"
        return titleLabel
    }()
    
    let name: MDCTextField = {
        let name = MDCTextField()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.autocapitalizationType = .words
        name.backgroundColor = .white
        name.placeholder = "Name"
        return name
    }()
    var nameController: MDCTextInputControllerOutlined?

    let phone: MDCTextField = {
        let phone = MDCTextField()
        phone.translatesAutoresizingMaskIntoConstraints = false
        phone.autocapitalizationType = .words
        phone.backgroundColor = .white
        phone.placeholder = "Phone"
        return phone
    }()
    var phoneController: MDCTextInputControllerOutlined?
    
    let instructions: MDCTextField = {
        let instructions = MDCTextField()
        instructions.translatesAutoresizingMaskIntoConstraints = false
        instructions.backgroundColor = .white
        instructions.placeholder = "Take-Out Instructions / Notes:"
        return instructions
    }()
    var instructionsController: MDCTextInputControllerOutlined?
    
    var orderTypeSelectorDelegate: OrderTypeSelectorDelegate?
    var orderViewManagerDelegate: OrderViewManagerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        name.delegate = self
        phone.delegate = self
        instructions.delegate = self
        
        infoStackView.addArrangedSubview(titleLabel)
        infoStackView.addArrangedSubview(name)
        infoStackView.addArrangedSubview(phone)
        infoStackView.addArrangedSubview(instructions)
        infoStackView.addArrangedSubview(startOrderButton)
        
        self.view.addSubview(infoStackView)
        self.view.addSubview(goBackButton)
        
        nameController = MDCTextInputControllerOutlined(textInput: name)
        phoneController = MDCTextInputControllerOutlined(textInput: phone)
        instructionsController = MDCTextInputControllerOutlined(textInput: instructions)
    }
    
    override func viewWillLayoutSubviews() {
        NSLayoutConstraint(item: infoStackView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: infoStackView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true

        let stackItems = [titleLabel, name, phone, instructions, startOrderButton]
        stackItems.forEach {stackItem in
            NSLayoutConstraint(item: stackItem, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80).isActive = true
            NSLayoutConstraint(item: stackItem, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 350).isActive = true
        }

        NSLayoutConstraint(item: goBackButton, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: goBackButton, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 10).isActive = true
    }
    
    func backToOrderTypeSelector() {
        orderTypeSelectorDelegate?.backToMainSelector()
    }
    
    func goToOrdersView() {
        var info = orderInfoSchema()
        info.orderType = _OrderTypes.TakeOut.rawValue
        info.orderName = name.text ?? ""
        info.orderPhone = phone.text ?? ""
        info.instructions = instructions.text ?? ""
        
        orderTypeSelectorDelegate?.setOrderInformation(info: info)
    }
    
    func fillInAnyEnteredOrderTypeInformation(){
        if let orderInfo = NIMBUS.OrderCreation?.orderInformation {
            name.text = orderInfo.orderName
            phone.text = orderInfo.orderPhone
            instructions.text = orderInfo.instructions
        }
    }
    
    
}
