//
//  loginRequiredVC.swift
//  Vrou
//
//  Created by Mac on 10/27/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit

class loginRequiredVC: UIViewController {
    
    var uiSupport = UISupport()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nav = self.navigationController {
            uiSupport.TransparentNavigationController(navController: nav)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTransparentNavagtionBar()
    }
   
    @IBAction func SignInBtn_pressed(_ sender: Any) {
        RouterManager(self).push(view: View.loginVC, presenter: BasePresenter.self, item: BaseItem())
    }
    
    
    @IBAction func CancelBtn_pressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
