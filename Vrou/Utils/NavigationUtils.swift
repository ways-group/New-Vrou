//
//  NavigationUtils.swift
//  Vrou
//
//  Created by MacBook Pro on 12/2/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

extension Notification.Name {
    static let visible_tabs = Notification.Name("visible_tabs")
    static let timer_down = Notification.Name("timer_down")
}


class NavigationUtils {

    //proj storyboards
    static let  center_storyboard = "Center"
    static let  category_storyboard = ""
    
    //proj ViewsController identifier
    static let offers_vc = "OffersViewController"
    static let services_vc = "ServicesVC"
    static let shop_vc = "ShopViewController"


    //Go to Salon Profile
    static func goToSalonProfile(from: UIViewController, salon_id : Int) {
     
    let vc = UIStoryboard.init(name: center_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SalonProfileRootViewController") as! SalonProfileRootViewController
     
        vc.salon_id = salon_id
   //  vc.show_dismiss_adv = show_dismiss_adv
     from.navigationController?.pushViewController(vc, animated: true)
 }
    
    //side menu items action
    static func goToCentersPage(from: UIViewController, salon_id : String) {

    let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "CenterViewController") as! CenterViewController
     CenterParams.SectionID = salon_id
        
        if (salon_id == "4"){
            CenterParams.OuterViewController = true
        }
        
     from.navigationController?.pushViewController(vc, animated: false)
    }
    
    
    static func goto_specificViewByIdentifier(from: UIViewController, identifier: String) {
        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: identifier)

        from.navigationController?.pushViewController(vc, animated: false)
        
    }
    
    
//    @IBAction func ServicesBtn_pressed(_ sender: Any) {
//        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "ServicesVC") as! ServicesVC
//        //self.navigationController?.pushViewController(vc, animated: true)
//        self.navigationController?.popViewController(animated: false )
//        self.navigationController?.pushViewController(vc, animated: false)
//
//
//    }
//
//
//
//    @IBAction func ShopBtn_pressed(_ sender: Any) {
//        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "ShopViewController") as! ShopViewController
//        self.navigationController?.popViewController(animated: false )
//        self.navigationController?.pushViewController(vc, animated: false)
//    }

}
