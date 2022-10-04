//
//  EmployeeDetailsViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-25.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit
import MaterialComponents

class EmployeeDetailsViewController: UIViewController {
    var authenticatedEmployee: Employee?
    var employeeViewManagerDelegate: EmployeesViewManagerDelegate?
    var hoursViewController: HoursView = HoursView()
    var hoursView: UIView = UIView()
    var employeeInfoDisplayView: UIView = UIView()
    var timePunchViewController: TimePunchViewController = TimePunchViewController()
    var timePunchView: UIView = UIView()
    
    var employeeNameField: SmartTextFieldUpdateView = SmartTextFieldUpdateView()
    var employeePhoneField: SmartTextFieldUpdateView = SmartTextFieldUpdateView()
    var employeeEmailField: SmartTextFieldUpdateView = SmartTextFieldUpdateView()
    
    let labelGaps: CGFloat = 10
    let labelHeight: CGFloat = 40
    
    let topSectionHeight: CGFloat = 160
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        employeeNameField.textField.placeholder = "Name"
        employeePhoneField.textField.placeholder = "Phone"
        employeeEmailField.textField.placeholder = "Email"
        
        employeeNameField.saveButton.addTarget(self, action: #selector(updateEmployeeName), for: .touchUpInside)
        employeePhoneField.saveButton.addTarget(self, action: #selector(updateEmployeePhone), for: .touchUpInside)
        employeeEmailField.saveButton.addTarget(self, action: #selector(updateEmployeeEmail), for: .touchUpInside)
        
        self.employeeInfoDisplayView.addSubview(employeeNameField)
        self.employeeInfoDisplayView.addSubview(employeePhoneField)
        self.employeeInfoDisplayView.addSubview(employeeEmailField)
        self.view.addSubview(employeeInfoDisplayView)
        
        self.employeeNameField.textField.font = MDCTypography.titleFont()
        self.employeePhoneField.textField.font = MDCTypography.body2Font()
        self.employeeEmailField.textField.font = MDCTypography.body2Font()

        self.addChildViewController(hoursViewController)
        hoursViewController.view.frame = self.hoursView.bounds
        self.hoursView.addSubview(hoursViewController.view)
        hoursViewController.didMove(toParentViewController: self)
        self.view.addSubview(hoursView)
        
        self.addChildViewController(timePunchViewController)
        timePunchViewController.view.frame = self.timePunchView.bounds
        self.timePunchView.addSubview(timePunchViewController.view)
        timePunchViewController.didMove(toParentViewController: self)
        self.view.addSubview(timePunchView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        self.employeeInfoDisplayView.frame.origin = .zero
        self.employeeInfoDisplayView.frame.size = CGSize(width: self.view.frame.width/2, height: topSectionHeight)
        
        self.timePunchView.frame.origin = CGPoint(x: self.view.frame.width/2, y: 0)
        self.timePunchView.frame.size = CGSize(width: self.view.frame.width/2, height: topSectionHeight)
        
        let labelWidth: CGFloat = employeeInfoDisplayView.frame.width - 10
        
        self.employeeNameField.frame = CGRect(origin: CGPoint(x: 10, y: 10), size: CGSize(width: labelWidth, height: labelHeight))
        self.employeePhoneField.frame = CGRect(origin: CGPoint(x: 10, y: 10 + labelHeight + labelGaps), size: CGSize(width: labelWidth, height: labelHeight))
        self.employeeEmailField.frame = CGRect(origin: CGPoint(x: 10, y: 10 + (labelHeight + labelGaps)*2), size: CGSize(width: labelWidth, height: labelHeight))
        
        let hoursViewOrigin = CGPoint(x: 10, y: topSectionHeight )
        let hoursViewSize = CGSize(width: self.view.frame.width - 20, height: self.view.frame.height - hoursViewOrigin.y - 20)
        self.hoursView.frame = CGRect(origin: hoursViewOrigin, size: hoursViewSize)
    }
    
    func refreshLabels(){
        employeeNameField.text = authenticatedEmployee?.name
        
        var phoneString = String(describing: authenticatedEmployee?.phone ?? 0)
        phoneString = phoneString.formatPhoneNumber() ?? ""
        employeePhoneField.text = phoneString
        employeeEmailField.text = authenticatedEmployee?.email
    }

    func employeeSelected(employee: Employee){
        self.authenticatedEmployee = employee
        self.hoursViewController.authenticatedEmployee = employee
        self.timePunchViewController.employee = self.authenticatedEmployee
        refreshLabels()
    }
    
    func updateEmployeeName(){
        let name: String = employeeNameField.text ?? ""
        if let employeeId = authenticatedEmployee?.id {
            NIMBUS.Employees?.updateEmployeeName(employeeId: employeeId, name: name)
        }
    }
    
    func updateEmployeePhone(){
        let phoneString: String = employeePhoneField.text ?? ""
        if let employeeId = authenticatedEmployee?.id{
            var phone: Int64
            phone = Int64(Int(phoneString.digitsOnly()) ?? 0)
            NIMBUS.Employees?.updateEmployeePhone(employeeId: employeeId, phone: phone)
        }
    }
    
    func updateEmployeeEmail(){
        let email: String = employeeEmailField.text ?? ""
        if let employeeId = authenticatedEmployee?.id{
            NIMBUS.Employees?.updateEmployeeEmail(employeeId: employeeId, email: email)
        }
    }
}
