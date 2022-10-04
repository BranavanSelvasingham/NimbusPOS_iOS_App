//
//  SeatSelectCollectionViewCell.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-10.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit
import MaterialComponents

class SeatSelectCollectionViewCell: UICollectionViewCell {
    var seatNumber: Int? {
        didSet{
            refreshSeat()
        }
    }
    
    var seatNumberLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        seatNumberLabel.textColor = UIColor.white
        seatNumberLabel.font = MDCTypography.subheadFont()
        seatNumberLabel.textAlignment = .center
        
        self.layer.cornerRadius = 20
        self.backgroundColor = UIColor.lightGray
        self.addSubview(seatNumberLabel)
        
        seatNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: seatNumberLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: seatNumberLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: seatNumberLabel, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: seatNumberLabel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initCell(seatNumber: Int){
        self.seatNumber = seatNumber
    }
    
    func refreshSeat(){
        seatNumberLabel.text = "Seat " + (seatNumber?.toString() ?? "")
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected == true {
                self.backgroundColor = UIColor.blue
            } else {
                self.backgroundColor = UIColor.gray
            }
        }
    }
}
