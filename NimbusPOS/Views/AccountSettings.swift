//
//  AccountSettings.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-22.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class AccountSettings: UIViewController {
    
    let businessDisplayView: BusinessNameTile = {
        let businessDisplayViewFrame: CGRect = CGRect(x: 10, y: 10, width: 200, height: 50)
        let businessDisplayView = BusinessNameTile(frame: businessDisplayViewFrame, blockSize: .large, textColor: UIColor.darkGray)
        businessDisplayView.translatesAutoresizingMaskIntoConstraints = false
        businessDisplayView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return businessDisplayView
    }()
    
    let authenticatedImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_done_white_48pt"))
        imageView.backgroundColor = UIColor.green
        imageView.layer.cornerRadius = 50
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.isHidden = true
        return imageView
    }()
    
    let authenticatedStatusLabel: UILabel = {
        let label = UILabel()
        label.font = MDCTypography.subheadFont()
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Authenticated"
        label.isHidden = true
        return label
    }()
    
    let loader: MDCActivityIndicator = {
        let loader = MDCActivityIndicator()
        loader.indicatorMode = .indeterminate
        loader.startAnimating()
        loader.cycleColors = [UIColor.blue, UIColor.lightGray]
        loader.translatesAutoresizingMaskIntoConstraints = false
        return loader
    }()
    
    let logoutButton: MDCRaisedButton = {
        let button = MDCRaisedButton()
        button.setTitle("Logout", for: .normal)
        button.setTitleFont(MDCTypography.titleFont(), for: .normal)
        button.backgroundColor = UIColor.red
        button.setTitleColor(UIColor.white, for: .normal)
        button.isUppercaseTitle = false
        button.addTarget(self, action: #selector(logoutClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 150).isActive = true
        button.isHidden = true
        return button
    }()
    
    let loginButton: MDCRaisedButton = {
        let button = MDCRaisedButton()
        button.setTitle("Login", for: .normal)
        button.setTitleFont(MDCTypography.titleFont(), for: .normal)
        button.backgroundColor = UIColor().nimbusBlue
        button.setTitleColor(UIColor.white, for: .normal)
        button.isUppercaseTitle = false
        button.addTarget(self, action: #selector(loginClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 150).isActive = true
        button.isHidden = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(businessDisplayView)
        self.view.addSubview(authenticatedImage)
        self.view.addSubview(authenticatedStatusLabel)
        self.view.addSubview(logoutButton)
        self.view.addSubview(loginButton)
        self.view.addSubview(loader)
        
        self.view.sendSubview(toBack: loader)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        NSLayoutConstraint(item: authenticatedImage, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: authenticatedImage, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: loader, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: loader, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: businessDisplayView, attribute: .bottom, relatedBy: .equal, toItem: authenticatedImage, attribute: .top, multiplier: 1, constant: -100).isActive = true
        NSLayoutConstraint(item: businessDisplayView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: authenticatedStatusLabel, attribute: .top, relatedBy: .equal, toItem: authenticatedImage, attribute: .bottom, multiplier: 1, constant: 5).isActive = true
        NSLayoutConstraint(item: authenticatedStatusLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: loginButton, attribute: .top, relatedBy: .equal, toItem: authenticatedImage, attribute: .bottom, multiplier: 1, constant: 150).isActive = true
        NSLayoutConstraint(item: loginButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true

        NSLayoutConstraint(item: logoutButton, attribute: .top, relatedBy: .equal, toItem: authenticatedImage, attribute: .bottom, multiplier: 1, constant: 150).isActive = true
        NSLayoutConstraint(item: logoutButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkForAuthentication()
    }
    
    func checkForAuthentication(){
        authenticatedImage.isHidden = true
        authenticatedStatusLabel.isHidden = true
        loginButton.isHidden = true
        logoutButton.isHidden = true
        
        if NIMBUS.Devices?.appAuthenticated == true {
            authenticatedImage.image = UIImage(named: "ic_done_white_48pt")
            authenticatedImage.backgroundColor = UIColor.green
            
            authenticatedStatusLabel.text = "Authenticated"
            
            logoutButton.isHidden = false
            loginButton.isHidden = true
            
        } else {
            authenticatedImage.image = UIImage(named: "ic_error_outline_white_48pt")
            authenticatedImage.backgroundColor = UIColor.red

            authenticatedStatusLabel.text = "Not Authenticated"
            
            loginButton.isHidden = false
            logoutButton.isHidden = true
        }
        authenticatedImage.isHidden = false
        authenticatedStatusLabel.isHidden = false
    }
    
    func logoutClicked(){
        NIMBUS.Devices?.logoutFromDevice()
        restartApp()
    }
    
    func loginClicked(){
        
    }
    
    @objc func restartApp(){
        if NIMBUS.Devices?.appAuthenticated == false {
            NIMBUS.Navigation?.restartApp()
        } else {
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(restartApp), userInfo: nil, repeats: false)
        }
    }
    
}
