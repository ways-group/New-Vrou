//
//  SubHomeVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/5/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import Tabman
import Pageboy

class SubHomeVC: TabmanViewController , PageboyViewControllerDataSource  {

    
    
    private var vcs : [UIViewController] =  []
    var items : [Item] = []
    
    
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        if vcs.count > 0 {
            return vcs.count
        }
        return 0
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        //vcs[index].testName = "page \(index)"
        if vcs.count > 0 {
            return vcs[index]
        }
        return MyWorldVC()
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.bar.style = .buttonBar
        
        self.bar.appearance = TabmanBar.Appearance({ (appearance) in
            
            // customize appearance here
            appearance.state.selectedColor = #colorLiteral(red: 0.6777178645, green: 0.1466906071, blue: 0.4528601766, alpha: 1)
            appearance.text.font = .systemFont(ofSize: 16.0)
            //  appearance.indicator.isProgressive = true
            appearance.indicator.color = #colorLiteral(red: 0.6777178645, green: 0.1466906071, blue: 0.4528601766, alpha: 1)
            appearance.style.background = .clear
        })
        
        
        self.dataSource = self
        
        
        CreateTab(TabDesign: "MyWorldVC", tabName: "My World")
        CreateTab(TabDesign: "HomeDiscoverVC", tabName: "Discover")
        CreateTab(TabDesign: "BeautyWorldVC", tabName: "Beauty World")
        
        
        self.bar.items = self.items
        
        self.reloadPages()
    }
    

    
    
    
    func CreateTab( TabDesign:String,tabName:String) {
        
        if TabDesign == "MyWorldVC" {
            
            let followersVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "MyWorldVC") as! MyWorldVC
            self.vcs.append(followersVC)
            
            let Following = Item(title: tabName)
            self.items.append(Following)
        }
        
        if TabDesign == "HomeDiscoverVC" {
            
            let followersVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeDiscoverVC") as! HomeDiscoverVC
            self.vcs.append(followersVC)
            
            let Following = Item(title: tabName)
            self.items.append(Following)
        }
        
        if TabDesign == "BeautyWorldVC" {
            
            let followersVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "BeautyWorldVC") as! BeautyWorldVC
            self.vcs.append(followersVC)
            
            let Following = Item(title: tabName)
            self.items.append(Following)
        }
        
        
        
    }


}


extension SubHomeVC : UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // im my example the desired view controller is the second one
        // it might be different in your case...
        let secondVC = tabBarController.viewControllers?[1] as! UINavigationController
        secondVC.popToRootViewController(animated: false)
    }
    
}
