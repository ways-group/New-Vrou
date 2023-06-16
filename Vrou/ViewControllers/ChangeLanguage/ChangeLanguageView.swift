//
//  ChangeLanguageView.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/8/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import MOLH

class ChangeLanguageView:  BaseVC<BasePresenter, BaseItem> {
    
    @IBOutlet weak var AdIamge: UIImageView!
    override func bindind() {
        GetAdsData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTransparentNavagtionBar()
        hideNavigationBar()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
    }
    var lat = ""
    var long = ""
    @IBAction func LanguageBtn_pressed(_ sender: UIButton) {
        let current_lang = UserDefaults.standard.string(forKey: "Language") ?? "en"
        let required_lang = (sender.tag == 1) ? "ar" : "en"
        if  current_lang == required_lang {
            //RouterManager(self).popBack()
           // goToHome()
            goToPushHome()
        }else{
            MOLH.setLanguageTo(required_lang)
            UserDefaults.standard.set(required_lang, forKey: "Language")
            MOLH.reset()
            goToSplash()
        }
    }
    // MARK: - GetAdsData
    func GetAdsData() {
        var headerData = [String:String]()
        if User.shared.isLogedIn() {
            headerData =  [
                "Authorization": "Bearer \(User.shared.TakeToken())",
                "Accept": "application/json",
                "locale": UserDefaults.standard.string(forKey: "Language") ?? "en",
                "timezone": TimeZoneValue.localTimeZoneIdentifier
            ]
        }else {
            headerData = [
                "Accept": "application/json",
                "locale": UserDefaults.standard.string(forKey: "Language") ?? "en",
                "timezone": TimeZoneValue.localTimeZoneIdentifier
            ]
        }
        ApiManager.shared.ApiRequest(URL: "\(ApiManager.Apis.FreeAdsList.description)lat=\(lat)&lng=\(long)", method: .get, Header:headerData, ExtraParams: nil, view: self.view) { (data, tmp) in
            if tmp == nil {
                do {
                    let data_ = try JSONDecoder().decode(FirstAds.self, from: data!)
                    self.SetImage(image: self.AdIamge, link: data_.first_ads ?? "")
                }catch {
                    print(error)
                   // HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
            }
        }
    }
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage: nil, options: .highPriority , completed: nil)
    }
}
