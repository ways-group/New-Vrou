//
//  SettingVC.swift
//  BeautySalon
//
//  Created by Islam Elgaafary on 10/9/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SideMenu
import MOLH
import Alamofire
import SwiftyJSON
import PKHUD
import RSSelectionMenu

class SettingVC: UIViewController {
    
    // MARK: - IBOutlet

    @IBOutlet weak var InviteFromFB: UIButton!
    @IBOutlet weak var InviteFromContacts: UIButton!
    @IBOutlet weak var YourFriends: UIButton!
    @IBOutlet weak var emailNotifications: UISwitch!
    @IBOutlet weak var MobileNotifications: UISwitch!
    @IBOutlet weak var LanguageBtn: UIButton!
    @IBOutlet weak var CountryBtn: UIButton!
    @IBOutlet weak var CityBtn: UIButton!
    
    
    // MARK: - Variables

    let toArabic = ToArabic()
    var success = ErrorMsg()
    
    var countriesList = Countries()
    var citiesList = Cities()
    var countries = [String]()
    var cities = [String]()
    
    var Languages = [String]()
    var languagesList = LanguagesList()
    var Languages_fullName = [String]()
   
    var ChosenCityID = ""
    var chosenNotificationState = ""
    var chosenEmailState = ""
    var ChosenCountryID = ""
    var choosenLang = ""
    var chosenCountryName = ""
    var CityPicker = false
    var CountryPickerIndex = 0
    var CityPickerIndex = 0
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            toArabic.ReverseButtonAlignment(Button: InviteFromFB)
            toArabic.ReverseButtonAlignment(Button: InviteFromContacts)
            toArabic.ReverseButtonAlignment(Button: YourFriends)
        }
        
        ChosenCountryID = "\(User.shared.data?.user?.country?.id ?? Int())"
        ChosenCityID = "\(User.shared.data?.user?.city?.id ?? Int())"
        choosenLang = "\(User.shared.data?.user?.locale ?? "en")"
        chosenNotificationState = User.shared.data?.user?.mobile_notification ?? "1"
        chosenEmailState = User.shared.data?.user?.email_notification ?? "1"
        
        CountryBtn.setTitle("\(User.shared.data?.user?.country?.country_name ?? "")", for: .normal)
        CityBtn.setTitle("\(User.shared.data?.user?.city?.city_name ?? "")", for: .normal)
        
        switch User.shared.data?.user?.locale ?? "en" {
        case "en":
            LanguageBtn.setTitle(("English"), for: .normal)
            break
        case "ar":
            LanguageBtn.setTitle(("عربي"), for: .normal)
            break
        default:
            break
        }
        
        
        if User.shared.data?.user?.email_notification == "1" {
            emailNotifications.setOn(true, animated: false)
        }else {
            emailNotifications.setOn(false, animated: false)
        }
        
        if User.shared.data?.user?.mobile_notification == "1" {
            MobileNotifications.setOn(true, animated: false)
        }else {
            MobileNotifications.setOn(false, animated: false)
        }
        
        setupSideMenu()
        GetCountries()
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
    
    
    // MARK: - SaveBtn
    @IBAction func SaveBtn_pressed(_ sender: Any) {
        if ChosenCityID != "" {
            UpdateSettings()
        }else {
            if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                HUD.flash(.label("Please fill all fields") , onView: self.view , delay: 1.6 , completion: nil)
            }else  if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                HUD.flash(.label("برجاء ادخال البيانات المطلوبة") , onView: self.view , delay: 1.6 , completion: nil)
            }
        }
    }
    
    // MARK: - EmailBtn
    @IBAction func EmailBtn_pressed(_ sender: UISwitch) {
        if sender.isOn {
            chosenEmailState = "1"
        }else {
            chosenEmailState = "0"
        }
    }
    
    
    // MARK: - NotificationsSwitchBtn
    @IBAction func M(_ sender: UISwitch) {
        if sender.isOn {
            chosenNotificationState = "1"
        }else {
            chosenNotificationState = "0"
        }
    }
    
    // MARK: - InviteFacebookFriendsBtn
    @IBAction func InviteFBbtn_pressed(_ sender: Any) {
    }
    
    // MARK: - InviteContactsBtn
    @IBAction func InviteFromContactsBtn_pressed(_ sender: Any) {
    }
    
    // MARK: - LanguagesBtn
    @IBAction func LanguageBtn_pressed(_ sender: Any) {
        
        let selectionMenu =  RSSelectionMenu(dataSource: Languages_fullName) { (cell, object, indexPath) in
            

            cell.textLabel?.text = "\(self.Languages_fullName[indexPath.row])"
            cell.textLabel?.textColor = .black
            cell.textLabel?.textAlignment = .center
        }
        
        selectionMenu.setSelectedItems(items: [self.LanguageBtn.title(for: .normal) ?? ""]) {
            (item, index, isSelected, selectedItems)  in
            
            self.LanguageBtn.setTitle(item, for: .normal)
            self.LanguageBtn.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            self.choosenLang = "\(self.languagesList.data?[index].name ?? "")"
        }
        
        // show as PresentationStyle = Push
        selectionMenu.show(style: .popover(sourceView: LanguageBtn, size: CGSize(width: 220, height: 100)) , from: self)
    }
    
    
    // MARK: - CountryBtn
    @IBAction func CountryBtn_pressed(_ sender: Any) {
        
        CityPicker = false
        CountryPickerIndex = 0
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            PickerActionSheet(title: "Please Select Country")
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar"{
            PickerActionSheet(title: "اختار الدولة")
        }
    }
    
    
    // MARK: - CityBtn
    @IBAction func ChangeCityBtn_pressed(_ sender: Any) {
        CityPicker = true
        CityPickerIndex = 0
       if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            PickerActionSheet(title: "Please Select city")
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar"{
            PickerActionSheet(title: "اختار المدينة")
        }
    }
    
    
    // MARK: - ChangeBtnPassword
    @IBAction func ChangePasswordBtn_pressed(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    
    
}

extension SettingVC {
    
    // MARK: - GetCountries_API
    func GetCountries() {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.CountriesList.description, method: .get, Header: [
            "Accept": "application/json",
            "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" ,
            "timezone": TimeZoneValue.localTimeZoneIdentifier
        ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                do {
                    self.countriesList = try JSONDecoder().decode(Countries.self, from: data!)
                    self.countriesList.data?.forEach({ (country) in
                        if country.country_name != "" {
                            self.countries.append(country.country_name ?? "")
                        }
                    })
                    self.GetLangauages()
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                UIApplication.shared.keyWindow?.rootViewController = vc
                
            }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.GetCountries()
                }
                self.present(vc, animated: true, completion: nil)
            }
            
        }
    }
    
    
    // MARK: - GetCities_API
    func GetCities() {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: "\(ApiManager.Apis.CitiesList.description)\(ChosenCountryID)", method: .get, Header: [
            "Accept": "application/json",
            "locale": UserDefaults.standard.string(forKey: "Language") ?? "en",
            "timezone": TimeZoneValue.localTimeZoneIdentifier
        ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                HUD.hide()
                do {
                    self.citiesList = try JSONDecoder().decode(Cities.self, from: data!)
                    self.cities.removeAll()
                    if self.ChosenCountryID != "\(User.shared.data?.user?.country?.id ?? Int())" {
                        self.ChosenCityID = ""
                        self.CityBtn.setTitle("", for: .normal)
                    }
                    self.citiesList.data?.forEach({ (city) in
                        if city.city_name != "" {
                            self.cities.append(city.city_name ?? "")
                        }
                    })
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                // self.navigationController?.present(vc, animated: true, completion: nil)
                UIApplication.shared.keyWindow?.rootViewController = vc
                
            }
            
        }
    }
    
    
    
    // MARK: - GetLanguages_API
    func GetLangauages() {
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.LanguagesList.description, method: .get, Header: [
            "Accept": "application/json",
            "locale": UserDefaults.standard.string(forKey: "Language") ?? "en",
            "timezone": TimeZoneValue.localTimeZoneIdentifier
        ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                //  HUD.hide()
                do {
                    self.languagesList = try JSONDecoder().decode(LanguagesList.self, from: data!)
                    self.languagesList.data?.forEach({ (lan) in
                        if lan.name != "" && lan.full_name != "" {
                            self.Languages.append(lan.name ?? "")
                            self.Languages_fullName.append(lan.full_name ?? "")
                        }
                    })
                    self.GetCities()
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                UIApplication.shared.keyWindow?.rootViewController = vc
            }
            
        }
    }
    
    
    
    // MARK: - UpdateSetting_API
    func UpdateSettings() {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.UpdateSettings.description, method: .post, parameters: ["language":choosenLang , "email_notification": chosenEmailState , "mobile_notification": chosenNotificationState , "country_id": ChosenCountryID , "city_id" : ChosenCityID],encoding: URLEncoding.default, Header:["Authorization": "Bearer \(User.shared.TakeToken())", "Accept": "application/json", "locale":choosenLang , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view) { (data, tmp) in
            if tmp == nil {
                HUD.hide()
                do {
                    HUD.hide()
                    User.shared.removeUser()
                    User.shared.SaveUser(data: data!)
                  
                    
                    if User.shared.fetchUser() {
                          FirstAdds.marketPlace = User.shared.data?.user?.marketplace ?? "0"
                        if self.choosenLang != UserDefaults.standard.string(forKey: "Language") ?? "en" {
                            
                            MOLH.setLanguageTo(self.choosenLang)
                            UserDefaults.standard.set(self.choosenLang, forKey: "Language")
                            MOLH.reset()
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginNavController") as! LoginNavController
                            UIApplication.shared.keyWindow?.rootViewController = vc
                        }
                        
                        if self.choosenLang == "en" {
                            HUD.flash(.label("Setting is Updated Successfully") , onView: self.view , delay: 2 , completion: nil)
                        }else if self.choosenLang == "ar" {
                            HUD.flash(.label("تم تغيير الاعدادات بنجاح") , onView: self.view , delay: 2 , completion: nil)
                        }
                        
                    }
                    
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 2 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                UIApplication.shared.keyWindow?.rootViewController = vc
            }
            
        }
    }
    
    
}


// MARK: - PickerDelegate
extension SettingVC : UIPickerViewDataSource , UIPickerViewDelegate {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
     }
     
     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if CityPicker {
            return cities.count
        }else {
            return countries.count
        }
     }
     
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if CityPicker {
            return cities[row]
        }else {
            return countries[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if CityPicker {
            CityPickerIndex = pickerView.selectedRow(inComponent: 0)
        }else {
            CountryPickerIndex = pickerView.selectedRow(inComponent: 0)
        }
        
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func PickerActionSheet(title:String) {
        let message = "\n\n\n\n\n\n"
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.isModalInPopover = true
         
        let height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 300)
        alert.view.addConstraint(height)
        
         let pickerFrame = UIPickerView(frame: CGRect(x: 0, y: 20, width: 270, height: 220))
        pickerFrame.tag = 555
        //set the pickers datasource and delegate
        pickerFrame.delegate = self
        pickerFrame.dataSource = self
        //Add the picker to the alert controller
        alert.view.addSubview(pickerFrame)
        let okAction = UIAlertAction(title: "Done", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            if self.CityPicker {
                self.ChosenCityID = "\(self.citiesList.data?[self.CityPickerIndex].id ?? Int())"
                self.CityBtn.setTitle(self.citiesList.data?[self.CityPickerIndex].city_name ?? "", for: .normal)
            }else {
                self.ChosenCountryID = "\(self.countriesList.data?[self.CountryPickerIndex].id ?? Int())"
                self.chosenCountryName = "\(self.countriesList.data?[self.CountryPickerIndex].country_name ?? "")"
              self.CountryBtn.setTitle(self.countriesList.data?[self.CountryPickerIndex].country_name ?? "", for: .normal)
                self.GetCities()
            }
        })
        
       
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(cancelAction)
         alert.addAction(okAction)
         self.present(alert, animated: true, completion: nil)
    }
    
    
}
