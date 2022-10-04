//
//  DataLoadingView.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-17.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MaterialComponents

class DataLoadingView: UIViewController, locationSelectorProtocol, DataLoadingDelegate {
    var locationSelectorController: LocationSelectorTableViewController?
    var activityIndicator: DataLoadingBar?
    
    let businessDisplayView: BusinessNameTile = {
        let businessDisplayViewFrame: CGRect = CGRect(x: 10, y: 10, width: 200, height: 50)
        let businessDisplayView = BusinessNameTile(frame: businessDisplayViewFrame, blockSize: .large)
        businessDisplayView.translatesAutoresizingMaskIntoConstraints = false
        businessDisplayView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return businessDisplayView
    }()
    
    let locationDisplayView: LocationNameTile = {
        let locationDisplayViewFrame: CGRect = CGRect(x: 10, y: 10, width: 200, height: 50)
        let locationDisplayView = LocationNameTile(frame: locationDisplayViewFrame, blockSize: .large)
        locationDisplayView.translatesAutoresizingMaskIntoConstraints = false
        locationDisplayView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return locationDisplayView
    }()
    
    let skipSyncOptionView: YesNoOptionView = {
        let labelText = "Refresh all local data with cloud data?"
        let yesButtonText = "Continue"
        let noButtonText = "Skip"
        let view = YesNoOptionView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 300, height: 200)), fontColor: UIColor.white, labelText: labelText, yesButtonText: yesButtonText, noButtonText: noButtonText)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.yesButton.addTarget(self, action: #selector(continueWithDataSync), for: .touchUpInside)
        view.noButton.addTarget(self, action: #selector(skipDataSync), for: .touchUpInside)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loadingIndicatorDim: CGFloat = 300
        let loadingIndicatorOrigin: CGPoint = CGPoint(x: self.view.frame.width/2 - loadingIndicatorDim/2, y: self.view.frame.height/2 - loadingIndicatorDim/2)
        activityIndicator = DataLoadingBar(frame: CGRect(origin: loadingIndicatorOrigin, size: CGSize(width: loadingIndicatorDim, height: loadingIndicatorDim)))
        activityIndicator?.isHidden = true
        
        self.view.addSubview(activityIndicator!)
        self.view.addSubview(businessDisplayView)
        self.view.addSubview(locationDisplayView)
        self.view.addSubview(skipSyncOptionView)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(notificationForResultsFromDocumentIdListCall(notification:)), name: Notification.Name.onResultsFromDocumentIdListCall, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        NSLayoutConstraint(item: businessDisplayView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 100).isActive = true
        NSLayoutConstraint(item: businessDisplayView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: locationDisplayView, attribute: .top, relatedBy: .equal, toItem: businessDisplayView, attribute: .bottom, multiplier: 1, constant: 60).isActive = true
        NSLayoutConstraint(item: locationDisplayView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: skipSyncOptionView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: skipSyncOptionView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        activityIndicator?.startAndShowProgressView()
        
        let dataLoadedBefore = NIMBUS.Data?.dataLoadedBefore
        if dataLoadedBefore == true {
            skipSyncOptionView.isHidden = false
        } else {
            activityIndicator?.isHidden = false
            checkForDeviceLocation()
        }
    }
    
    func notificationForResultsFromDocumentIdListCall(notification: NSNotification){
        DispatchQueue.main.async {
            let progress = notification.object as! notificationDocumentListSyncObject
            self.activityIndicator?.statusText = "\(progress.message) \(progress.currentDocumentProgress) / \(progress.totalDocuments)"
            
            let totalDocuments: Int = progress.totalDocuments
            
            if totalDocuments <= 0 {
                self.activityIndicator?.progress = Float(1)
            } else {
                self.activityIndicator?.progress = Float(progress.currentDocumentProgress)/Float(progress.totalDocuments)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToLocationSelector" {
            locationSelectorController = segue.destination as! LocationSelectorTableViewController
            locationSelectorController?.locationSelectorDelegate = self
        }
    }
    
    func locationSelected(location: Location) {
        NIMBUS.Location?.setLocation(selectedLocation: location)
        locationSelectorController?.dismiss(animated: true, completion: checkForDeviceLocation)
    }
    
    func continueWithDataSync(){
        skipSyncOptionView.isHidden = true
        activityIndicator?.isHidden = false
        
        NIMBUS.Data?.periodicSyncStatus = .Stopped
        checkForDeviceLocation()
    }
    
    func skipDataSync(){
        NIMBUS.Devices?.startNonFirstRunSyncProcess()
        goToMain()
    }
    
    func checkForDeviceLocation(){
        if NIMBUS.Location?.isDeviceLocationSelected() == true {
            NIMBUS.Devices?.getDeviceReadyForUse(delegate: self)
        } else {
            NIMBUS.Devices?.getCoreInfo(delegate: self)
            performSegue(withIdentifier: "segueToLocationSelector", sender: nil)
        }
    }

    func dataLoadingCompleted() {
        NIMBUS.Devices?.startFirstRunSyncProcess()
        goToMain()
    }
    
    func coreServerDataLoaded() {
        
    }
    
    func goToMain(){
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "segueID_masterNavigation", sender: nil)
        }
    }
}
