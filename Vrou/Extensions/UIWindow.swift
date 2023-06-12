//
//  UIWindows.swift
//  Vrou
//
//  Created by Mac on 12/25/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation


extension UIWindow {
    
    override open func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        globalValues.sideMenu_selected = 8
        if globalValues.ShakingEnabled {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShakeFeedbackVC") as! ShakeFeedbackVC
       // UIApplication.shared.keyWindow?.rootViewController = vc
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            vc.modalPresentationStyle = .overCurrentContext
            topController.present(vc, animated: true, completion: nil)
        }
            
        }
        
    }
    
}
