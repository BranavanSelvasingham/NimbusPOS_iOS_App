//
//  CustomerAttributesViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-03.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit
import MaterialComponents

class CustomerAttributesViewController: UIViewController, UITextViewDelegate {

    var customer: Customer? {
        didSet{
            refreshFields()
        }
    }
    
    var nameField: SmartTextFieldUpdateView = SmartTextFieldUpdateView()
    var emailField: SmartTextFieldUpdateView = SmartTextFieldUpdateView()
    var phoneField: SmartTextFieldUpdateView = SmartTextFieldUpdateView()
    var creationErrorMessage = MDCSnackbarMessage()
    var notesAndPreferenceTextView: UITextView = UITextView()
    var notesBackground: UIImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.textField.placeholder = "Name"
        phoneField.textField.placeholder = "Phone"
        phoneField.textField.keyboardType = .numberPad
        emailField.textField.placeholder = "Email"
        emailField.textField.autocapitalizationType = .none
        emailField.textField.autocorrectionType = .no
        
        nameField.saveButton.addTarget(self, action: #selector(updateCustomerName), for: .touchUpInside)
        phoneField.saveButton.addTarget(self, action: #selector(updateCustomerPhone), for: .touchUpInside)
        emailField.saveButton.addTarget(self, action: #selector(updateCustomerEmail), for: .touchUpInside)
        
        nameField.textField.font = MDCTypography.titleFont()
        phoneField.textField.font = MDCTypography.body2Font()
        emailField.textField.font = MDCTypography.body2Font()
        
        self.view.addSubview(nameField)
        self.view.addSubview(emailField)
        self.view.addSubview(phoneField)
        
        notesAndPreferenceTextView.font = MDCTypography.body2Font()
        notesAndPreferenceTextView.delegate = self
        notesAndPreferenceTextView.backgroundColor = UIColor.clear
        notesAndPreferenceTextView.layer.borderColor = UIColor.lightGray.cgColor
        notesAndPreferenceTextView.layer.borderWidth = 1
        notesAndPreferenceTextView.text = "Customer notes and preferences..."
        self.view.addSubview(notesAndPreferenceTextView)
        let backgroundImage = UIImage(named: "background_paper_white_1")
        notesBackground.image = backgroundImage
        notesBackground.contentMode = .scaleAspectFill
        notesBackground.clipsToBounds = true
        
        self.view.addSubview(notesBackground)
        self.view.sendSubview(toBack: notesBackground)
        
        self.view.autoresizesSubviews = true

    }
    
    override func viewWillLayoutSubviews() {
        let labelGaps: CGFloat = 10
        let labelHeight: CGFloat = 40
        let labelWidth: CGFloat = self.view.frame.width - 10
        let labelSize: CGSize = CGSize(width: labelWidth, height: labelHeight)
        
        nameField.frame = CGRect(origin: CGPoint(x: 10, y: 10), size: labelSize)
        phoneField.frame = CGRect(origin: CGPoint(x: 10, y: 10 + labelHeight + labelGaps), size: labelSize)
        emailField.frame = CGRect(origin: CGPoint(x: 10, y: 10 + (labelHeight + labelGaps) * 2), size: labelSize)

        notesAndPreferenceTextView.frame = CGRect(origin: CGPoint(x: 10, y: 10 + (labelHeight + labelGaps) * 3 ), size: CGSize(width: labelWidth - 10, height: 150))
        notesAndPreferenceTextView.frame.origin = CGPoint(x: 10, y: 10 + (labelHeight + labelGaps) * 3 )
        notesAndPreferenceTextView.frame.size = CGSize(width: labelWidth - 10, height: self.view.frame.height - notesAndPreferenceTextView.frame.origin.y - 10 )
        notesBackground.frame = notesAndPreferenceTextView.frame
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func refreshFields(){
        nameField.text = customer?.name
        emailField.text = customer?.email
        
        var phoneString = String(describing: customer?.phone ?? 0)
        phoneString = phoneString.formatPhoneNumber() ?? ""
        phoneField.text = phoneString
        
        if customer?.notes != nil {
            notesAndPreferenceTextView.text = customer?.notes
        } else {
            notesAndPreferenceTextView.text = "Customer notes and preferences..."
        }
    }
    
    func updateCustomerName(){
        let customerName: String = nameField.text ?? ""
        if let customerId = customer?.id {
            let (resultSuccess, resultMessage) = NIMBUS.Customers?.updateCustomerName(customerId: customerId, name: customerName) ?? (false, "")
            if resultSuccess == false {
                creationErrorMessage.text = resultMessage
                MDCSnackbarManager.show(creationErrorMessage)
            } else {
                creationErrorMessage.text = ""
            }
        }
    }
    
    func updateCustomerPhone(){
        let customerPhone: String = phoneField.text ?? ""
        if let customerId = customer?.id {
            let phone: Int64 = Int64(Int(customerPhone.digitsOnly()) ?? 0)
            NIMBUS.Customers?.updateCustomerPhone(customerId: customerId, phone: phone)
        }
    }
    
    func updateCustomerEmail(){
        var customerEmail: String = emailField.text ?? ""
        customerEmail = customerEmail.lowercased()
        
        if let customerId = customer?.id {
            let (resultSuccess, resultMessage) = NIMBUS.Customers?.updateCustomerEmail(customerId: customerId, email: customerEmail) ?? (false, "")
            if resultSuccess == false {
                creationErrorMessage.text = resultMessage
                MDCSnackbarManager.show(creationErrorMessage)
            } else {
                creationErrorMessage.text = ""
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let customerNotes: String = textView.text ?? ""
        if let customerId = customer?.id {
            NIMBUS.Customers?.updateCustomerNotes(customerId: customerId, notes: customerNotes)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let customerNotes: String = textView.text ?? ""
        if let customerId = customer?.id {
            NIMBUS.Customers?.updateCustomerNotes(customerId: customerId, notes: customerNotes)
        }
    }
}
