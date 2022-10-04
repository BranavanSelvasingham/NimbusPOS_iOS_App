//
//  Help.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-22.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents
import MessageUI

class HelpPage: UIViewController, MFMailComposeViewControllerDelegate {
    let helpText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = MDCTypography.subheadFont()
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "If you have any questions, we would be happy to help you on a 1-on-1 basis. Just send us a simple message with a call-back number and we will be in touch as soon as we get it."
        return label
    }()
    
    let emailButton: MDCRaisedButton = {
        let button = MDCRaisedButton()
        button.setTitle("info@nimbuspos.com", for: .normal)
        button.setTitleFont(MDCTypography.titleFont(), for: .normal)
        button.backgroundColor = UIColor.white
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.isUppercaseTitle = false
        button.addTarget(self, action: #selector(sendHelpMail), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(helpText)
        self.view.addSubview(emailButton)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        NSLayoutConstraint(item: helpText, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: helpText, attribute: .bottom, relatedBy: .equal, toItem: emailButton, attribute: .top, multiplier: 1, constant: -100).isActive = true
        NSLayoutConstraint(item: helpText, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.75, constant: 0).isActive = true
        
        NSLayoutConstraint(item: emailButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: emailButton, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
    }
    
    func sendHelpMail(){
        let emailTitle = "Help: "
        let messageBody = "Urgent? (yes/no): \n\n\nHelp needed with... \n\n\nCall-back phone #: "
        let toRecipents = ["info@nimbuspos.com"]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        
        self.present(mc, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
