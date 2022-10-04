//
//  HoursTableViewCell.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-26.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit
import MaterialComponents

class HoursTableViewCell: UITableViewCell {
    var hourEntry: EmployeeHours? {
        didSet {
            refreshLabels()
        }
    }
    
    var hourEntryDateField: UILabel = UILabel()
    var hourEntryInTimeField: UILabel = UILabel()
    var hourEntryOutTimeField: UILabel = UILabel()
    var buttonBarView: UIView = UIView()
    var buttonBar: MDCButtonBar = MDCButtonBar()
    
//    var editButton: UIBarButtonItem = UIBarButtonItem()
    var deleteButton: UIBarButtonItem = UIBarButtonItem()
    
    override var isSelected: Bool {
        didSet{
            
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if isSelected == true {
//            editButton.isEnabled = true
            deleteButton.isEnabled = true
        } else {
//            editButton.isEnabled = false
            deleteButton.isEnabled = false
        }
    }
    
    override var frame: CGRect {
        didSet{
            sizeLabels()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initCell(hourEntry: EmployeeHours){
        self.hourEntry = hourEntry
        
        hourEntryDateField.font = MDCTypography.body2Font()
        hourEntryInTimeField.font = MDCTypography.body2Font()
        hourEntryOutTimeField.font = MDCTypography.body2Font()
        
        self.contentView.addSubview(hourEntryDateField)
        self.contentView.addSubview(hourEntryInTimeField)
        self.contentView.addSubview(hourEntryOutTimeField)
        
//        editButton = UIBarButtonItem(image: UIImage(named: "ic_edit"), style: .plain, target: self, action: #selector(editHourEntry))
        deleteButton = UIBarButtonItem(image: UIImage(named: "ic_delete"), style: .plain, target: self, action: #selector(deleteNewHourEntry))
        
//        editButton.isEnabled = false
        deleteButton.isEnabled = false
        
        buttonBar.items = [deleteButton]
        buttonBarView.addSubview(buttonBar)
        self.contentView.addSubview(buttonBarView)
    }
    
//    func editHourEntry(){
//
//    }
    
    func deleteNewHourEntry(){
        if let hourEntry = hourEntry {
            NIMBUS.EmployeeHours?.deleteEmployeeHourEntry(employeeHourEntry: hourEntry)
        }
    }
    
    func sizeLabels(){
        let frame1 = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.contentView.frame.width/4, height: self.contentView.frame.height))
        let frame2 = CGRect(origin: CGPoint(x: hourEntryDateField.frame.width, y: 0), size: CGSize(width: self.contentView.frame.width/4, height: self.contentView.frame.height))
        let frame3 = CGRect(origin: CGPoint(x: hourEntryDateField.frame.width * 2, y: 0), size: CGSize(width: self.contentView.frame.width/4, height: self.contentView.frame.height))
        let frame4 = CGRect(origin: CGPoint(x: hourEntryDateField.frame.width * 3, y: 0), size: CGSize(width: self.contentView.frame.width/4, height: self.contentView.frame.height))
        
        hourEntryDateField.frame = frame1
        hourEntryInTimeField.frame = frame2
        hourEntryOutTimeField.frame = frame3
        
        buttonBarView.frame = frame4
        
        let size = buttonBar.sizeThatFits(frame4.size)
        buttonBar.frame = CGRect(x: frame4.width - size.width, y: 0, width: size.width, height: frame4.height)
    }
    
    func refreshLabels(){
        hourEntryDateField.text = hourEntry?.date?.toDateStringWithoutTime(dateStyle: .medium)
        hourEntryInTimeField.text = hourEntry?.actualClockIn?.toTimeStringOnly(timeStyle: .medium)
        hourEntryOutTimeField.text = hourEntry?.actualClockOut?.toTimeStringOnly(timeStyle: .medium)
    }
    
    
}
