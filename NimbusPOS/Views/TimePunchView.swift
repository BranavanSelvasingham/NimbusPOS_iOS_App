//
//  TimePunchView.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-25.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents
import UIKit


class TimePunchViewController: UIViewController{
    var employee: Employee?{
        didSet{
            showAppropriateButton()
        }
    }
    var timeLabel: UILabel = UILabel()
    var checkInButton: MDCButton = MDCButton()
    var checkOutButton: MDCButton = MDCButton()
    var timer = Timer()
    var allDoneLabel: UILabel = UILabel()
    
    override func viewDidLoad() {
        timeLabel.text = DateFormatter.localizedString(from: Date(),
                                                               dateStyle: .none,
                                                               timeStyle: .medium)
        timeLabel.font = MDCTypography.display1Font()
        timeLabel.textColor = UIColor.gray
        timeLabel.textAlignment = .center
        self.view.addSubview(timeLabel)
        
        let timer = Timer.scheduledTimer(timeInterval: 1.0,
                                            target: self,
                                            selector: #selector(tick),
                                            userInfo: nil,
                                            repeats: true)
    
        checkInButton.setTitle("Check-In", for: .normal)
        checkInButton.setBackgroundColor(UIColor(red: 66, green: 185, blue: 244))
        checkInButton.setTitleColor(UIColor.white, for: .normal)
        checkInButton.setElevation(.raisedButtonResting, for: .normal)
        checkInButton.addTarget(self, action: #selector(checkInEmployee), for: .touchUpInside)
        
        checkOutButton.setTitle("Check-Out", for: .normal)
        checkOutButton.setBackgroundColor(UIColor(red: 15, green: 216, blue: 31))
        checkOutButton.setTitleColor(UIColor.white, for: .normal)
        checkOutButton.setElevation(.raisedButtonResting, for: .normal)
        checkOutButton.addTarget(self, action: #selector(checkOutEmployee), for: .touchUpInside)
        
        allDoneLabel.text = "All Done For Today"
        allDoneLabel.font = MDCTypography.body2Font()
        allDoneLabel.textAlignment = .center
        allDoneLabel.textColor = UIColor.gray
        
        showAppropriateButton()
        
        // Add Observer
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object:NIMBUS.EmployeeHours?.managedContext)
    }
    
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
        let entityDescription = EmployeeHours.entity()
        NIMBUS.Data?.parseNotificationManagedObjectContextDidChange(entityDescription: entityDescription, notification: notification, callFunction: self.showAppropriateButton)
    }
    
    func showAppropriateButton(){
        if let employeeId = employee?.id{
            if let todaysHoursEntry = NIMBUS.EmployeeHours?.getEmployeeHourEntryForDate(employeeId: employeeId, date: Date()){
                if todaysHoursEntry.isCheckedIn() == true {
                    if todaysHoursEntry.isCheckedOut() == true {
                        showAllDoneLabel()
                    } else {
                        showCheckOutButton()
                    }
                } else {
                    showCheckInButton()
                }
            } else {
                showCheckInButton()
            }
        }
    }
    
    func showAllDoneLabel(){
        checkOutButton.removeFromSuperview()
        checkInButton.removeFromSuperview()
        self.view.addSubview(allDoneLabel)
    }
    
    func showCheckInButton(){
        checkOutButton.removeFromSuperview()
        self.view.addSubview(checkInButton)
    }
    
    func showCheckOutButton(){
        checkInButton.removeFromSuperview()
        self.view.addSubview(checkOutButton)
    }
    
    func tick(){
        timeLabel.text = DateFormatter.localizedString(from: Date(),
                                                               dateStyle: .none,
                                                               timeStyle: .medium)
    }
    
    func checkInEmployee(){
        if let employeeId = employee?.id {
            NIMBUS.EmployeeHours?.checkInEmployeeForDate(employeeId: employeeId, date: Date())
        }
    }
    
    func checkOutEmployee(){
        if let employeeId = employee?.id {
            NIMBUS.EmployeeHours?.checkOutEmployeeForDate(employeeId: employeeId, date: Date())
        }
    }
    
    override func viewWillLayoutSubviews() {
        timeLabel.frame.origin = CGPoint(x: 0, y: 10)
        timeLabel.frame.size = CGSize(width: self.view.frame.width, height: 50)
        
        let buttonWidth: CGFloat = self.view.frame.width/2
        let buttonHeight: CGFloat = 50
        let buttonOrigin = CGPoint(x: (self.view.frame.width - buttonWidth)/2 , y: timeLabel.frame.origin.y + timeLabel.frame.size.height + 20)
        let buttonSize = CGSize(width: buttonWidth, height: buttonHeight)
        
        checkInButton.frame = CGRect(origin: buttonOrigin, size: buttonSize)
        checkOutButton.frame = CGRect(origin: buttonOrigin, size: buttonSize)
        allDoneLabel.frame = CGRect(origin: buttonOrigin, size: buttonSize)
    }
}
