//
//  LocaitonSelectorTableViewCell.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-26.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit

class LocationSelectorTableViewCell: UITableViewCell {
    var location: Location? {
        didSet {
            var locationLabel: UILabel?
            var locationIcon: UIImage? = UIImage(named: "ic_location_on")
            
            let locationLabelText = NSMutableAttributedString(string: "")
            let locationIconAttach = NSTextAttachment()
            locationIconAttach.image = locationIcon
            
            let iconsSize = CGRect(x: 0, y: -5, width: 30, height: 30)
            locationIconAttach.bounds = iconsSize
            
            locationLabelText.append(NSAttributedString(attachment: locationIconAttach))
            locationLabelText.append(NSAttributedString(string: "  "))
            locationLabelText.append(NSAttributedString(string: location?.name ?? "?"))
            locationNameLabel?.attributedText = locationLabelText
            
            if let deviceLocationId = NIMBUS.Location?.getLocationId() {
                if deviceLocationId == location?.id {
                    self.isUserInteractionEnabled = false
                    self.backgroundColor = UIColor.lightGray
                } else {
                    self.isUserInteractionEnabled = true
                    self.backgroundColor = UIColor.white
                }
            } else {
                self.isUserInteractionEnabled = true
                self.backgroundColor = UIColor.white
            }
        }
    }
    
    @IBOutlet weak var locationNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }

    func initCell(location: Location) {
        self.location = location
    }
}
