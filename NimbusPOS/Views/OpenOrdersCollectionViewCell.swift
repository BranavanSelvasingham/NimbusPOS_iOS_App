//
//  OpenOrdersCollectionViewCell.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-28.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit
import MaterialComponents

class OpenOrdersCollectionViewCell: UICollectionViewCell {
    var order: Order? {
        didSet {
            //
        }
    }
    
    var receiptView: UIView? {
        didSet{
            //
        }
    }
    
    
    func initCell(order: Order, receiptView: UIView){
        self.order = order
        
        let label = UILabel()
        label.text = "Cell"
        self.addSubview(label)
        
        self.backgroundColor = UIColor.clear
        
        self.addSubview(receiptView)
        
        receiptView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: receiptView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: receiptView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: receiptView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: receiptView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
}
