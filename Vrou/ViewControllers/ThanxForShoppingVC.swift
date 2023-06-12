//
//  ThanxForShoppingVC.swift
//  Vrou
//
//  Created by Mac on 10/30/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit

protocol DonePressed {
    func DonePressed_func()
}

class ThanxForShoppingVC: UIViewController {
    
     var delegate : DonePressed!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func DoneBtn_pressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: {
            if let delegate = self.delegate {
            delegate.DonePressed_func()
        }
        })
    }
    
    
}
