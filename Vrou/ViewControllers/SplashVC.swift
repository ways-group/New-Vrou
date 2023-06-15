//
//  SplashVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/4/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import RevealingSplashView

class SplashVC: BaseVC<BasePresenter, BaseItem> {
    
    @IBOutlet weak var LogoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     //   setTransparentNavagtionBar(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), "", true)
        let revealingSplashView = RevealingSplashView(iconImage: #imageLiteral(resourceName: "VrouLogo"),iconInitialSize: CGSize(width: 200, height: 200), backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))
        self.view.addSubview(revealingSplashView)
        revealingSplashView.startAnimation(){
            !Shortcuts.shortcut ? self.openfirstAds() : self.openShortcut()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         setTransparentNavagtionBar(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), "", true)
        
    }
    func openfirstAds(){
        if  !UserDefaults.standard.bool(forKey: "changelang") {
            UserDefaults.standard.set(true, forKey: "changelang")
            RouterManager(self).push(view: View.changeLanguageView, presenter: BasePresenter.self, item: BaseItem())
        }
        else {
            RouterManager(self).push(view: View.firstAdVC, presenter: BasePresenter.self, item: BaseItem())
        }
    }
    
    func openShortcut(){
        Shortcuts.shortcut = false
        switch Shortcuts.ID {
        case "com.Vrou.Offers":
            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "OffersNavController") as! OffersNavController
            Shortcuts.ID = ""
            keyWindow?.rootViewController = vc
            
        case "com.Vrou.Places":
            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "CenterNavController") as! CenterNavController
             Shortcuts.ID = ""
            keyWindow?.rootViewController = vc
        case "com.Vrou.Services":
            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "ServicesNavController") as! ServicesNavController
             Shortcuts.ID = ""
            keyWindow?.rootViewController = vc
        case "com.Vrou.Marketplace":
            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "ShopNavController") as! ShopNavController
             Shortcuts.ID = ""
            keyWindow?.rootViewController = vc
        default:
            break
        }
    }
}
struct Shortcuts {
    static var shortcut = false
    static var ID = ""
}
