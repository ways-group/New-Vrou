//
//  SupportUI.swift
//  Beauty
//
//  Created by MacBook Pro on 7/3/19.
//  Copyright © 2019 waysgroup. All rights reserved.
//

import Foundation
import UIKit

class UISupport {
    func TransparentNavigationController(navController:UINavigationController?) {
        navController?.navigationBar.backgroundColor = .clear
        navController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController?.navigationBar.shadowImage = UIImage()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}


class Background {
    
    func AddBackgroundEffect(image:UIImageView) {
        
        let view = UIView(frame: image.frame)
        
        let gradient = CAGradientLayer()
        
        gradient.frame = view.frame
        
        gradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
        
        gradient.locations = [-1.0, 0.8]
        
        view.layer.insertSublayer(gradient, at: 0)
        
        image.addSubview(view)
        
        image.bringSubviewToFront(view)
    }
}


