//
//  HourEntryViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-26.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class HourEntryViewController: UIViewController {
    var employee: Employee?
    var hoursViewDelegate: HoursViewDelegate?
    var hourEntryDate: UIDatePicker = UIDatePicker()
    var hourEntryClockIn: UIDatePicker = UIDatePicker()
    var hourEntryClockOut: UIDatePicker = UIDatePicker()
    var toLabel: UILabel = UILabel()
    
    override func viewDidLoad() {
        hourEntryDate.datePickerMode = .date
        hourEntryDate.maximumDate = Date()
        
        hourEntryClockIn.datePickerMode = .time
        hourEntryClockIn.minimumDate = Date().startOfDay
        
        hourEntryClockOut.datePickerMode = .time
        hourEntryClockOut.maximumDate = Date().endOfDay
        
        toLabel.text = "To"
        toLabel.font = MDCTypography.body2Font()
        toLabel.textColor = UIColor.gray
        toLabel.textAlignment = .center
        
        self.view.addSubview(hourEntryDate)
        self.view.addSubview(hourEntryClockIn)
        self.view.addSubview(toLabel)
        self.view.addSubview(hourEntryClockOut)
    }
    
    override func viewWillLayoutSubviews() {
        let hourEntryWidth: CGFloat = self.view.frame.width
        let hourEntryHeight: CGFloat = 50
        let gap: CGFloat = 20
        
        hourEntryDate.frame = CGRect(origin: CGPoint(x: (self.view.frame.width - hourEntryWidth)/2, y: gap), size: CGSize(width: hourEntryWidth, height: hourEntryHeight))
        
        hourEntryClockIn.frame = CGRect(origin: CGPoint(x: (self.view.frame.width - hourEntryWidth)/2, y: hourEntryDate.frame.origin.y + hourEntryDate.frame.height + gap), size: CGSize(width: hourEntryWidth, height: hourEntryHeight))
        
        toLabel.frame = CGRect(origin: CGPoint(x: (self.view.frame.width - hourEntryWidth)/2, y: hourEntryClockIn.frame.origin.y + hourEntryClockIn.frame.height), size: CGSize(width: hourEntryWidth, height: gap))
        
        hourEntryClockOut.frame = CGRect(origin: CGPoint(x: (self.view.frame.width - hourEntryWidth)/2, y: toLabel.frame.origin.y + toLabel.frame.height), size: CGSize(width: hourEntryWidth, height: hourEntryHeight))
    }
    
    func saveHourEntry() -> Void{
        var entryDate: Date = hourEntryDate.date
        var checkInTime: Date = hourEntryClockIn.date
        var checkOutTime: Date = hourEntryClockOut.date

        entryDate = entryDate.startOfDay
        
        let calendar = Calendar.current
        var dateComponents: DateComponents
        
        dateComponents = calendar.dateComponents([.hour, .minute, .second], from: checkInTime)
        dateComponents.year = entryDate.year
        dateComponents.month = entryDate.month
        dateComponents.day = entryDate.day
        
        checkInTime = calendar.date(from: dateComponents)!
        
        dateComponents = calendar.dateComponents([.hour, .minute, .second], from: checkOutTime)
        dateComponents.year = entryDate.year
        dateComponents.month = entryDate.month
        dateComponents.day = entryDate.day
        
        checkOutTime = calendar.date(from: dateComponents)!
        
        //error check
        if checkInTime > checkOutTime {
            return
        }
        
        if let employeeId = employee?.id {
            let success = NIMBUS.EmployeeHours?.createNewEmployeeHourEntry(entryDate: entryDate, checkIn: checkInTime, checkOut: checkOutTime, employeeId: employeeId)
        }
        
        hoursViewDelegate?.dismissNewHourEntryModal()
    }
    
    func cancelHourEntry(){
        
    }
}
