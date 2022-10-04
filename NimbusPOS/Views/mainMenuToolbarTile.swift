//
//  mainMenuToolbarTile.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-18.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class MainMenuToolbarTile: UIButton {
    var title: String?
    var tileSize: CGSize = CGSize.zero
    let innerMargins: CGFloat = 5
    var iconLabel: UILabel = UILabel()
    var iconImage: UIImage?
    
    init(title: String, iconName: String, tileSize: CGSize = CGSize(width: 100, height: 30)) {
        super.init(frame: .zero)
        
        self.title = title
        self.frame.size = tileSize
        self.tileSize = tileSize
        iconLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.frame.height, height: self.frame.height)))
        iconImage = UIImage(named: iconName)
        
        let iconLabelText = NSMutableAttributedString(string: "")
        
        let iconAttach = NSTextAttachment()
        iconAttach.image = iconImage
        let iconsSize = CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height)
        iconAttach.bounds = iconsSize
        
        iconLabelText.append(NSAttributedString(attachment: iconAttach))
        iconLabel.attributedText = iconLabelText
        
        iconLabel.textColor = UIColor.white
        iconLabel.textAlignment = .center
        self.addSubview(iconLabel)
        
        let titleLabel = UILabel(frame: CGRect(origin: CGPoint(x: self.frame.height, y: 0), size: CGSize(width: self.frame.width - self.frame.height, height: self.frame.height)))
        titleLabel.font = MDCTypography.body1Font()
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        self.addSubview(titleLabel)
        
        self.backgroundColor = UIColor.lightGray
        self.setDefaultElevation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override class var layerClass: AnyClass {
        return MDCShadowLayer.self
    }
    
    var shadowLayer: MDCShadowLayer {
        return self.layer as! MDCShadowLayer
    }
    
    var elevation: ShadowElevation {
        get {
            return self.shadowLayer.elevation
        }
        set {
            self.shadowLayer.elevation = newValue
        }
    }
    
    func setDefaultElevation() {
        self.shadowLayer.elevation = .cardResting
    }
    
}
