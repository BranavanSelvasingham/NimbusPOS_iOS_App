//
//  loginView.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-17.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MaterialComponents

class LoginView: UIViewController, loginViewBoxDelegate {
    @IBOutlet weak var logo_y: NSLayoutConstraint!
    
    var loginView: loginViewBox?
    let loginViewWidth:CGFloat = 300
    let loginViewHeight:CGFloat = 300
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        NIMBUS.Devices?.prepareDeviceForLogin()

        loginView = loginViewBox(frame: CGRect(x: self.view.frame.width/2 - (300/2), y: self.view.frame.height, width: loginViewWidth, height: loginViewHeight))
        loginView?.loginDelegate = self
        
        let cloudWallpaper = nimbusCloudWallpaper(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/2))
        
        self.view.addSubview(loginView!)
        self.view.addSubview(cloudWallpaper)
        self.view.bringSubview(toFront: loginView!)
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        let keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        self.loginView?.frame = CGRect(x: self.view.frame.width/2 - (300/2), y: self.view.frame.height - self.loginViewHeight - keyboardSize.height, width: self.loginViewWidth, height: self.loginViewHeight)
    }
    
    @objc func keyboardDidHide(notification: NSNotification) {
        let keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        self.loginView?.frame = CGRect(x: self.view.frame.width/2 - (300/2), y: self.view.frame.height - self.loginViewHeight - 50, width: self.loginViewWidth, height: self.loginViewHeight)
    }
    
    func enterApp (){
        performSegue(withIdentifier: "segueID_LoginToDataLoading", sender: nil)
    }
    
    func enterLoginBox(){
        let animatorLoginView = UIViewPropertyAnimator(duration: 0.5, curve: .linear , animations: {
            self.loginView?.frame = CGRect(x: self.view.frame.width/2 - (300/2), y: self.view.frame.height - self.loginViewHeight - 50, width: self.loginViewWidth, height: self.loginViewHeight)
        })
        animatorLoginView.addCompletion({ (position) in
            //
        })
        
        let animatorLogo = UIViewPropertyAnimator(duration: 0.5, curve: .linear , animations: {
            self.logo_y.constant = self.logo_y.constant - 100
        })
        animatorLogo.addCompletion({ (position) in
            animatorLoginView.startAnimation()
        })
        animatorLogo.startAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if NIMBUS.Devices?.appAuthenticated == true {
            enterApp()
        } else {
            enterLoginBox()
        }
    }
    
    func loginAttemptStarted() {
        
    }
    
    func loginCompleted(loginSuccessful: Bool, message: String) {
        let snackBarMessage = MDCSnackbarMessage()
        snackBarMessage.text = message
        MDCSnackbarManager.show(snackBarMessage)
    }
    
    func appAuthentication(isAuthenticated: Bool, message: String) {
        if isAuthenticated == true {
            DispatchQueue.main.sync {
                NIMBUS.Devices?.registerDevice()
                enterApp()
            }
        } else {
            let snackBarMessage = MDCSnackbarMessage()
            snackBarMessage.text = message
            MDCSnackbarManager.show(snackBarMessage)
        }
    }
}
