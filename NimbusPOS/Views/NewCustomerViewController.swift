//
//  NewCustomerViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-02.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit
import MaterialComponents

class NewCustomerViewController: UIViewController {
    var nameField: SmartTextFieldNewInputView = SmartTextFieldNewInputView()
    var phoneField: SmartTextFieldNewInputView = SmartTextFieldNewInputView()
    var emailField: SmartTextFieldNewInputView = SmartTextFieldNewInputView()
    
    var createNewCustomerButton: UIButton = UIButton()
    var cancelNewCustomerButton: UIButton = UIButton()
    
    var creationErrorMessage = MDCSnackbarMessage()
    
    var customerViewManagerDelegate: CustomersViewManagerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.textField.placeholder = "Name"
        phoneField.textField.placeholder = "Phone"
        phoneField.textField.keyboardType = .numberPad
        emailField.textField.placeholder = "Email"
        emailField.textField.autocapitalizationType = .none
        emailField.textField.autocorrectionType = .no
        
        self.view.addSubview(nameField)
        self.view.addSubview(phoneField)
        self.view.addSubview(emailField)

    }
    
    override func viewWillLayoutSubviews() {
        let labelGaps: CGFloat = 10
        let labelHeight: CGFloat = 40
        let labelWidth: CGFloat = self.view.frame.width - 10
        let labelSize: CGSize = CGSize(width: labelWidth, height: labelHeight)
        
        nameField.frame = CGRect(origin: CGPoint(x: 10, y: 10), size: labelSize)
        phoneField.frame = CGRect(origin: CGPoint(x: 10, y: 10 + labelHeight + labelGaps), size: labelSize)
        emailField.frame = CGRect(origin: CGPoint(x: 10, y: 10 + (labelHeight + labelGaps) * 2), size: labelSize)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func createNewCustomer() {
        let name = nameField.text ?? ""
        let phoneAsString = phoneField.text ?? ""
        let phone: Int64 = Int64(Int(phoneAsString.digitsOnly()) ?? 0)
        let email = emailField.text ?? ""
        
        var newCustomerId: String
        
        let (resultSuccess, resultMessage) = (NIMBUS.Customers?.attemptNewCustomerCreation(name: name, phone: phone, email: email))!
        if resultSuccess == false {
            creationErrorMessage.text = resultMessage
            MDCSnackbarManager.show(creationErrorMessage)
        } else if resultSuccess == true {
            newCustomerId = resultMessage
            customerViewManagerDelegate?.highlightCustomer(customerId: newCustomerId)
            customerViewManagerDelegate?.dismissNewCustomerModal()
        }
    }
    
    func cancelNewCustomerCreation() {
        dismiss(animated: true, completion: nil)
    }
}
