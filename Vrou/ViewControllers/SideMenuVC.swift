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
import RSSelectionMenu

protocol ChooseSideMenu {
    func SideToCenter()
}


class SideMenuVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var ProfileImage: UIImageView!
    @IBOutlet weak var ProfileName: UILabel!
    @IBOutlet weak var ProfileCity: UILabel!
    @IBOutlet weak var SignOutBtn: UIButton!
    @IBOutlet weak var LanguageBtn: UIButton!
    @IBOutlet weak var notificationCounter: UILabel!
    @IBOutlet weak var MarketPlaceView: UIView!
    
    
    @IBOutlet weak var home_lbl     :UILabel!
    @IBOutlet weak var places_lbl   :UILabel!
    @IBOutlet weak var services_lbl :UILabel!
    @IBOutlet weak var offer_lbl    :UILabel!
    @IBOutlet weak var shop_lbl     :UILabel!
    @IBOutlet weak var cart_lbl     :UILabel!
    @IBOutlet weak var nearby_lbl   :UILabel!
    @IBOutlet weak var watch_lbl    :UILabel!
    @IBOutlet weak var help_lbl     :UILabel!
    @IBOutlet weak var settings_lbl :UILabel!
    
    // MARK: - Variables
    var delegate : ChooseSideMenu!
    var uiSupport = UISupport()
    var languages = [String]()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FirstAdds.marketPlace == "0" {
            MarketPlaceView.isHidden = true
        }else if FirstAdds.marketPlace == "1" {
            MarketPlaceView.isHidden = false
        }
        
        notificationCounter.text = "\(NotificationsCounter.count)"
        
        if NotificationsCounter.count == 0 || NotificationsCounter.count == Int() {
            notificationCounter.isHidden = true
        }else {
            notificationCounter.isHidden = false
        }
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            languages = ["ar"]
        }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            languages = ["en"]
        }
        
        if let nav = self.navigationController {
            uiSupport.TransparentNavigationController(navController: nav)
        }
        
        if User.shared.isLogedIn() {
            User.shared.fetchUser()
            SetImage(image: ProfileImage, link: User.shared.data?.user?.image ?? "")
            ProfileName.text = User.shared.data?.user?.name ?? ""
            ProfileCity.text = User.shared.data?.user?.city?.city_name ?? ""
            
            if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                SignOutBtn.setTitle("تسجيل الخروج", for: .normal)
            }
            
        }else {
            if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                SignOutBtn.setTitle("تسجيل الدخول", for: .normal)
            }else {
                SignOutBtn.setTitle("Login", for: .normal)
            }
            
        }
        
        //selected item in SideMenu
        setSideMenuTabs()
        
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage:UIImage(), options: .highPriority , completed: nil)
    }
    
    // MARK: - LanguageBtn
    @IBAction func LanguageBtn_pressed(_ sender: Any) {
        let current_lang = UserDefaults.standard.string(forKey: "Language") ?? "en"
        let lang = current_lang  == "ar" ? "en" : "ar"
        MOLH.setLanguageTo(lang )
        UserDefaults.standard.set(lang, forKey: "Language")
        print(UserDefaults.standard.string(forKey: "Language") ?? "en")
        
        MOLH.reset()
        
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginNavController") as! LoginNavController
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
  
    
    // MARK: - HomeBtn
    @IBAction func HomeBtn_pressed(_ sender: Any) {
        
        globalValues.sideMenu_selected = 0

        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "BeautyWorldVC") as! BeautyWorldVC
        self.navigationController?.popViewController(animated: false)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // MARK: - PlacesBtn
    @IBAction func PlacesBtn_pressed(_ sender: Any) {
        globalValues.sideMenu_selected = 1

        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "CenterViewController") as! CenterViewController
        CenterParams.SectionID = "0"
        self.navigationController?.popViewController(animated: false)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // MARK: - NearbyBtn
    @IBAction func NearbyBtn_pressed(_ sender: Any) {
        globalValues.sideMenu_selected = 6

        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "MapVC") as! MapVC
       // self.navigationController?.popViewController(animated: false)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - WatchBtn
    @IBAction func WatchBtn_pressed(_ sender: Any) {
        globalValues.sideMenu_selected = 7

        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WatchVC") as! WatchVC
        self.navigationController?.popViewController(animated: false )
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // MARK: - OffersBtn
    @IBAction func OffersBtn_pressed(_ sender: Any) {
        
        globalValues.sideMenu_selected = 2

        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "OffersViewController") as! OffersViewController
        self.navigationController?.popViewController(animated: false)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // MARK: - ServicesBtn
    @IBAction func ServicesBtn_pressed(_ sender: Any) {
        
        globalValues.sideMenu_selected = 3

        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "ServicesVC") as! ServicesVC
        self.navigationController?.popViewController(animated: false )
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    
    // MARK: - viewDidLoad
    @IBAction func MarketPlaceBtn_pressed(_ sender: Any) {
        
        globalValues.sideMenu_selected = 4

        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "ShopViewController") as! ShopViewController
        self.navigationController?.popViewController(animated: false )
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // MARK: - MyAccountBtn
    @IBAction func MyAccountBtn_pressed(_ sender: Any) {
        if User.shared.isLogedIn() {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditAccountNavController") as! EditAccountNavController
            UIApplication.shared.keyWindow?.rootViewController = vc
            
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: - AboutVrouBtn
    @IBAction func AboutVrouBtn_pressed(_ sender: Any) {
        globalValues.sideMenu_selected = 8
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AboutAppVC") as! AboutAppVC
        self.navigationController?.popViewController(animated: false )
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // MARK: - CartBtn
    @IBAction func CartBtn_pressed(_ sender: Any) {
        
        if User.shared.isLogedIn(){
            globalValues.sideMenu_selected = 5

            let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CartVC") as! CartVC
            self.navigationController?.popViewController(animated: false )
            self.navigationController?.pushViewController(vc, animated: false)
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    
    // MARK: - SettingBtn
    @IBAction func SettingBtn_pressed(_ sender: Any) {
        
        if User.shared.isLogedIn() {
            globalValues.sideMenu_selected = 9

            let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
            self.navigationController?.popViewController(animated: false )
            self.navigationController?.pushViewController(vc, animated: false)
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    // MARK: - NotificationsBtn
    @IBAction func NotificationsBtn_pressed(_ sender: Any) {
        
        if User.shared.isLogedIn(){
            let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NotificationsVC") as! NotificationsVC
            self.navigationController?.popViewController(animated: false )
            self.navigationController?.pushViewController(vc, animated: false)
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: - SignoutBtn
    @IBAction func SignOutBtn_pressed(_ sender: Any) {
        if User.shared.isLogedIn() {
            SignOut()
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WelcomeNavController") as! WelcomeNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: - SearchBtn
    @IBAction func SearchBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "CentersSearchNavController") as! CentersSearchNavController
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    
}

extension SideMenuVC {
    
    func setSideMenuTabs() {
         
        let sideMenu_selected_item =  globalValues.sideMenu_selected
        
        switch sideMenu_selected_item {
        case 0:
            home_lbl     .alpha = 1.0
            print(sideMenu_selected_item)
        case 1:
            places_lbl   .alpha = 1.0
            print(sideMenu_selected_item)
        case 2:
            offer_lbl   .alpha = 1.0
            print(sideMenu_selected_item)
        case 3:
            services_lbl.alpha = 1.0
            print(sideMenu_selected_item)
        case 4:
            shop_lbl    .alpha = 1.0
            print(sideMenu_selected_item)
        case 5:
            cart_lbl    .alpha = 1.0
            print(sideMenu_selected_item)
        case 6:
            nearby_lbl .alpha = 1.0
            print(sideMenu_selected_item)
        case 7:
            watch_lbl   .alpha = 1.0
            print(sideMenu_selected_item)
        case 8:
            help_lbl    .alpha = 1.0
            print(sideMenu_selected_item)
        case 9:
            settings_lbl.alpha = 1.0
            print(sideMenu_selected_item)
        case 10:
           // signin_lbl  .tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            print(sideMenu_selected_item)

        default:
            print(sideMenu_selected_item)
        }
    //}
    }
    
    
    
    
    // MARK: - SignOutAPI
    func SignOut() {
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.Logout.description, method: .post, parameters: ["":""] , encoding: URLEncoding.default, Header: ["Authorization" : "Bearer \(User.shared.TakeToken())" , "Accept":"application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                User.shared.remove()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
                UIApplication.shared.keyWindow?.rootViewController = vc
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                UIApplication.shared.keyWindow?.rootViewController = vc
                
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
