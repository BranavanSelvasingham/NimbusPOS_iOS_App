//
//  dataLoadingSpinner.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-17.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

class DataLoadingBar: UIView {
    let progressView = MDCProgressView()
    var loadingLabel: UILabel = UILabel()
    
    var statusText: String {
        get {
            return loadingLabel.text ?? ""
        }
        set {
            loadingLabel.text = newValue
        }
    }
    
    var progress: Float {
        get {
            return progressView.progress
        }
        set {
            progressView.progress = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.frame = frame

        let labelHeight: CGFloat = 30
        loadingLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: self.frame.height/2 - labelHeight/2), size: CGSize(width: self.frame.width, height: labelHeight)))
        loadingLabel.text = "Loading data..."
        loadingLabel.textColor = UIColor.white
        loadingLabel.textAlignment = .center
        loadingLabel.font = MDCTypography.body2Font()
        
        self.addSubview(loadingLabel)
        
        progressView.progress = 0
        let progressViewHeight = CGFloat(5)
        progressView.frame = CGRect(x: 0, y: loadingLabel.frame.maxY + 20, width: self.bounds.width, height: progressViewHeight)
        self.addSubview(progressView)
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func startAndShowProgressView() {
        progressView.progress = 0
        progressView.setHidden(false, animated: true)
    }
    
    func completeAndHideProgressView() {
        progressView.setProgress(1, animated: true) { (finished) in
            self.progressView.setHidden(true, animated: true)
        }
    }
}
