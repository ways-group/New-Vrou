//
//  ServicePolicyVC.swift
//  Vrou
//
//  Created by Mac on 12/4/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit

class ServicePolicyVC: UIViewController {

    @IBOutlet weak var PolicyLbl: UILabel!
    var policy = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PolicyLbl.text = policy
    }
    
    @IBAction func X_btn_pressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
