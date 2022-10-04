//
//  PageView.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-21.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class PageView: UIView {
    //Left Section
    //1) Header
    //2) Table
    
    //Right Section
    //3) Toolbar
    //4) Detail
    
    var leftSection: LeftSectionView = LeftSectionView()
    var rightSection: RightSectionView = RightSectionView()
    var screenSplitRatio: CGFloat = 0.4
    var screenProportionConstraint: NSLayoutConstraint?
    
    convenience init(frame: CGRect, screenSplitRatio: CGFloat) {
        self.init(frame: frame)
        self.screenSplitRatio = screenSplitRatio
        resizeSplitScreen()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        leftSection = LeftSectionView(frame: CGRect(origin: CGPoint(x: 0, y: 20) , size: CGSize(width: self.frame.width * screenSplitRatio, height: self.frame.height - 20)))
        self.addSubview(leftSection)
        
        rightSection = RightSectionView(frame: CGRect(origin: CGPoint(x: leftSection.frame.width, y: 20), size: CGSize(width: self.frame.width - leftSection.frame.width , height: self.frame.height - 20)))
        self.addSubview(rightSection)
        
        self.bringSubview(toFront: leftSection)
        
        leftSection.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: leftSection, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: leftSection, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: leftSection, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        screenProportionConstraint = NSLayoutConstraint(item: leftSection, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: screenSplitRatio, constant: 0)
        screenProportionConstraint?.isActive = true
        
        rightSection.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: rightSection, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: rightSection, attribute: .leading, relatedBy: .equal, toItem: leftSection, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: rightSection, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: rightSection, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func resizeSplitScreen(){
        screenProportionConstraint?.isActive = false
        screenProportionConstraint? = NSLayoutConstraint(item: leftSection, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: screenSplitRatio, constant: 0)
        screenProportionConstraint?.isActive = true
    }
    
    func addTableViewToLeftSection(tableView: UIView){
        tableView.frame = leftSection.tableView.bounds
        leftSection.tableView.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: leftSection.tableView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableView, attribute: .leading, relatedBy: .equal, toItem: leftSection.tableView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableView, attribute: .trailing, relatedBy: .equal, toItem: leftSection.tableView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: leftSection.tableView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func addDetailViewToRightSection(detailView: UIView){
        removeSubviews(ofView: rightSection.detailView)
        detailView.frame = rightSection.detailView.bounds
        rightSection.detailView.addSubview(detailView)
        
        detailView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: detailView, attribute: .top, relatedBy: .equal, toItem: rightSection.detailView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: detailView, attribute: .leading, relatedBy: .equal, toItem: rightSection.detailView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: detailView, attribute: .trailing, relatedBy: .equal, toItem: rightSection.detailView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: detailView, attribute: .bottom, relatedBy: .equal, toItem: rightSection.detailView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func removeSubviews(ofView view: UIView){
        let allSubviews = view.subviews
        allSubviews.forEach {subview in
            subview.removeFromSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
