//
//  NoConnectionVC.swift
//  Vrou
//
//  Created by Mac on 10/22/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit

class NoConnectionVC: UIViewController {
    
    var callbackClosure: (() -> Void)?
    
    override func viewWillDisappear(_ animated: Bool) {
        callbackClosure?()
    }
    
    
    @IBAction func TryAgainBtn_pressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
