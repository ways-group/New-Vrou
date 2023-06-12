//
//  ShakeFeedbackVC.swift
//  Vrou
//
//  Created by Mac on 12/25/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit

class ShakeFeedbackVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        globalValues.ShakingEnabled = false
        // Do any additional setup after loading the view.
    }
    

   
    @IBAction func HaveProblemBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContactUsNavController") as! ContactUsNavController
           UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    
    @IBAction func HelpSupportBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HelpSupportNavController") as! HelpSupportNavController
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    @IBAction func X_Btn_pressed(_ sender: Any) {
        globalValues.ShakingEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
}
