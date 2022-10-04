//
//  masterNavigationController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-20.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MasterViewController: UIViewController {
    @IBOutlet weak var homeButton: UIButton!

    var mainMenuManager: MainMenuManager?
    
    @IBOutlet weak var statusBar: UIView!
    
    var orderView: UIView = UIView()
    var secondaryContentView: UIView = UIView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(orderView)
        self.view.addSubview(secondaryContentView)
        self.view.bringSubview(toFront: statusBar)

        mainMenuManager = MainMenuManager(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), view: self.view)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NIMBUS.Navigation?.initializeMasterNavigationController(masterNavigationController: self)
        
        NIMBUS.Navigation?.loadOrdersView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        orderView.frame = self.view.frame
        secondaryContentView.frame = self.view.frame
    }
    
    @IBAction func openMenu(_ sender: Any) {
        showMenu()
    }
    
    func showMenu(){
        mainMenuManager?.showMenu()
    }
    
    func goToStartOfApp(){
        performSegue(withIdentifier: "segueToStartOfApp", sender: nil)
    }
}
