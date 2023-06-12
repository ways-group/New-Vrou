//
//  CenterNavController.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/13/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit

class CenterNavController: UINavigationController {

    var SectionID = ""
    var OuterViewController = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
      //  tableVC.yourTableViewArray = localArrayValue
        // Do any additional setup after loading the view.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = self.navigationController?.viewControllers.first as! CenterViewController
               vc.SectionID = SectionID
               vc.OuterViewController = OuterViewController
    }

}
