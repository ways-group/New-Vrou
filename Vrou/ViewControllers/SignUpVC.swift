//
//  SignUpVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/4/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import RSSelectionMenu
import Alamofire
import SwiftyJSON
import PKHUD
import MOLH
import SDWebImage

class SignUpVC: UIViewController{
    
    // MARK: - IBOutlet
    @IBOutlet weak var UserNameTxtField: UITextField!
    @IBOutlet weak var EmailTxtField   : UITextField!
    @IBOutlet weak var PhoneNumTxtField: UITextField!
    @IBOutlet weak var PasswordTxtField: UITextField!
    @IBOutlet weak var CountryBtn: UIButton!
    @IBOutlet weak var GovernmentBtn: UIButton!
    @IBOutlet weak var NextImage: UIImageView!
    @IBOutlet weak var ArrowImage: UIImageView!
    @IBOutlet weak var signUpBackground: UIImageView!
    
    // MARK: - Variables
    var countries = [String]()
    var cities = [String]()
    var countriesList = Countries()
    var citiesList = Cities()
    
    var uiSUpport = UISupport()
    let toArabic = ToArabic()
    
    var ChosenCountryID = ""
    var ChosenCityID = ""
    var chosenPhoneCode = ""
    var image = ""
    var CityPicker = false
    var CountryPickerIndex = 0
    var CityPickerIndex = 0
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SetImage(image: signUpBackground, link: FirstAdds.register_ads)
        PhoneNumTxtField.keyboardType = .asciiCapableNumberPad
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            toArabic.ReverseImage(Image: NextImage)
            toArabic.ReverseImage(Image: ArrowImage)
            toArabic.ReverseButtonAlignment(Button: CountryBtn)
            toArabic.ReverseButtonAlignment(Button: GovernmentBtn)
        }
        
        if let nav = self.navigationController {
            uiSUpport.TransparentNavigationController(navController: nav)
        }
        
        //TxtField delgates
        UserNameTxtField.delegate = self
        EmailTxtField   .delegate = self
        PhoneNumTxtField.delegate = self
        PasswordTxtField.delegate = self
        
        GetCountries()
        
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage: nil, options: .highPriority , completed: nil)
    }
    
    
    
    // MARK: - NextBtn
    @IBAction func NextBtn_pressed(_ sender: Any) {
        
        if UserNameTxtField.text == "" || EmailTxtField.text == "" || CountryBtn.currentTitle == "Country" || GovernmentBtn.currentTitle == "City" || GovernmentBtn.currentTitle == "" || PhoneNumTxtField.text == "" || PasswordTxtField.text == "" {
            if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                HUD.flash(.label("Please fill all fields"), onView: self.view , delay: 1.5)
            }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                HUD.flash(.label("برجاء ادخال البيانات المطلوبة"), onView: self.view , delay: 1.5)
            }
        }else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TermsVC") as! TermsVC
            let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = item
            self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "BackArrow")
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "BackArrow")
            vc.params = ["name":UserNameTxtField.text!, "email":EmailTxtField.text! , "password":PasswordTxtField.text! , "phone":"\(chosenPhoneCode)\(PhoneNumTxtField.text!)" , "country_id":ChosenCountryID , "city_id":ChosenCityID , "locale":"en" , "device_token": UserDefaults.standard.string(forKey: "FCM_new") ?? "" , "device_id": UIDevice.current.identifierForVendor!.uuidString ] // To be update the locale param
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    // MARK: - LoginBtn
    @IBAction func LoginBtn_pressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    // MARK: - CountryBtn_pressed
    @IBAction func CountryBtn_pressed(_ sender: Any) {
        
//        let selectionMenu =  RSSelectionMenu(dataSource: countries) { (cell, object, indexPath) in
//            cell.textLabel?.text = "\(self.countries[indexPath.row])"
//            cell.textLabel?.textColor = .black
//            cell.textLabel?.textAlignment = .center
//        }
//
//        selectionMenu.setSelectedItems(items: [self.CountryBtn.title(for: .normal) ?? ""]) {
//            (item, index, isSelected, selectedItems)  in
//
//            self.CountryBtn.setTitle(item, for: .normal)
//            self.CountryBtn.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
//            self.ChosenCountryID = "\(self.countriesList.data?[index].id ?? Int())"
//            self.chosenPhoneCode = self.countriesList.data?[index].phone_code ?? ""
//            self.GetCities()
//
//
//        }
//
//        selectionMenu.show(style: .popover(sourceView: CountryBtn, size: CGSize(width: 220, height: 100)) , from: self)
        
        CityPicker = false
        CountryPickerIndex = 0
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
             PickerActionSheet(title: "Please Select Country")
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar"{
             PickerActionSheet(title: "اختار الدولة")
        }
       
        
    }
    
    
    
    // MARK: - CiyBtn
    @IBAction func CityBtn_pressed(_ sender: Any) {
        
//        let selectionMenu =  RSSelectionMenu(dataSource: cities) { (cell, object, indexPath) in
//            cell.textLabel?.text = "\(self.cities[indexPath.row])"
//            cell.textLabel?.textColor = .black
//            cell.textLabel?.textAlignment = .center
//        }
//
//        selectionMenu.setSelectedItems(items: [self.GovernmentBtn.title(for: .normal) ?? ""]) {
//            (item, index, isSelected, selectedItems)  in
//
//            self.GovernmentBtn.setTitle(item, for: .normal)
//            self.GovernmentBtn.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
//            self.ChosenCityID = "\(self.citiesList.data?[index].id ?? Int())"
//
//        }
//
//        // show as PresentationStyle
//        selectionMenu.show(style: .popover(sourceView: GovernmentBtn, size: CGSize(width: 220, height: 100)) , from: self)

        CityPicker = true
        CityPickerIndex = 0
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            PickerActionSheet(title: "Please Select city")
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar"{
            PickerActionSheet(title: "اختار المدينة")
        }
        
    }
    
    
    
    // MARK: - GetCountriesAPI
    func GetCountries() {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.CountriesList.description, method: .get, Header: [
            "Accept": "application/json",
            "locale": UserDefaults.standard.string(forKey: "Language") ?? "en",
            "timezone": TimeZoneValue.localTimeZoneIdentifier
        ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                HUD.hide()
                do {
                    self.countriesList = try JSONDecoder().decode(Countries.self, from: data!)
                    
                    self.countriesList.data?.forEach({ (country) in
                        if country.country_name != "" {
                            self.countries.append(country.country_name ?? "")
                        }
                    })
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                keyWindow?.rootViewController = vc
                
            }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.GetCountries()
                }
                self.present(vc, animated: true, completion: nil)
            }
            
        }
    }
    
    
    // MARK: - GetCitiesAPI
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
                    self.ChosenCityID = ""
                    self.GovernmentBtn.setTitle("", for: .normal)
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
                keyWindow?.rootViewController = vc
                
            }
            
        }
    }
    
    
    
    
}


// MARK: - TextFieldDelegate
extension SignUpVC : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == UserNameTxtField { EmailTxtField.becomeFirstResponder() }
        else if textField == EmailTxtField { PhoneNumTxtField.becomeFirstResponder() }
        else if textField == PhoneNumTxtField { PasswordTxtField.becomeFirstResponder() }
        else if textField == PasswordTxtField { textField.resignFirstResponder() }
        
        
        return false
    }
}

// MARK: - PickerDelegate

extension SignUpVC : UIPickerViewDataSource , UIPickerViewDelegate {
    
    
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
            self.GovernmentBtn.setTitle(self.citiesList.data?[self.CityPickerIndex].city_name ?? "", for: .normal)
            }else {
                self.ChosenCountryID = "\(self.countriesList.data?[self.CountryPickerIndex].id ?? Int())"
                self.chosenPhoneCode = self.countriesList.data?[self.CountryPickerIndex].phone_code ?? ""
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
