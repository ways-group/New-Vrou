//
//  FirstAdVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/4/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PKHUD
import CoreLocation

class FirstAdVC: BaseVC<BasePresenter, BaseItem> , CLLocationManagerDelegate{
    // MARK: - IBOutlet
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var AdIamge: UIImageView!
    
    // MARK: - Variables
    var ads = FirstAds()
    var uiSUpport = UISupport()
    let locationManager = CLLocationManager()
    var requested = false
    var lat = ""
    var long = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let nav = self.navigationController {
//            uiSUpport.TransparentNavigationController(navController: nav)
//        }
        hideNavigationBar()
        mainView.contentView = logo
        mainView.isShimmering = true
        mainView.shimmeringSpeed = 550
        mainView.shimmeringOpacity = 1
        
        // For use in foreground
        DispatchQueue.global().async {
            let manager = CLLocationManager()
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.startUpdatingLocation()
                
            default:
                self.GetAdsData()
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showNavigationBar()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        long = "\(locValue.longitude)"
        lat = "\(locValue.latitude)"
        
        if !requested {
            requested = true
            GetAdsData()
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            print("user allow app to get location data when app is active or in background")
        case .authorizedWhenInUse:
            print("user allow app to get location data only when app is active")
        case .denied:
            GetAdsData()
        case .restricted:
            print("parental control setting disallow location data")
        case .notDetermined:
            print("the location permission dialog haven't shown before, user haven't tap allow/disallow")
        }
    }
    
 // MARK: - SkipBtn
    @IBAction func SkipBtn_pressed(_ sender: Any) {
      //  goToHome()
        goToPushHome()
    }
    
     // MARK: - GetAdsData
    func GetAdsData() {
        var headerData = [String:String]()
        if User.shared.isLogedIn() {
            User.shared.fetchUser()
            headerData =  [
                "Authorization": "Bearer \(User.shared.TakeToken())",
                "Accept": "application/json",
                "locale": UserDefaults.standard.string(forKey: "Language") ?? "en",
                "timezone": TimeZoneValue.localTimeZoneIdentifier
            ]
            print(headerData)
        }else {
            headerData = [
                "Accept": "application/json",
                "locale": UserDefaults.standard.string(forKey: "Language") ?? "en",
                "timezone": TimeZoneValue.localTimeZoneIdentifier
            ]
            print(headerData)
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            ApiManager.shared.ApiRequest(URL: "\(ApiManager.Apis.FreeAdsList.description)lat=\(lat)&lng=\(long)", method: .get, Header:headerData, ExtraParams: nil, view: self.view) { (data, tmp) in
                print("\(ApiManager.Apis.FreeAdsList.description)lat=\(self.lat)&lng=\(self.long)")
                if tmp == nil {
                    do {
                        print(data)
                        self.ads = try JSONDecoder().decode(FirstAds.self, from: data!)
                        print(self.ads)
                        self.SetImage(image: self.AdIamge, link: self.ads.first_ads ?? "")
                        self.mainView.isHidden = true
                        self.mainView.isShimmering = false
                        
                        FirstAdds.first_ads = self.ads.first_ads ?? ""
                        FirstAdds.register_ads = self.ads.register_ads ?? ""
                        FirstAdds.login_ads = self.ads.login_ads ?? ""
                        FirstAdds.discover_ads = self.ads.discover_ads ?? ""
                        FirstAdds.marketPlace = self.ads.marketplace ?? "0"
                        FirstAdds.week_offer_day = self.ads.week_offer_day ?? ""
                        UserDefaults.standard.set(self.ads.city_id ?? 0, forKey: "GuestCityId")
                        self.CheckTodayName()
                        
                       
                        
                    }catch {
                        HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                    }
                    
                }else if tmp == "401" {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    self.navigationController?.pushViewController(vc, animated: false)
                }else if tmp == "NoConnect" {
                    guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                    vc.callbackClosure = { [weak self] in
                        self?.GetAdsData()
                    }
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage: nil, options: .highPriority , completed: nil)
    }
    
    
    func CheckTodayName() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale =  NSLocale(localeIdentifier: "en") as Locale
        print(dateFormatter.string(from: date))
       
        if dateFormatter.string(from: date).lowercased() == FirstAdds.week_offer_day.lowercased() && !UserDefaults.standard.bool(forKey: "WeekOffer") {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ThisWeekNavController") as! ThisWeekNavController
            self.present(vc, animated: true, completion: nil)
        }else {
            if dateFormatter.string(from: date).lowercased() != FirstAdds.week_offer_day.lowercased() {
                UserDefaults.standard.set(false, forKey: "WeekOffer")
            }
        }
//
//        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "ThisWeekNavController") as! ThisWeekNavController
//        self.present(vc, animated: true, completion: nil)
    }
    
}
