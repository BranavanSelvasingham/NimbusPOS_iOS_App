//
//  UIImageExtensions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-04.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

extension UIImage {
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
