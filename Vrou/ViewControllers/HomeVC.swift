//
//  HomeVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/5/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
class HomeVC: UIViewController {
    
    
    var uiSUpport = UISupport()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nav = self.navigationController {
            uiSUpport.TransparentNavigationController(navController: nav)
        }
        
    }
    
    
}



