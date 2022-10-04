//
//  LocationSettings.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-22.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class LocationSettings: UIViewController, locationSelectorProtocol {
    let locationName: UILabel = {
        let label = UILabel()
        label.font = MDCTypography.display1Font()
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NIMBUS.Location?.getLocationName()
        return label
    }()
    
    let locationAddress: UILabel = {
        let label = UILabel()
        label.font = MDCTypography.subheadFont()
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        let address = NIMBUS.Location?.getLocationAddress()
        label.text = address?.street
        return label
    }()
    
    
    let changeLocation: MDCRaisedButton = {
        let button = MDCRaisedButton()
        button.setTitle("Change Location", for: .normal)
        button.setTitleFont(MDCTypography.titleFont(), for: .normal)
        button.backgroundColor = UIColor().nimbusBlue
        button.setTitleColor(UIColor.white, for: .normal)
        button.isUppercaseTitle = false
        button.addTarget(self, action: #selector(changeLocationClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 200).isActive = true
        return button
    }()
    
    let changeLocationDescriptor: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = MDCTypography.subheadFont()
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 300).isActive = true
        label.lineBreakMode = .byWordWrapping
        label.text = "*Changing the location will reset all location specific data from this device (eg. Order History, Reports, Tables, etc.)"
        return label
    }()
    
    var locationSelectorController: LocationSelectorTableViewController = UIStoryboard(name: "Locations", bundle: Bundle.main).instantiateViewController(withIdentifier: "LocationSelector") as! LocationSelectorTableViewController
    
    var locationSelectorModal: SlideOverModalView = SlideOverModalView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(locationName)
        self.view.addSubview(locationAddress)
        self.view.addSubview(changeLocation)
        self.view.addSubview(changeLocationDescriptor)
        
        self.addChildViewController(locationSelectorController)
        locationSelectorController.didMove(toParentViewController: self)
        locationSelectorController.locationSelectorDelegate = self
        
        locationSelectorModal.addViewToModal(view: locationSelectorController.view)
        locationSelectorModal.headerTitle = "Change Location"
        self.view.addSubview(locationSelectorModal)
        self.view.bringSubview(toFront: locationSelectorModal)
        
        let closeLocationSelectorModal = UITapGestureRecognizer(target: self, action: #selector(dismissLocationSelectorModal))
        closeLocationSelectorModal.numberOfTapsRequired = 1
        closeLocationSelectorModal.cancelsTouchesInView = false
        locationSelectorModal.blurView.addGestureRecognizer(closeLocationSelectorModal)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        NSLayoutConstraint(item: changeLocation, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: changeLocation, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: locationName, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: locationName, attribute: .bottom, relatedBy: .equal, toItem: changeLocation, attribute: .top, multiplier: 1, constant: -100).isActive = true
        
        NSLayoutConstraint(item: locationAddress, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: locationAddress, attribute: .top, relatedBy: .equal, toItem: locationName, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
        
        NSLayoutConstraint(item: changeLocationDescriptor, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: changeLocationDescriptor, attribute: .top, relatedBy: .equal, toItem: changeLocation, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
        
        locationSelectorModal.resizeView(frame: self.view.frame)
    }
    
    func changeLocationClicked(){
        locationSelectorController.tableView.reloadData()
        locationSelectorModal.presentModal(slideAnimation: false)
    }
    
    func dismissLocationSelectorModal(){
        locationSelectorModal.dismissModal(slideAnimation: false)
    }
    
    func locationSelected(location: Location) {
        NIMBUS.Devices?.changeDeviceLocation(newLocation: location)
        locationSelectorModal.dismissModal(slideAnimation: false)
        
        refreshLabels()
    }
    
    func refreshLabels(){
        locationName.text = NIMBUS.Location?.getLocationName()
        
        let address = NIMBUS.Location?.getLocationAddress()
        locationAddress.text = address?.street
    }
}
