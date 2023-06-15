//
//  SideMenuVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/5/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import SwiftyJSON
import PKHUD
import MOLH

protocol ChooseSideMenu {
    func SideToCenter()
}


class SideMenuVC:  BaseVC<SideMenuPresenter, BaseItem> {
    
    // MARK: - IBOutlet
    @IBOutlet weak var ProfileImage: UIImageView!
    @IBOutlet weak var ProfileName: UILabel!
    @IBOutlet weak var ProfileCity: UILabel!
    @IBOutlet weak var LanguageBtn: UIButton!
    @IBOutlet weak var notificationCounter: UILabel!
    @IBOutlet weak var MarketPlaceView: UIView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet var titles_lbl     :[UILabel]!
    // MARK: - Variables
    var delegate : ChooseSideMenu!
    var uiSupport = UISupport()
    var languages = [String]()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = SideMenuPresenter(router: RouterManager(self))
//        if FirstAdds.marketPlace == "0" {
//            MarketPlaceView.isHidden = true
//        }else if FirstAdds.marketPlace == "1" {
//            MarketPlaceView.isHidden = false
//        }
        notificationCounter.text = "\(NotificationsCounter.count)"
        if NotificationsCounter.count == 0 || NotificationsCounter.count == Int() {
            notificationCounter.isHidden = true
        }else {
            notificationCounter.isHidden = false
        }
//        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
//            languages = ["ar"]
//        }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
//            languages = ["en"]
//        }
//        
       if let nav = self.navigationController {
           uiSupport.TransparentNavigationController(navController: nav)
       }
        if User.shared.isLogedIn() {
           // User.shared.fetchUser()
            SetImage(image: ProfileImage, link: User.shared.data?.user?.image ?? "")
            ProfileName.text = User.shared.data?.user?.name ?? ""
            ProfileCity.text = User.shared.data?.user?.city?.city_name ?? ""
        }else {
            titles_lbl[9].text = "Login".ar()
            settingsView.isHidden = true
        }
        //selected item in SideMenu
        setSideMenuTabs()
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage:UIImage(), options: .highPriority , completed: nil)
    }
    @IBAction func itemsAction(_ button: UIButton){
        globalValues.sideMenu_selected = button.tag
        presenter.itemsRoute(button.tag)
    }
}
extension SideMenuVC {
    func setSideMenuTabs() {
        let sideMenu_selected_item =  globalValues.sideMenu_selected
        if sideMenu_selected_item <= 9 {
          titles_lbl[sideMenu_selected_item].alpha = 1.0
        }
    }
    // MARK: - SignOutAPI
    func SignOut() {
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.Logout.description, method: .post, parameters: ["":""] , encoding: URLEncoding.default, Header: ["Authorization" : "Bearer \(User.shared.TakeToken())" , "Accept":"application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                User.shared.remove()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
                keyWindow?.rootViewController = vc
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                keyWindow?.rootViewController = vc
                
            }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.SignOut()
                }
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}
