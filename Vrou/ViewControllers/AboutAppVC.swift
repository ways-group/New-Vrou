//
//  AboutAppVC.swift
//  BeautySalon
//
//  Created by Islam Elgaafary on 10/9/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SideMenu
import Alamofire
import SwiftyJSON
import PKHUD
import MOLH

class AboutAppVC: UIViewController {
    
    var aboutUrls = AboutURLs()
    
    // MARK: - IBOutlet
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSideMenu()
        GetAboutURLsData()
    }
    
     // MARK: - SetupSideMenu
    private func setupSideMenu() {
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sideMenuNavigationController = segue.destination as? SideMenuNavigationController else { return }
        sideMenuNavigationController.settings = makeSettings()
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            sideMenuNavigationController.leftSide = false
        }
    }
    
    private func makeSettings() -> SideMenuSettings {
        let presentationStyle = selectedPresentationStyle()
        presentationStyle.menuStartAlpha = 1.0
        presentationStyle.onTopShadowOpacity = 0.0
        presentationStyle.presentingEndAlpha = 1.0
        
        var settings = SideMenuSettings()
        settings.presentationStyle = presentationStyle
        settings.menuWidth = min(view.frame.width, view.frame.height)  * 0.9
        settings.statusBarEndAlpha = 0
        
        return settings
    }
    
    private func selectedPresentationStyle() -> SideMenuPresentationStyle {
        return .viewSlideOutMenuIn
    }
    
    
    // MARK: - GetAboutURL
    func GetAboutURLsData() {
        var headerData = [String:String]()
        headerData = ["Accept": "application/json"
            , "locale":UserDefaults.standard.string(forKey: "Language") ?? "en", "timezone": TimeZoneValue.localTimeZoneIdentifier
        ]
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.AboutURLs.description, method: .get, Header:headerData, ExtraParams: nil, view: self.view) { (data, tmp) in
            if tmp == nil {
                do {
                    self.aboutUrls = try JSONDecoder().decode(AboutURLs.self, from: data!)
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                UIApplication.shared.keyWindow?.rootViewController = vc
                
            }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.GetAboutURLsData()
                }
                self.present(vc, animated: true, completion: nil)
            }
            
        }
    }
    
    
    // MARK: - HelpCenterBtn
    @IBAction func HelpCenterBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "WebVC") as! WebVC
        vc.link = aboutUrls.data?.help_center ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - TermsCondtionsBtn
    @IBAction func TermsConditionsBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingTermsConditionsVC") as! SettingTermsConditionsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - PrivacyBtn
    @IBAction func PrivacyBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "WebVC") as! WebVC
        vc.link = aboutUrls.data?.privacy_policy ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
     // MARK: - AdvertiseBtn
    @IBAction func AdvertiseBtn_pressed(_ sender: Any) {
         let vc = self.storyboard?.instantiateViewController(withIdentifier: "AdvertiseVC") as! AdvertiseVC
         self.navigationController?.pushViewController(vc, animated: true)
    }
    
     // MARK: - BussinessBtn
    @IBAction func BussinssBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "WebVC") as! WebVC
        vc.link = aboutUrls.data?.bussiness_account ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - ContactUsBtn
    @IBAction func ContactUsBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContactUsVC") as! ContactUsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - ShareAppBtn
    @IBAction func ShareAppBtn_pressed(_ sender: Any) {
        let url =  "https://apps.apple.com/us/app/vrou/id1484066118?ls=1"
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    // MARK: - FollowUsBtn
    @IBAction func FollowUsBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "WebVC") as! WebVC
        vc.link = "https://www.facebook.com/vrouapp"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
