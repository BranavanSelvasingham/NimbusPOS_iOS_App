//
//  mainHomeButton.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-17.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import MaterialComponents

class mainHomeButton: MDCFloatingButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func awakeFromNib() {
        self.setTitle("", for: .normal)
        self.setTitleColor(UIColor.white, for: .normal)
        let nimbusLogo = UIImage(named:"ic_menu_white")
        self.setImage(nimbusLogo, for: .normal)
        self.setElevation(.cardPickedUp , for: .normal)
        self.sizeToFit()
    }
    
}
