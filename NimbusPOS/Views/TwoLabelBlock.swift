//
//  TwoLabelBlock.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-11.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

class TwoLabelBlock: UIView{
    var label1: UILabel = UILabel()
    var label2: UILabel = UILabel()
    
    enum _labelBlockSplitByType {
        case label2Width
        case label2Proportion
    }
    
    convenience init(splitBy: _labelBlockSplitByType, label2SplitValue: Int, labelColor: UIColor, labelFont: UIFont) {
        let frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        self.init(frame: frame)
        
        label1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: label1, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: label1, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: label1, attribute: .trailing, relatedBy: .equal, toItem: label2, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: label1, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        label2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: label2, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: label2, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: label2, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        if splitBy == .label2Proportion {
            let label2WidthMultiplier: CGFloat = CGFloat(label2SplitValue/100)
            NSLayoutConstraint(item: label2, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: label2WidthMultiplier, constant: 0).isActive = true
        } else {
            let label2WidthConstant: CGFloat = CGFloat(label2SplitValue)
            NSLayoutConstraint(item: label2, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: label2WidthConstant).isActive = true
        }
        
        label1.font = labelFont
        label1.textAlignment = .left
        label1.textColor = labelColor
        
        label2.font = labelFont
        label2.textAlignment = .right
        label2.textColor = labelColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(label1)
        self.addSubview(label2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     Will hide (nil or 0) or unhide block based on optional amount provided and format as currency with 2 decimal places.
    */
    func setAmountToLabel2(optionalAmount: Float? ){
        if let amount = optionalAmount {
            if amount != 0 {
                self.isHidden = false
                self.label2.text = amount.toString(asMoney: true, toDecimalPlaces: 2)
            } else {
                self.isHidden = true
            }
        } else {
            self.isHidden = true
        }
    }
}
