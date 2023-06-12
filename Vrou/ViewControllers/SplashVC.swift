//
//  SplashVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/4/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import RevealingSplashView

class SplashVC: UIViewController {
    
    @IBOutlet weak var LogoView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Initialize a revealing Splash with with the iconImage, the initial size and the background color
        let revealingSplashView = RevealingSplashView(iconImage: #imageLiteral(resourceName: "VrouLogo"),iconInitialSize: CGSize(width: 200, height: 200), backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))
        
        
        
        // MARK: - Adds the revealing splash view as a sub view
        self.view.addSubview(revealingSplashView)
        
        
        
        
        // MARK: - Starts animation
        revealingSplashView.startAnimation(){
            if !Shortcuts.shortcut {
            if User.shared.isLogedIn() {
                if User.shared.fetchUser() {
                    
                    if User.shared.data?.user?.country_id != "0" && User.shared.data?.user?.country_id != nil {
//                        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "BeautyWorldNavController") as!  BeautyWorldNavController
//                        UIApplication.shared.keyWindow?.rootViewController = vc
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginNavController") as! LoginNavController
                        UIApplication.shared.keyWindow?.rootViewController = vc
                    }else {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginNavController") as! LoginNavController
                        UIApplication.shared.keyWindow?.rootViewController = vc
                    }
                }
            }else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginNavController") as! LoginNavController
                UIApplication.shared.keyWindow?.rootViewController = vc
            }
            }else {
                Shortcuts.shortcut = false
                switch Shortcuts.ID {
                    
                case "com.Vrou.Offers":
                    let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "OffersNavController") as! OffersNavController
                    Shortcuts.ID = ""
                    UIApplication.shared.keyWindow?.rootViewController = vc
                    
                case "com.Vrou.Places":
                    let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "CenterNavController") as! CenterNavController
                     Shortcuts.ID = ""
                    UIApplication.shared.keyWindow?.rootViewController = vc
                case "com.Vrou.Services":
                    let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "ServicesNavController") as! ServicesNavController
                     Shortcuts.ID = ""
                    UIApplication.shared.keyWindow?.rootViewController = vc
                case "com.Vrou.Marketplace":
                    let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "ShopNavController") as! ShopNavController
                     Shortcuts.ID = ""
                    UIApplication.shared.keyWindow?.rootViewController = vc
                default:
                    break
                }
                
                
            }
        }
            
        
    }
    
    
}


struct Shortcuts {
    static var shortcut = false
    static var ID = ""
}
