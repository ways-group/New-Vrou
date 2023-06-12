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
    
    
    @IBAction func SignInBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func CancelBtn_pressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
