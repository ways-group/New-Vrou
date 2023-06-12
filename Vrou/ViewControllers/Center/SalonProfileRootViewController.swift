//
//  SalonProfileRootViewController.swift
//  Vrou
//
//  Created by MacBook Pro on 12/2/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit

class SalonProfileRootViewController: UIViewController{
    
    //Outlet
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var OffersTab  :  UIView!
    @IBOutlet weak var productsTab: UIView!
    @IBOutlet weak var ServicesTab: UIView!
    @IBOutlet weak var tabsView: UIView!
    @IBOutlet weak var back_btn: UIButton!

    @IBOutlet weak var AboutLbl: UILabel!
    @IBOutlet weak var ContactUsLbl: UILabel!
    @IBOutlet weak var OffersLbl: UILabel!
    @IBOutlet weak var ProductsLbl: UILabel!
    @IBOutlet weak var ServicesLbl: UILabel!
    
    @IBOutlet weak var TabsStackView: UIStackView!
    
    //DATA
    var uiSUpport = UISupport()
    var current_btn = 5
    var salon_id : Int = 0
    var tabs = [String]()

 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigation settings
        
        print("====\(salon_id)")
                
        NotificationCenter.default.addObserver(self, selector: #selector(setBottomTabs(_:)), name: .visible_tabs , object: nil)
        

        if let nav = self.navigationController {
            TabsStackView.addBackground(color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        }
        
       
        let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "CenterAboutVC") as! CenterAboutVC
        
        vc.SalonID = salon_id
        EmbededViewContainerUtil.embed(vc_: vc, withIdentifier: "", parent: self, container: container)

        tabsView.isHidden = true

//        productsTab.isHidden = false
//        OffersTab.isHidden = false
//        ServicesTab.isHidden = false

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
 
      //   self.navigationController?.navigationBar.isTranslucent = true
        
        if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            
          //  back_arrow.setImage(#imageLiteral(resourceName: "BackArrow"), for: .normal)
            back_btn.setImage(#imageLiteral(resourceName: "arrow"), for: .normal)

        }

    }
   
}

//MARK: - Buttons tabs Action
extension SalonProfileRootViewController{
    
    @IBAction func tapBarButtons_action(_ sender: UIButton) {
        
        if current_btn == sender.tag {return}
        //change buttons tab color (selected tab)
        sender.tintColor = #colorLiteral(red: 0.6784313725, green: 0.1450980392, blue: 0.4509803922, alpha: 1)
        
        let last = view.viewWithTag(current_btn) as! UIButton
        last.tintColor =  #colorLiteral(red: 0.03921568627, green: 0.02745098039, blue: 0.3764705882, alpha: 1)
        current_btn = sender.tag
        
        AboutLbl.textColor = #colorLiteral(red: 0.03921568627, green: 0.02745098039, blue: 0.3764705882, alpha: 1)
        ContactUsLbl.textColor = #colorLiteral(red: 0.03921568627, green: 0.02745098039, blue: 0.3764705882, alpha: 1)
        OffersLbl.textColor = #colorLiteral(red: 0.03921568627, green: 0.02745098039, blue: 0.3764705882, alpha: 1)
        ProductsLbl.textColor = #colorLiteral(red: 0.03921568627, green: 0.02745098039, blue: 0.3764705882, alpha: 1)
        ServicesLbl.textColor = #colorLiteral(red: 0.03921568627, green: 0.02745098039, blue: 0.3764705882, alpha: 1)
        
        switch sender.tag {
        case 5:
            let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "CenterAboutVC") as! CenterAboutVC
            
            vc.SalonID = salon_id
            AboutLbl.textColor = #colorLiteral(red: 0.6784313725, green: 0.1450980392, blue: 0.4509803922, alpha: 1)
            EmbededViewContainerUtil.embed(vc_: vc, withIdentifier: "", parent: self, container: container)
       
        case 1:
            let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "CenterOffersVC") as! CenterOffersVC
            
            vc.SalonID = salon_id
            OffersLbl.textColor = #colorLiteral(red: 0.6784313725, green: 0.1450980392, blue: 0.4509803922, alpha: 1)
            EmbededViewContainerUtil.embed(vc_: vc, withIdentifier: "", parent: self, container: container)
        
        case 2:
            let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "CenterProductsVC") as! CenterProductsVC
            
            vc.SalonID = salon_id
             ProductsLbl.textColor = #colorLiteral(red: 0.6784313725, green: 0.1450980392, blue: 0.4509803922, alpha: 1)
            EmbededViewContainerUtil.embed(vc_: vc, withIdentifier: "", parent: self, container: container)
            
        case 3:
            let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "CenterServicesVC") as! CenterServicesVC
            
            vc.salonID = salon_id
            ServicesLbl.textColor = #colorLiteral(red: 0.6784313725, green: 0.1450980392, blue: 0.4509803922, alpha: 1)
            EmbededViewContainerUtil.embed(vc_: vc, withIdentifier: "", parent: self, container: container)
            
//        case 4:
//            let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "CenterBranchesVC") as! CenterBranchesVC
//
//            vc.SalonID = salon_id
//             ContactUsLbl.textColor = #colorLiteral(red: 0.6784313725, green: 0.1450980392, blue: 0.4509803922, alpha: 1)
//            EmbededViewContainerUtil.embed(vc_: vc, withIdentifier: "", parent: self, container: container)
            
        default:
            print("button tag = \(sender.tag)")
        }
        
    }
    
    
    
    @IBAction func backBtn_action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func setBottomTabs(_ notification: NSNotification) {
        
        
        if let tabs_data = notification.userInfo?["data"] as? [String] {
            
            tabs = tabs_data
            if self.tabs.contains("product") {
                productsTab.isHidden = false
            }
            if self.tabs.contains("service") {
                ServicesTab.isHidden = false
            }
            if self.tabs.contains("offer") {
                OffersTab.isHidden = false
            }
            tabsView.isHidden = false

        }

    }
    
    
}


extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: CGRect(x: bounds.origin.x-10, y: bounds.origin.y, width: bounds.width+20, height: bounds.height+2))
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        subView.cornerRadius = 15
        subView.shadowRadius = 10
        subView.shadowOpacity = 0.8
        subView.shadowOffset.height = 10
        subView.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        insertSubview(subView, at: 0)
    }
}
