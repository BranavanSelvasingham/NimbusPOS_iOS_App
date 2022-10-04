//
//  LeftSectionView.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-19.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class LeftSectionView: UIViewWithShadow {
    let headerView: UIViewWithShadow = UIViewWithShadow()
    let titleLabelMain = UILabel()
    let tableView = UIView()
    let buttonBar = MDCButtonBar()
    var buttonBarActionButtons = [UIBarButtonItem](){
        didSet {
            buttonBar.items = buttonBarActionButtons
            let size = buttonBar.sizeThatFits(self.bounds.size)
            buttonBar.frame = CGRect(x: headerView.frame.width - size.width, y: 0, width: size.width, height: headerView.frame.height)
        }
    }
    let titleLabelRightView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setDefaultElevation()
        
        headerView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: self.frame.width, height: 50))

        titleLabelMain.frame.size = CGSize(width: headerView.frame.width * 0.6, height: headerView.frame.height)
        titleLabelMain.frame.origin = CGPoint(x: headerView.frame.width/2 - titleLabelMain.frame.width/2 , y: 0)
        titleLabelMain.font = MDCTypography.headlineFont()
        titleLabelMain.textColor = UIColor.darkGray
        titleLabelMain.textAlignment = .center
        
        headerView.shadowLayer.elevation = .switch
        
        headerView.addSubview(titleLabelMain)
        headerView.addSubview(titleLabelRightView)
        headerView.addSubview(buttonBar)
        
        self.addSubview(headerView)
        
        tableView.frame = CGRect(origin: CGPoint(x: 0, y: headerView.frame.height), size: CGSize(width: self.frame.width, height: self.frame.height - headerView.frame.height))
        
        self.addSubview(tableView)
        self.bringSubview(toFront: headerView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: headerView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        titleLabelMain.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: titleLabelMain, attribute: .centerX, relatedBy: .equal, toItem: headerView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: titleLabelMain, attribute: .centerY, relatedBy: .equal, toItem: headerView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: titleLabelRightView, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: titleLabelRightView, attribute: .trailing, relatedBy: .equal, toItem: headerView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: titleLabelRightView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 130).isActive = true
        NSLayoutConstraint(item: titleLabelRightView, attribute: .bottom, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
    }
    
    func addButtonClicked(){
        
    }
    
    func setHeaderTitle(title: String){
        self.titleLabelMain.text = title
    }
    
    func setRightTitleNote(sideView: UIView){
        self.titleLabelRightView.isHidden = false
        self.titleLabelRightView.addSubview(sideView)

        sideView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: sideView, attribute: .top, relatedBy: .equal, toItem: titleLabelRightView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: sideView, attribute: .leading, relatedBy: .equal, toItem: titleLabelRightView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: sideView, attribute: .trailing, relatedBy: .equal, toItem: titleLabelRightView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: sideView, attribute: .bottom, relatedBy: .equal, toItem: titleLabelRightView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
