//
//  orderHistoryListCell.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-12.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

class OrderHistoryListCell: UITableViewCell{
    var order : Order?{
        didSet{
            if let order = order {
                orderNumberLabel.text = order.formattedUniqueOrderNumber()
                dailyOrderNumberLabel.text = order.formattedDailyOrderNumber()
                orderDateLabel.text = order.formattedCreatedDate()
                orderTotalLabel.text = order.paymentAmount.toString(asMoney: true, toDecimalPlaces: 2)
                
                if let customerId = order.customerId {
                    orderCustomer = NIMBUS.Customers?.getCustomerById(id: customerId)
                } else {
                    customerLabel.isHidden = true
                }
                
                if let waiterId = order.waiterId {
                    orderWaiter = NIMBUS.Employees?.getEmployeeById(employeeId: waiterId)
                } else {
                    waiterLabel.isHidden = true
                }
                
                if let tableId = order.tableId {
                    orderTable = NIMBUS.Tables?.getTableById(tableId: tableId)
                } else {
                    tableLabel.isHidden = true
                }
                
                if order.status == _OrderStatus.Cancelled.rawValue {
                    orderCancelled.isHidden = false
                } else {
                    orderCancelled.isHidden = true
                }
            }
        }
    }
    
    var orderCustomer: Customer? = nil {
        didSet {
            if orderCustomer != nil {
                customerLabel.text = "For " + (orderCustomer?.name ?? "??")
                customerLabel.isHidden = false
            } else {
                customerLabel.isHidden = true
            }
        }
    }
    
    var orderWaiter: Employee? = nil {
        didSet {
            if orderWaiter != nil {
                waiterLabel.text = "By " + (orderWaiter?.name ?? "??" )
                waiterLabel.isHidden = false
            } else {
                waiterLabel.isHidden = true
            }
        }
    }
    
    var orderTable: Table? = nil {
        didSet {
            if orderTable != nil {
                tableLabel.text = "Table: " + (orderTable?.tableLabel ?? "??")
                tableLabel.isHidden = false
            } else {
                tableLabel.isHidden = true
            }
        }
    }
    
    var orderNumberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = MDCTypography.subheadFont()
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var dailyOrderNumberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = MDCTypography.subheadFont()
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var orderDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = MDCTypography.subheadFont()
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var orderTotalLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = MDCTypography.titleFont()
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var customerLabel: UILabel = {
        let label = UILabel()
        label.font = MDCTypography.titleFont()
        label.textColor = UIColor.gray
        label.textAlignment = .right
        label.text = "Customer Name"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var tableLabel: UILabel = {
        let label = UILabel()
        label.font = MDCTypography.titleFont()
        label.textColor = UIColor.gray
        label.textAlignment = .right
        label.text = "Table Label"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var waiterLabel: UILabel = {
        let label = UILabel()
        label.font = MDCTypography.titleFont()
        label.textColor = UIColor.gray
        label.textAlignment = .right
        label.text = "Waiter Name"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var orderCancelled: UILabel = {
        let label = UILabel()
        label.text = "CANCELLED"
        label.isHidden = true
        label.font = MDCTypography.subheadFont()
        label.textColor = UIColor.red
        label.transform = CGAffineTransform.identity.rotated(by: CGFloat(-Double.pi/4))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 100).isActive = true
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return label
    }()
    
    let section1: UIView = UIView()
    let section2: UIView = UIView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(section1)
        self.contentView.addSubview(section2)
        
        self.section1.addSubview(orderNumberLabel)
        self.section1.addSubview(dailyOrderNumberLabel)
        self.section1.addSubview(orderDateLabel)
        self.section1.addSubview(orderTotalLabel)
        
        self.contentView.addSubview(orderCancelled)
        
        section1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: section1, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: section1, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: section1, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: section1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50).isActive = true
        NSLayoutConstraint(item: section1, attribute: .bottom, relatedBy: .equal, toItem: section2, attribute: .top, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: orderNumberLabel, attribute: .top, relatedBy: .equal, toItem: self.section1, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderNumberLabel, attribute: .leading, relatedBy: .equal, toItem: self.section1, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderNumberLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 150).isActive = true
        NSLayoutConstraint(item: orderNumberLabel, attribute: .bottom, relatedBy: .equal, toItem: self.section1, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: dailyOrderNumberLabel, attribute: .top, relatedBy: .equal, toItem: self.section1, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: dailyOrderNumberLabel, attribute: .leading, relatedBy: .equal, toItem: orderNumberLabel, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: dailyOrderNumberLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 75).isActive = true
        NSLayoutConstraint(item: dailyOrderNumberLabel, attribute: .bottom, relatedBy: .equal, toItem: self.section1, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: orderDateLabel, attribute: .top, relatedBy: .equal, toItem: self.section1, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderDateLabel, attribute: .leading, relatedBy: .equal, toItem: dailyOrderNumberLabel, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderDateLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200).isActive = true
        NSLayoutConstraint(item: orderDateLabel, attribute: .bottom, relatedBy: .equal, toItem: self.section1, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: orderTotalLabel, attribute: .top, relatedBy: .equal, toItem: self.section1, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderTotalLabel, attribute: .leading, relatedBy: .equal, toItem: orderDateLabel, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderTotalLabel, attribute: .trailing, relatedBy: .equal, toItem: self.section1, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderTotalLabel, attribute: .bottom, relatedBy: .equal, toItem: self.section1, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        self.section2.addSubview(customerLabel)
        self.section2.addSubview(tableLabel)
        self.section2.addSubview(waiterLabel)
        
        section2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: section2, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: section2, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: section2, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50).isActive = true
        NSLayoutConstraint(item: section2, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: customerLabel, attribute: .top, relatedBy: .equal, toItem: self.section2, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: customerLabel, attribute: .leading, relatedBy: .equal, toItem: section2, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: customerLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200).isActive = true
        NSLayoutConstraint(item: customerLabel, attribute: .bottom, relatedBy: .equal, toItem: self.section2, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: tableLabel, attribute: .top, relatedBy: .equal, toItem: self.section2, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableLabel, attribute: .leading, relatedBy: .equal, toItem: customerLabel, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
//        NSLayoutConstraint(item: tableLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100).isActive = true
        NSLayoutConstraint(item: tableLabel, attribute: .bottom, relatedBy: .equal, toItem: self.section2, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: waiterLabel, attribute: .top, relatedBy: .equal, toItem: self.section2, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: waiterLabel, attribute: .leading, relatedBy: .equal, toItem: tableLabel, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: waiterLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200).isActive = true
        NSLayoutConstraint(item: waiterLabel, attribute: .trailing, relatedBy: .equal, toItem: self.section2, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: waiterLabel, attribute: .bottom, relatedBy: .equal, toItem: self.section2, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: orderCancelled, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderCancelled, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initCell(cellOrder: Order){
        self.order = cellOrder
    }
    
}
