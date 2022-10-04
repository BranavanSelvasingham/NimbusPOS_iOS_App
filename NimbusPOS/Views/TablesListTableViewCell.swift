//
//  TablesListTableViewCell.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-04.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit
import MaterialComponents

class TablesListTableViewCell: UITableViewCell {
    var table: Table? {
        didSet {
            refreshLabels()
        }
    }
    
    var section1: UIView = {
        let view = UIView()
        view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var section2: UIView = {
        let view = UIView()
        view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var section3: UIView = {
        let view = UIView()
        view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var tableLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100))
        label.font = MDCTypography.display1Font()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var tableIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_group_work_48pt"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100))
        return imageView
    }()
    
    var tableWaiterLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100))
        label.font = MDCTypography.subheadFont()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var tableOrderDailyNumberLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100))
        label.font = MDCTypography.subheadFont()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        section1.addSubview(tableLabel)
        section1.addSubview(tableIcon)
        section2.addSubview(tableWaiterLabel)
        section3.addSubview(tableOrderDailyNumberLabel)
        
        self.contentView.addSubview(section1)
        self.contentView.addSubview(section2)
        self.contentView.addSubview(section3)
        
        sizeSubviews()
        constrainSubviews()
    }
    
    func sizeSubviews(){
        let baseFrame: CGRect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100))
        
        section1.frame = baseFrame
        section2.frame = baseFrame
        section3.frame = baseFrame
        
        tableWaiterLabel.frame = baseFrame
        tableOrderDailyNumberLabel.frame = baseFrame
    }
    
    func constrainSubviews(){
        let gaps: CGFloat = 10

        NSLayoutConstraint(item: section1, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: section1, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: section1, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: section1, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 0.4, constant: 0).isActive = true

        NSLayoutConstraint(item: section2, attribute: .leading, relatedBy: .equal, toItem: section1, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: section2, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: section2, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: section2, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 0.4, constant: 0).isActive = true
        
        NSLayoutConstraint(item: section3, attribute: .leading, relatedBy: .equal, toItem: section2, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: section3, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: section3, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: section3, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: tableIcon, attribute: .leading, relatedBy: .equal, toItem: section1, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableIcon, attribute: .top, relatedBy: .equal, toItem: section1, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableIcon, attribute: .bottom, relatedBy: .equal, toItem: section1, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableIcon, attribute: .width, relatedBy: .equal, toItem: section1, attribute: .width, multiplier: 0.3, constant: 0).isActive = true
        
        NSLayoutConstraint(item: tableLabel, attribute: .trailing, relatedBy: .equal, toItem: section1, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableLabel, attribute: .top, relatedBy: .equal, toItem: section1, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableLabel, attribute: .bottom, relatedBy: .equal, toItem: section1, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableLabel, attribute: .leading, relatedBy: .equal, toItem: tableIcon, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: tableWaiterLabel, attribute: .leading, relatedBy: .equal, toItem: section2, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableWaiterLabel, attribute: .top, relatedBy: .equal, toItem: section2, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableWaiterLabel, attribute: .bottom, relatedBy: .equal, toItem: section2, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableWaiterLabel, attribute: .trailing, relatedBy: .equal, toItem: section2, attribute: .trailing, multiplier: 1, constant: 0).isActive = true

        NSLayoutConstraint(item: tableOrderDailyNumberLabel, attribute: .leading, relatedBy: .equal, toItem: section3, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableOrderDailyNumberLabel, attribute: .top, relatedBy: .equal, toItem: section3, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableOrderDailyNumberLabel, attribute: .bottom, relatedBy: .equal, toItem: section3, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableOrderDailyNumberLabel, attribute: .trailing, relatedBy: .equal, toItem: section3, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initCell(table: Table){
        self.table = table
    }

    func refreshLabels(){
        tableLabel.text = self.table?.tableLabel
        tableWaiterLabel.text = getTableWaiterName()
        tableOrderDailyNumberLabel.text = getTableOrderDailyNumber()
    }
    
    func getTableWaiterName()->String? {
        return table?.waiterName()
    }
    
    func getTableOrderDailyNumber()-> String {
        var dailyOrderNumbers: String = ""
        let openOrders = table?.getOpenOrders()
        
        openOrders?.forEach({dailyOrderNumbers = dailyOrderNumbers + "  " + $0.formattedDailyOrderNumber()})
        return dailyOrderNumbers
    }
}

