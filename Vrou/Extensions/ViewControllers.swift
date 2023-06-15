//
//  ViewControllers.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/12/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import Foundation

extension UIViewController {
    
    func TransparentNavigationController() {
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
}


