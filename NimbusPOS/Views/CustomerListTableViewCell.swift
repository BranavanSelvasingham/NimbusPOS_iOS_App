//
//  customerListTableViewCell.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-18.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit
import MaterialComponents

class CustomerListTableViewCell: UITableViewCell {
    var customer: Customer?{
        didSet {
            refreshLabels()
        }
    }
    var customerNameField: UILabel = UILabel()
    var customerPhoneField: UILabel = UILabel()
    var customerEmailField: UILabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        customerNameField.font = MDCTypography.titleFont()
        customerEmailField.font = MDCTypography.subheadFont()
        customerPhoneField.font = MDCTypography.subheadFont()
        
        self.contentView.addSubview(customerNameField)
        self.contentView.addSubview(customerEmailField)
        self.contentView.addSubview(customerPhoneField)
        
        sizeSubviews()
    }
    
    func sizeSubviews(){
        let leftMargin: CGFloat = 20
        let labelWidth: CGFloat = self.contentView.frame.width - leftMargin
        
        let line1 = CGRect(origin: CGPoint(x: leftMargin, y: 5), size: CGSize(width: labelWidth, height: 30))
        let line2 = CGRect(origin: CGPoint(x: leftMargin, y: line1.size.height), size: CGSize(width: labelWidth, height: 20))
        let line3 = CGRect(origin: CGPoint(x: leftMargin, y: line1.size.height + line2.size.height), size: CGSize(width: labelWidth, height: 20))
        
        customerNameField.frame = line1
        customerEmailField.frame = line2
        customerPhoneField.frame = line3
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initCell(customer: Customer){
        self.customer = customer
    }
    
    func refreshLabels(){
        customerNameField.text = customer?.name
        var phoneString = String(describing: customer?.phone ?? 0)
        phoneString = phoneString.formatPhoneNumber() ?? ""
        customerPhoneField.text = phoneString
        customerEmailField.text = customer?.email
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
