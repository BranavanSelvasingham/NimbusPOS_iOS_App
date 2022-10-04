//
//  nimbusStyleFunctions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-11.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit


class nimbusStyleFunctions: NimbusBase {
    let nimbusBlue = UIColor.color(fromHexString: "4fc3f7")
    
    override init(master: NimbusFramework?){
        super.init(master: master)
    }
    
    func initializeUnselectedCategoryTileStruct() -> tileStylePropertyStruct{
        var unselected = tileStylePropertyStruct()
        unselected.cornerRadius = 20
        unselected.shadowColor = UIColor.color(fromHexString: "a6a6a6")
        unselected.shadowOpacity = 0
        unselected.shadowOffset = CGSize.zero
        unselected.shadowRadius = 0
        unselected.shadowScale = true
        return unselected
    }
    
    func initializeSelectedCategoryTileStruct() -> tileStylePropertyStruct{
        var selected = tileStylePropertyStruct()
        selected.shadowColor = UIColor.color(fromHexString: "80ffff")
        selected.shadowOpacity = 1
        selected.shadowOffset = CGSize(width: -2, height: 2)
        selected.shadowRadius = 3
        selected.shadowScale = true
        return selected
    }
    
    func initializeUnselectedProductTileStruct() -> tileStylePropertyStruct{
        var unselected = tileStylePropertyStruct()
        unselected.cornerRadius = 3
        unselected.shadowColor = UIColor.color(fromHexString: "a6a6a6")
        unselected.shadowOpacity = 1
        unselected.shadowOffset = CGSize.zero
        unselected.shadowRadius = 3
        unselected.shadowScale = true
        return unselected
    }
    
    func dropShadow(tile: UICollectionViewCell, color: UIColor = UIColor.black, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        tile.layer.masksToBounds = false
        tile.layer.shadowColor = color.cgColor
        tile.layer.shadowOpacity = opacity
        tile.layer.shadowOffset = offSet
        tile.layer.shadowRadius = radius
    }
    
}
