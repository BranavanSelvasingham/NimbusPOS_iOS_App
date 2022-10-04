//
//  loginViewBox.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-16.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents.MaterialCards
import MaterialComponents.MDCTypography
import MaterialComponents.MaterialTextFields

protocol loginViewBoxDelegate {
    func loginAttemptStarted()
    func loginCompleted(loginSuccessful: Bool, message: String)
    func appAuthentication(isAuthenticated: Bool, message: String)
}

class loginViewBox: UIViewWithShadow {
    let loginBoxHeader: UILabel = {
        let label = UILabel()
        label.text = "Login"
        label.textColor = UIColor.gray
        label.font = MDCTypography.titleFont()
        label.textAlignment = .center
        return label
    }()

    let usernameTextField: MDCTextField = {
        let textFieldFloating = MDCTextField()
        textFieldFloating.placeholder = "Username"
        textFieldFloating.autocapitalizationType = .none
        return textFieldFloating
    }()
    
    let passwordTextField: MDCTextField = {
        let textFieldFloating = MDCTextField()
        textFieldFloating.placeholder = "Password"
        textFieldFloating.autocapitalizationType = .none
        textFieldFloating.isSecureTextEntry = true
        return textFieldFloating
    }()
    
    let enterButton: UIButton = {
        let enter = UIButton()
        enter.setTitle("Enter", for: .normal)
        enter.setTitleColor(UIColor.white, for: .normal)
        enter.backgroundColor = UIColor.darkGray
        enter.titleLabel?.font = MDCTypography.titleFont()
        enter.layer.borderWidth = 0
        enter.addTarget(self, action: #selector(login), for: .touchDown)
        if #available(iOS 11.0, *) {
            enter.clipsToBounds = true
            enter.layer.cornerRadius = 30
            enter.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            // Fallback on earlier versions
        }
        return enter
    }()
    
    let enterButtonContainerView: UIView = {
        let container = UIView()
        container.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 30)
        return container
    }()
    
    var loginDelegate: loginViewBoxDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setDefaultElevation()
        self.layer.cornerRadius = 30
        self.backgroundColor = UIColor.white
        
        loginBoxHeader.frame = CGRect(x: 0, y: 10, width: self.frame.width, height: 30)
        usernameTextField.frame = CGRect(x: 20, y: 70, width: self.frame.width - 40, height: 50)
        passwordTextField.frame = CGRect(x: 20, y: 160, width: self.frame.width - 40, height: 50)
        enterButton.frame = CGRect(x: -1, y: self.frame.height - 50, width: self.frame.width + 2, height: 50)
        
        self.addSubview(loginBoxHeader)
        self.addSubview(usernameTextField)
        self.addSubview(passwordTextField)
        self.addSubview(enterButton)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(loginAttemptNotification(notification:)), name: Notification.Name.onResultsFromLoginAttempt, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appAuthenticationAttemptNotification(notification:)), name: Notification.Name.onAppAuthenticationAttempt, object: nil)
    }
    
    @objc func loginAttemptNotification(notification: NSNotification){
        let loginAttempt: notificationLoginAttempt = notification.object as! notificationLoginAttempt
        loginDelegate?.loginCompleted(loginSuccessful: loginAttempt.loginSuccessful, message: loginAttempt.message)
    }
    
    @objc func appAuthenticationAttemptNotification(notification: NSNotification){
        let appAuthenticationAttempt: notificationAppAuthenticationAttempt = notification.object as! notificationAppAuthenticationAttempt
        if appAuthenticationAttempt.appAuthenticationSuccessful == true {
            loginDelegate?.appAuthentication(isAuthenticated: appAuthenticationAttempt.appAuthenticationSuccessful, message: appAuthenticationAttempt.message)
        } else {
            NIMBUS.Devices?.checkForDeviceAuthentication()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func login(){
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        if let user = username {
            if let pass = password {
                self.endEditing(true)
                loginDelegate?.loginAttemptStarted()
                NIMBUS.Devices?.loginFromDevice(username: user, password: pass)
            }
        }
    }
}
