//
//  mainMenuTile.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-17.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class MainMenuTile: UIButton {
    var title: String?
    var tileSize: CGSize = CGSize.zero
    let innerMargins: CGFloat = 5
    
    init(title: String, iconName: String, tileSize: CGSize = CGSize(width: 200, height: 200)) {
        super.init(frame: .zero)
        
        self.title = title
        self.frame.size = tileSize
        self.tileSize = tileSize
        let titleLabel = UILabel(frame: CGRect(origin: CGPoint(x: innerMargins, y: 25), size: CGSize(width: self.frame.width - innerMargins * 2, height: 50)))
        titleLabel.font = MDCTypography.titleFont()
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        self.addSubview(titleLabel)

        let iconLabel = UILabel(frame: CGRect(origin: CGPoint(x: innerMargins, y: 25 + titleLabel.frame.height), size: CGSize(width: self.frame.width - innerMargins * 2, height: 100)))
        let iconImage = UIImage(named: iconName)

        let iconLabelText = NSMutableAttributedString(string: "")

        let iconAttach = NSTextAttachment()
        iconAttach.image = iconImage
        let iconsSize = CGRect(x: 0, y: 0, width: 90, height: 90)
        iconAttach.bounds = iconsSize

        iconLabelText.append(NSAttributedString(attachment: iconAttach))
        iconLabel.attributedText = iconLabelText

        iconLabel.textColor = UIColor.white
        iconLabel.textAlignment = .center
        self.addSubview(iconLabel)
        
        self.backgroundColor = UIColor().nimbusBlue
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
