//
//  ReservationPolicyPopUpVC.swift
//  Vrou
//
//  Created by Mac on 12/4/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit

protocol ConfirmPressed {
    func ConfirmPressed_func()
}

class ReservationPolicyPopUpVC: UIViewController {

    @IBOutlet weak var PolicyLbl: UILabel!
      var delegate : ConfirmPressed!
    var polictTxt = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PolicyLbl.text = polictTxt
        // Do any additional setup after loading the view.
    }
    

    @IBAction func ConfirmBtn_pressed(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                delegate.ConfirmPressed_func()
            }
        })
    }
    
    
    @IBAction func CancelBtn_pressed(_ sender: Any) {
      
        self.dismiss(animated: true, completion: nil)
    }
    

}
