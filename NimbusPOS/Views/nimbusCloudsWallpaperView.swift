//
//  nimbusCloudsWallpaperView.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-16.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit

class nimbusCloudWallpaper: UIView {

    let cloudView1 = UIImageView(image: UIImage(named: "NimbusPOS_cloud"))
    let cloudView2 = UIImageView(image: UIImage(named: "NimbusPOS_cloud"))
    let cloudView3 = UIImageView(image: UIImage(named: "NimbusPOS_cloud"))
    let cloudView4 = UIImageView(image: UIImage(named: "NimbusPOS_cloud"))
    let cloudView5 = UIImageView(image: UIImage(named: "NimbusPOS_cloud"))
    let cloudView6 = UIImageView(image: UIImage(named: "NimbusPOS_cloud"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cloudView1.contentMode = UIViewContentMode.scaleAspectFit
        cloudView1.alpha = 0.0
        cloudView1.frame = CGRect(origin: CGPoint(x: -50, y: -30), size: getCloudSize(scale: 1))
        self.addSubview(cloudView1)
        
        cloudView2.contentMode = UIViewContentMode.scaleAspectFit
        cloudView2.alpha = 0.0
        cloudView2.frame = CGRect(origin: CGPoint(x: 300, y: -100), size: getCloudSize(scale: 1.2))
        self.addSubview(cloudView2)
        
        cloudView3.contentMode = UIViewContentMode.scaleAspectFit
        cloudView3.alpha = 0.0
        cloudView3.frame = CGRect(origin: CGPoint(x: 700, y: 20), size: getCloudSize(scale: 0.7))
        self.addSubview(cloudView3)
        
        cloudView4.contentMode = UIViewContentMode.scaleAspectFit
        cloudView4.alpha = 0.0
        cloudView4.frame = CGRect(origin: CGPoint(x: 200, y: 200), size: getCloudSize(scale: 0.3))
        self.addSubview(cloudView4)
        
        cloudView5.contentMode = UIViewContentMode.scaleAspectFit
        cloudView5.alpha = 0.0
        cloudView5.frame = CGRect(origin: CGPoint(x: 600, y: 180), size: getCloudSize(scale: 0.5))
        self.addSubview(cloudView5)
        
        cloudView6.contentMode = UIViewContentMode.scaleAspectFit
        cloudView6.alpha = 0.0
        cloudView6.frame = CGRect(origin: CGPoint(x: self.frame.width - 100, y: 160), size: getCloudSize(scale: 0.9))
        self.addSubview(cloudView6)
        
        animateCloudsForward()
        transitionInClouds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func transitionInClouds(){
        let animator = UIViewPropertyAnimator(duration: 1 , curve: .linear , animations: {
            self.cloudView1.alpha = 0.8
            self.cloudView2.alpha = 0.8
            self.cloudView3.alpha = 0.7
            self.cloudView4.alpha = 0.6
            self.cloudView5.alpha = 0.7
            self.cloudView6.alpha = 0.8
        })
        animator.addCompletion({ (position) in

        })
        animator.startAnimation()
    }
    
    func getCloudSize(scale: CGFloat) -> CGSize{
        let standardDim: CGFloat = 200
        let scaledDim: CGFloat = scale * standardDim
        return CGSize(width: scaledDim, height: scaledDim)
    }
    
    func animateCloudsForward(){
        let animator = UIViewPropertyAnimator(duration: 200, curve: .linear , animations: {
            self.cloudView1.frame.origin.x += 900
            self.cloudView2.frame.origin.x += 1000
            self.cloudView3.frame.origin.x += 700
            self.cloudView4.frame.origin.x += 400
            self.cloudView5.frame.origin.x += 500
            self.cloudView6.frame.origin.x += 900
        })
        animator.addCompletion({ (position) in
            self.cloudView1.frame.origin.x = -50
            self.cloudView2.frame.origin.x = 300
            self.cloudView3.frame.origin.x = 700
            self.cloudView4.frame.origin.x = 200
            self.cloudView5.frame.origin.x = 500
            self.cloudView6.frame.origin.x = self.frame.width - 100
            
            self.animateCloudsForward()
        })
        animator.startAnimation()
    }
}
