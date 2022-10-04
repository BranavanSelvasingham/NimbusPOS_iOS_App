//
//  EmployeeAuthenticate.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-25.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents
import UIKit

protocol EmployeeAuthenticateDelegate {
    func employeeAuthenticated(employee: Employee)
    func employeeLoggedOut(employee: Employee?)
    func employeeAuthenticationAborted()
    func employeeAuthenticationFailed()
}

class EmployeeAuthenticateViewController: UIViewController {
    var employee: Employee? {
        didSet {
            employeeNameLabel.text = employee?.name
            resetView()
        }
    }
    var authenticationRequestorDelegate: EmployeeAuthenticateDelegate?
    var isAuthenticated: Bool = false
    var employeeNameLabel: UILabel = UILabel()
    var lockIconView: UIImageView = UIImageView()
    var pinEntryField: UITextField = UITextField()
    var verifyPinButton: MDCFloatingButton = MDCFloatingButton()
    var logoutButton: MDCFloatingButton = MDCFloatingButton()
    
    override func viewDidLoad() {
        lockIconView.image = UIImage(named: "ic_lock_outline_48pt")
        
        employeeNameLabel.font = MDCTypography.titleFont()
        employeeNameLabel.textAlignment = .center
        self.view.addSubview(employeeNameLabel)
        self.view.addSubview(lockIconView)
        
        pinEntryField.font = MDCTypography.titleFont()
        pinEntryField.isSecureTextEntry = true
        pinEntryField.borderStyle = .roundedRect
        pinEntryField.keyboardType = .numberPad
        pinEntryField.textAlignment = .center
        
        self.view.addSubview(pinEntryField)
        
        verifyPinButton.addTarget(self, action: #selector(verifyPinEntry), for: .touchUpInside)
        verifyPinButton.setImage(UIImage(named: "ic_lock_open_white"), for: .normal)
        verifyPinButton.backgroundColor = UIColor.gray
        self.view.addSubview(verifyPinButton)
        
        logoutButton.addTarget(self, action: #selector(logoutEmployee), for: .touchUpInside)
        logoutButton.setImage(UIImage(named: "ic_lock_white"), for: .normal)
        logoutButton.backgroundColor = UIColor.gray
        self.view.addSubview(logoutButton)
        
        logoutButton.isHidden = true
    }
    
    func verifyPinEntry(){
        let enteredPin: String = pinEntryField.text ?? ""
        if enteredPin == employee?.pin {
            authenticationRequestorDelegate?.employeeAuthenticated(employee: employee!)
            employeeSuccessfullyAuthenticated()
        } else {
            pinEntryField.text = ""
            authenticationRequestorDelegate?.employeeAuthenticationFailed()
        }
    }
    
    func resetView(){
        pinEntryField.text = ""
        isAuthenticated = false
        lockIconView.image = UIImage(named: "ic_lock_outline_48pt")
        logoutButton.isHidden = true
        pinEntryField.isHidden = false
        verifyPinButton.isHidden = false
    }
    
    override func viewWillLayoutSubviews() {
        let employeeNameWidth: CGFloat = 200
        employeeNameLabel.frame.origin = CGPoint(x: (self.view.frame.width - employeeNameWidth)/2, y: 50)
        employeeNameLabel.frame.size = CGSize(width: employeeNameWidth, height: 30)
        
        let iconViewWidth: CGFloat = 50 //self.view.frame.width * 0.5
        let iconViewSize: CGSize = CGSize(width: iconViewWidth, height: iconViewWidth)
        let iconViewOrigin: CGPoint = CGPoint(x: (self.view.frame.width - iconViewWidth)/2 , y: 100)
        lockIconView.frame = CGRect(origin: iconViewOrigin, size: iconViewSize)
        
        let pinEnterViewWidth: CGFloat = 150
        pinEntryField.frame.origin = CGPoint(x: (self.view.frame.width - pinEnterViewWidth)/2 , y: iconViewOrigin.y + iconViewSize.height + 20)
        pinEntryField.frame.size = CGSize(width: pinEnterViewWidth, height: 50)
        
        verifyPinButton.frame.origin = CGPoint(x: pinEntryField.frame.origin.x + pinEntryField.frame.width + 5, y: pinEntryField.frame.origin.y)
        verifyPinButton.frame.size = CGSize(width: 50, height: 50)
        
        logoutButton.frame.size = CGSize(width: 50, height: 50)
        logoutButton.frame.origin = CGPoint(x: (self.view.frame.width - logoutButton.frame.width)/2 , y: lockIconView.frame.maxY + 20)
    }
    
    func employeeSuccessfullyAuthenticated(){
        isAuthenticated = true
        lockIconView.image = UIImage(named: "ic_lock_open_48pt")
        logoutButton.isHidden = false
        pinEntryField.isHidden = true
        verifyPinButton.isHidden = true
    }
    
    func logoutEmployee(){
        resetView()
        authenticationRequestorDelegate?.employeeLoggedOut(employee: employee)
    }
    
}
