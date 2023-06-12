//
//  EditAccountVC.swift
//  Vrou
//
//  Created by Mac on 10/28/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PKHUD
import RSSelectionMenu
import SDWebImage
import SideMenu
import MOLH

class EditAccountVC: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var CountryBtn: UIButton!
    @IBOutlet weak var cityBtn: UIButton!
    @IBOutlet weak var homeAddress: UITextField!
    @IBOutlet weak var mobile: UITextField!
    @IBOutlet weak var email: UITextField!
    
    // MARK: - Variables
    var countryID = ""
    var cityID = ""
    var countries = [String]()
    var cities = [String]()
    var countriesList = Countries()
    var citiesList = Cities()
    let imagePicker = UIImagePickerController()
    var dataImage = [Data]()
    var params = [String: Any]()
    var changeProfilePicture = false
    var SocialLogin = false
    var CityPicker = false
    var CountryPickerIndex = 0
    var CityPickerIndex = 0
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        if User.shared.data?.user?.image ?? "" != "" {
            SetImage(image: profileImage, link: User.shared.data?.user?.image ?? "")
        }
        
        firstName.text = User.shared.data?.user?.first_name ?? ""
        lastName.text = User.shared.data?.user?.last_name ?? ""
        userName.text = User.shared.data?.user?.name ?? ""
        CountryBtn.setTitle(User.shared.data?.user?.country?.country_name ?? "", for: .normal)
        cityBtn.setTitle(User.shared.data?.user?.city?.city_name ?? "", for: .normal)
        
        countryID = "\(User.shared.data?.user?.country?.id ?? 0)"
        cityID = "\(User.shared.data?.user?.city?.id ?? 0)"
        homeAddress.text = User.shared.data?.user?.address ?? ""
        mobile.text = User.shared.data?.user?.phone ?? ""
        email.text = User.shared.data?.user?.email ?? ""
        
        if  User.shared.data?.user?.email ?? "" != "" {
            email.isEnabled = false
        }
        
        GetCountries()
        
    }
    
    
    // MARK: - ImagePickerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            dataImage = [pickedImage.pngData()!]
            profileImage.image = pickedImage
        }
        
        changeProfilePicture = true
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - UpdateImageBtn
    @IBAction func UpdateImageBtn_pressed(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - CountryBtn
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
//            self.countryID = "\(self.countriesList.data?[index].id ?? Int())"
//            self.cityBtn.setTitle("", for: .normal)
//            self.cityID = ""
//            self.GetCities()
//
//        }
//
//        // show as PresentationStyle = Push
        //        selectionMenu.show(style: .popover(sourceView: CountryBtn, size: CGSize(width: 220, height: 100)) , from: self)
        
        CityPicker = false
        CountryPickerIndex = 0
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            PickerActionSheet(title: "Please Select Country")
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar"{
            PickerActionSheet(title: "اختار الدولة")
        }
        
    }
    
    
    // MARK: - CityBtn
    @IBAction func CityBtn_pressed(_ sender: Any) {
//        let selectionMenu =  RSSelectionMenu(dataSource: cities) { (cell, object, indexPath) in
//            cell.textLabel?.text = "\(self.cities[indexPath.row])"
//            cell.textLabel?.textColor = .black
//            cell.textLabel?.textAlignment = .center
//        }
//
//        selectionMenu.setSelectedItems(items: [self.cityBtn.title(for: .normal) ?? ""]) {
//            (item, index, isSelected, selectedItems)  in
//
//            self.cityBtn.setTitle(item, for: .normal)
//            self.cityBtn.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
//            self.cityID = "\(self.citiesList.data?[index].id ?? Int())"
//
//        }
//
//        // show as PresentationStyle = Push
        //        selectionMenu.show(style: .popover(sourceView: cityBtn, size: CGSize(width: 220, height: 100)) , from: self)
        
        CityPicker = true
        CityPickerIndex = 0
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            PickerActionSheet(title: "Please Select city")
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar"{
            PickerActionSheet(title: "اختار المدينة")
        }
    }
    
    // MARK: - SaveBtn
    @IBAction func SaveBtn_pressed(_ sender: Any) {
        
        let e =  email.text!
        let m =  mobile.text!
        
        if changeProfilePicture {
            UpdateProfileWithImage(url: ApiManager.Apis.updateProfile.description)
        }else {
            if SocialLogin {
                
                
                if countryID == "0" || cityID == "0" || e == "" || m == "" {
                    if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                        HUD.flash(.label("Please fill all fields") , onView: self.view , delay: 2 , completion: nil)
                    }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                        HUD.flash(.label("برجاء ادخال البيانات المطلوبة") , onView: self.view , delay: 2 , completion: nil)
                    }
                }else {
                    UpdateProfile()
                }
            }else {
                if firstName.text == User.shared.data?.user?.first_name ?? "" &&
                    lastName.text == User.shared.data?.user?.last_name ?? "" &&
                    userName.text == User.shared.data?.user?.name ?? "" &&
                    countryID == "\(User.shared.data?.user?.country?.id ?? Int())" &&
                    cityID == "\(User.shared.data?.user?.city?.id ?? Int())" &&
                    homeAddress.text == User.shared.data?.user?.address ?? "" &&
                    mobile.text == User.shared.data?.user?.phone ?? "" && email.text == User.shared.data?.user?.email ?? "" {
                    
                    if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                        HUD.flash(.label("No changes in profile") , onView: self.view , delay: 2 , completion: nil)
                    }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                        HUD.flash(.label("لا يوجد تعديل في الملف الشخصي") , onView: self.view , delay: 2 , completion: nil)
                    }
                }else if  countryID == "0" || cityID == "0" || e == "" || m == "" {
                    if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                        HUD.flash(.label("Please fill all fields") , onView: self.view , delay: 2 , completion: nil)
                    }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                        HUD.flash(.label("برجاء ادخال البيانات المطلوبة") , onView: self.view , delay: 2 , completion: nil)
                    }
                }else {
                    UpdateProfile()
                }
            }
            
        }
        
    }
    
}


extension EditAccountVC {
    
    // MARK: - GetCountries_API

    func GetCountries() {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.CountriesList.description, method: .get, Header: [
            "Accept": "application/json",
            "locale": UserDefaults.standard.string(forKey: "Language") ?? "en", "timezone": TimeZoneValue.localTimeZoneIdentifier
        ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                do {
                    self.countriesList = try JSONDecoder().decode(Countries.self, from: data!)
                    self.countriesList.data?.forEach({ (country) in
                        if country.country_name != "" {
                            self.countries.append(country.country_name ?? "")
                        }
                    })
                    HUD.hide()
                    if !self.SocialLogin {
                        self.GetCities()
                    }
                    
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
        ApiManager.shared.ApiRequest(URL: "\(ApiManager.Apis.CitiesList.description)\(countryID)", method: .get, Header: [
            "Accept": "application/json",
            "locale": UserDefaults.standard.string(forKey: "Language") ?? "en", "timezone": TimeZoneValue.localTimeZoneIdentifier
        ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                HUD.hide()
                do {
                    self.citiesList = try JSONDecoder().decode(Cities.self, from: data!)
                    self.cities.removeAll()
                    
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
    
    // MARK: - UpdateProfile_API
    func UpdateProfile() {
        let param = ["first_name":firstName.text! , "last_name": lastName.text! , "user_name": userName.text! , "country_id": countryID , "city_id" : cityID , "address": homeAddress.text ?? "" , "phone":mobile.text! , "email":email.text!]
        
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.updateProfile.description, method: .post, parameters: param ,encoding: URLEncoding.default, Header:["Authorization": "Bearer \(User.shared.TakeToken())", "Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view) { (data, tmp) in
            if tmp == nil {
                HUD.hide()
                do {
                    User.shared.removeUser()
                    User.shared.SaveUser(data: data!)
                   
                    if User.shared.fetchUser() {
                         FirstAdds.marketPlace = User.shared.data?.user?.marketplace ?? "0"
                        if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                            HUD.flash(.label("Profile is Updated Successfully") , onView: self.view , delay: 2 , completion: {
                                tmp in
                                if self.SocialLogin {
                                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WelcomeBeautyVC") as! WelcomeBeautyVC
                                    UIApplication.shared.keyWindow?.rootViewController = vc
                                }else {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            })
                        }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                            HUD.flash(.label("تم تعديل الملف الشخصي بنجاح") , onView: self.view , delay: 2 , completion: {
                                tmp in
                                if self.SocialLogin {
                                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WelcomeBeautyVC") as! WelcomeBeautyVC
                                    UIApplication.shared.keyWindow?.rootViewController = vc
                                }else {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            })
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
    
    
    
      // MARK: - UpdateProfile&Image_API
    func UpdateProfileWithImage(url:String){
        
        let tokn = User.shared.TakeToken()
        params = ["first_name":firstName.text! , "last_name": lastName.text! , "user_name": userName.text! , "country_id": countryID , "city_id" : cityID , "address": homeAddress.text ?? "" , "phone":mobile.text! , "image": ""]
        
        
        if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            HUD.show(.label("Uploading image ..."), onView: self.view)
            
        }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            HUD.show(.label("جاري رفع الصورة"), onView: self.view)
        }
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in self.params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            for i in self.dataImage{
                multipartFormData.append(i, withName: "image", fileName: "image.png", mimeType: "image/png")
            }
            //  }
            
        }, usingThreshold: UInt64.init(), to: url, method: .post , headers : ["Authorization" : "Bearer " + tokn] ) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if (response.response?.statusCode ?? 404) < 300{ //
                        User.shared.removeUser()
                        User.shared.SaveUser(data: response.data!)
                        if User.shared.fetchUser() {
                             FirstAdds.marketPlace = User.shared.data?.user?.marketplace ?? "0"
                            if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                                HUD.flash(.label("Profile is Updated Successfully") , onView: self.view , delay: 2 , completion: {
                                    tmp in
                                    if self.SocialLogin {
                                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WelcomeBeautyVC") as! WelcomeBeautyVC
                                        User.shared.SaveToken(data: User.shared.data?.token! ?? "")
                                        User.shared.SaveHashID(data: User.shared.data?.user_hash_id! ?? "")
                                        UIApplication.shared.keyWindow?.rootViewController = vc
                                    }else {
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                    
                                })
                            }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                                HUD.flash(.label("تم تعديل الملف الشخصي بنجاح") , onView: self.view , delay: 2 , completion: {
                                    tmp in
                                    if self.SocialLogin {
                                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WelcomeBeautyVC") as! WelcomeBeautyVC
                                        User.shared.SaveToken(data: User.shared.data?.token! ?? "")
                                        User.shared.SaveHashID(data: User.shared.data?.user_hash_id! ?? "")
                                        UIApplication.shared.keyWindow?.rootViewController = vc
                                    }else {
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                })
                            }
                        }
                        print(response.data!)
                        self.changeProfilePicture = false
                        
                    }else{
                        do {
                            let temp = try JSONDecoder().decode(ErrorMsg.self, from: response.data!)
                            HUD.flash(.labeledError(title: "حدث خطأ", subtitle: nil), onView: self.view, delay: 1.0, completion: nil)
                            HUD.hide()
                        }catch{
                            HUD.flash(.labeledError(title: "حدث خطأ", subtitle: nil), onView: self.view, delay: 1.0, completion: nil)
                        }
                    }
                    
                    if let err = response.error{
                        HUD.hide()
                        HUD.flash(.labeledError(title: "حدث خطأ", subtitle: nil), onView: self.view, delay: 1.0, completion: nil)
                        print(err)
                        return
                    }
                    
                }
            case .failure(let error):
                HUD.flash(.labeledError(title: "حدث خطأ في رفع الصور", subtitle: nil), onView: self.view, delay: 1.0, completion: nil)
                print("Error in upload: \(error.localizedDescription)")
                
            }
        }
        
    }
    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage:UIImage(), options: .highPriority , completed: nil)
    }
    
}

// MARK: - PickerDelegate
extension EditAccountVC : UIPickerViewDataSource , UIPickerViewDelegate {
    
    
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
                self.cityBtn.setTitle(self.citiesList.data?[self.CityPickerIndex].city_name ?? "", for: .normal)
                self.cityID = "\(self.citiesList.data?[self.CityPickerIndex].id ?? Int())"
            }else {
            self.countryID = "\(self.countriesList.data?[self.CountryPickerIndex].id ?? Int())"
            self.cityBtn.setTitle("", for: .normal)
            self.cityID = ""
            self.GetCities()
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
