
//
//  RightSectionView.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-20.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class RightSectionView: UIView {
    let headerView: UIViewWithShadow = UIViewWithShadow()
    let detailView: UIView = UIView()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = MDCTypography.titleFont()
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        return label
    }()
    
    let leftButtonBar = MDCButtonBar()
    var leftButtonBarActionButtons = [UIBarButtonItem](){
        didSet {
            leftButtonBar.items = leftButtonBarActionButtons
            resizeLeftButtonBar()
        }
    }
    let rightButtonBar = MDCButtonBar()
    var rightButtonBarActionButtons = [UIBarButtonItem](){
        didSet {
            rightButtonBar.items = rightButtonBarActionButtons
            resizeRightButtonBar()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        headerView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: self.frame.width, height: 50))
        headerView.shadowLayer.elevation = .switch
        
        headerView.addSubview(leftButtonBar)
        headerView.addSubview(rightButtonBar)
        
        self.addSubview(headerView)
        headerView.addSubview(titleLabel)
        
        detailView.frame = CGRect(origin: CGPoint(x: 0, y: headerView.frame.height), size: CGSize(width: self.frame.width, height: self.frame.height - headerView.frame.height))
        
        self.addSubview(detailView)
        
        self.bringSubview(toFront: headerView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: headerView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        detailView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: detailView, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: detailView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: detailView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: detailView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: headerView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: headerView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func resizeRightButtonBar(){
        let sizeRight = rightButtonBar.sizeThatFits(headerView.frame.size)
        rightButtonBar.frame = CGRect(x: headerView.frame.width - sizeRight.width, y: 0, width: sizeRight.width, height: headerView.frame.height)
    }
    
    func resizeLeftButtonBar(){
        let sizeLeft = leftButtonBar.sizeThatFits(headerView.frame.size)
        leftButtonBar.frame = CGRect(x: 0, y: 0, width: sizeLeft.width, height: headerView.frame.height)
    }
}
