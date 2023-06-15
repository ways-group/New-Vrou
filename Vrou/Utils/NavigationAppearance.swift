//
//  File.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/13/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

extension UIViewController{
    func setTransparentNavagtionBar(_ barColor: UIColor = UIColor(named: "mainColor")!, _ title:String = "",_ isTranslucent:Bool = false){
        self.navigationController?.navigationBar.isTranslucent = isTranslucent
        self.navigationController?.navigationBar.barTintColor = barColor
        self.navigationController?.navigationBar.tintColor = UIColor(named: "whiteColor")!
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "whiteColor")!]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.title = title
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    func setCustomNavagationBar(_ barColor: UIColor = UIColor(named: "mainColor")!, _ title:String = "",_ isTranslucent:Bool = false){
        self.navigationController?.navigationBar.isTranslucent = isTranslucent
        self.navigationController?.navigationBar.barTintColor = barColor
        self.navigationController?.navigationBar.tintColor = UIColor(named: "whiteColor")!
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "whiteColor")!]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.title = title
    }
    func hideNavigationBar(){
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    func showNavigationBar(){
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    func hideStatusBar(){
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
            statusBar.isHidden = true
        } else {
            (UIApplication.shared.value(forKey: "statusBar")  as? UIView )?.isHidden = true
        }
    }
    func setStatusBarBackgroundColor(_ color: UIColor = UIColor(named: "mainColor")!) {
        
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
            statusBar.backgroundColor = color
            statusBar.tintColor = .green
            keyWindow?.addSubview(statusBar)
        } else {
            (UIApplication.shared.value(forKey: "statusBar")  as? UIView )?.backgroundColor = color
        }
        
    }
    
    func goToHome(){
       let vc = View.homeRootView.identifyViewController(viewControllerType: HomeRootView.self)
       let vcc = UINavigationController(rootViewController: vc)
       keyWindow?.rootViewController = vcc
    }
    func goToPushHome(){
        RouterManager(self).push(controller: View.homeRootView.identifyViewController(viewControllerType: HomeRootView.self))
    }
    func goToSplash(){
        let vc = View.splashVC.identifyViewController(viewControllerType: SplashVC.self)
        let vcc = UINavigationController(rootViewController: vc)
        keyWindow?.rootViewController = vcc
    }
    

}
