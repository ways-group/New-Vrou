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
import FirebaseAuth

struct SignUpData {
    public static var params = [String:String]()
}



class SignUpVC: UIViewController{
    
    // MARK: - IBOutlet
    @IBOutlet weak var UserNameTxtField: UITextField!
    @IBOutlet weak var EmailTxtField   : UITextField!
    @IBOutlet weak var PhoneNumTxtField: UITextField!
    @IBOutlet weak var PasswordTxtField: UITextField!
    @IBOutlet weak var GovernmentBtn: UIButton!
    @IBOutlet weak var signUpBackground: UIImageView!
    @IBOutlet weak var countryFlagBtn: UIButton!
    @IBOutlet weak var trueEmailImage: UIImageView!
    @IBOutlet weak var errorMsgBtn: UIButton!
    @IBOutlet weak var errorMsgBtn_hieght: NSLayoutConstraint!
    @IBOutlet weak var flagIconImage: UIImageView!
    @IBOutlet weak var showBtn: UIButton!
    
    
    @IBOutlet weak var userNameErrorBtn: UIButton!
    @IBOutlet weak var userNameErrorBtn_height: NSLayoutConstraint!
    @IBOutlet weak var emailErrorBtn: UIButton!
    @IBOutlet weak var emailErrorBtn_height: NSLayoutConstraint!
    @IBOutlet weak var phoneErrorBtn: UIButton!
    @IBOutlet weak var phoneErrorBtn_height: NSLayoutConstraint!
    
    @IBOutlet weak var cityErrorBtn: UIButton!
    @IBOutlet weak var cityErrorBtn_height: NSLayoutConstraint!
    
    @IBOutlet weak var loginBtn: UIButton!
    
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
    
    var IsScurePassTxtField = true
    var phoneLength = 0
    var phoneMinLength = 0
        
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SetImage(image: signUpBackground, link: FirstAdds.register_ads)
        signUpBackground.AddBlurEffect(blueEffectStrength: 0.4)
        errorMsgBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        errorMsgBtn.titleLabel?.minimumScaleFactor = 0.5
        PhoneNumTxtField.keyboardType = .asciiCapableNumberPad
        
        CheckArabic()
        
        //TxtField delgates
        UserNameTxtField.delegate = self
        EmailTxtField   .delegate = self
        PhoneNumTxtField.delegate = self
        PasswordTxtField.delegate = self
        
        GetCountries()
        setTransparentNavagtionBar()
        GovernmentBtn.setTitle("City".ar(), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTransparentNavagtionBar()
    }
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage: nil, options: .highPriority , completed: nil)
    }
    
    
    func CheckArabic() {
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            UserNameTxtField.textAlignment = .right
            PasswordTxtField.textAlignment = .right
            EmailTxtField.textAlignment = .right
            PhoneNumTxtField.textAlignment = .right
            GovernmentBtn.contentHorizontalAlignment = .right
            
            emailErrorBtn.contentHorizontalAlignment = .right
            errorMsgBtn.contentHorizontalAlignment = .right
            userNameErrorBtn.contentHorizontalAlignment = .right
            phoneErrorBtn.contentHorizontalAlignment = .right
            cityErrorBtn.contentHorizontalAlignment = .right
            loginBtn.contentHorizontalAlignment = .right
            
        }else {
            UserNameTxtField.textAlignment = .left
            PasswordTxtField.textAlignment = .left
            EmailTxtField.textAlignment = .left
            PhoneNumTxtField.textAlignment = .left
            GovernmentBtn.contentHorizontalAlignment = .left
            
            emailErrorBtn.contentHorizontalAlignment = .left
            errorMsgBtn.contentHorizontalAlignment = .left
            userNameErrorBtn.contentHorizontalAlignment = .left
            phoneErrorBtn.contentHorizontalAlignment = .left
            cityErrorBtn.contentHorizontalAlignment = .left
            loginBtn.contentHorizontalAlignment = .left
        }
    }
    
    func isValidEmail(emailStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }
    
    func isValidPhoneNumber() -> Bool {
        
        if chosenPhoneCode == "+20" {
            if PhoneNumTxtField.text?.count == 11 && PhoneNumTxtField.text?.first == "0"{
                return true
            }
        }
        
        if PhoneNumTxtField.text?.count ?? 0 != phoneMinLength {
            return false
        }else {
            return true
        }
        
    }
    
    // MARK: - TxtFieldError
    func TxtFieldError(txtField:UITextField ,Button:UIButton, message:String,constraint:NSLayoutConstraint) {
           Button.setTitle(message, for: .normal)
           constraint.constant = 15
           txtField.endEditing(true)
       }
    
    
    @IBAction func showPassBtn_pressed(_ sender: Any) {
       var title = ""
        IsScurePassTxtField = !IsScurePassTxtField
        PasswordTxtField.isSecureTextEntry = IsScurePassTxtField
        title = IsScurePassTxtField ? "SHOW".ar() : "HIDE".ar()
        showBtn.setTitle(title, for: .normal)
    }
    
    // MARK: - NextBtn
    @IBAction func NextBtn_pressed(_ sender: Any) {
        
        if UserNameTxtField.text == "" || EmailTxtField.text == "" || GovernmentBtn.currentTitle == "City".ar() || GovernmentBtn.currentTitle == "" || PhoneNumTxtField.text == "" || PasswordTxtField.text == "" {
            
            if EmailTxtField.text == "" {
                TxtFieldError(txtField: EmailTxtField, Button: emailErrorBtn, message: "Required Field".ar(), constraint: emailErrorBtn_height)
            }
            
            if UserNameTxtField.text == "" {
                TxtFieldError(txtField: UserNameTxtField, Button: userNameErrorBtn, message: "Required Field".ar(), constraint: userNameErrorBtn_height)
            }
            
            if GovernmentBtn.currentTitle == "City".ar() {
                cityErrorBtn.setTitle("Required Field".ar(), for: .normal)
                cityErrorBtn_height.constant = 15
            }
            
            if PhoneNumTxtField.text == "" {
                TxtFieldError(txtField: PhoneNumTxtField, Button: phoneErrorBtn, message: "Required Field".ar(), constraint: phoneErrorBtn_height)
            }
            
            if PasswordTxtField.text == "" {
                TxtFieldError(txtField: PasswordTxtField, Button: errorMsgBtn, message: "Required Field".ar(), constraint: errorMsgBtn_hieght)
            }
            
        }else if PasswordTxtField.text?.count ?? 0 < 8 {
            errorMsgBtn_hieght.constant = 15
            errorMsgBtn.setTitle("\(NSLocalizedString("Password length must be at least 8".ar(), comment: ""))", for: .normal)
        }else if !isValidPhoneNumber() {
            phoneErrorBtn.setTitle("\(NSLocalizedString("Phone number length must be".ar(), comment: "")) \(phoneMinLength)", for: .normal)
             phoneErrorBtn_height.constant = 15
            
        }else {
            CheckemailExist()
        }
    }
    
    func CheckemailExist() {
        HUD.show(.progress , onView: view)
        
        let FinalURL = "\(ApiManager.Apis.CheckEmailExist.description)"
        var params = [String():String()]
        
        params = ["email": EmailTxtField.text!, "phone":"\(chosenPhoneCode)\(PhoneNumTxtField.text!)" ]
        
        if chosenPhoneCode == "+20" {
            if PhoneNumTxtField.text?.count == 11 && PhoneNumTxtField.text?.first == "0"{
                params["phone"] = "+2\(PhoneNumTxtField.text!)"
            }
        }
        
        
        var emailExist = false
        
        ApiManager.shared.ApiRequest(URL: FinalURL, method: .post, parameters: params ,encoding: URLEncoding.default, Header:["Accept": "application/json" , "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view)  { (data, tmp) in
            
            if tmp == nil {
                HUD.hide()
                do {
                  
                    let decoded_data = try JSONDecoder().decode(CheckEmailPhone.self, from: data!)
                   
                    
                    if (decoded_data.data?.email_status ?? false) {
                        self.TxtFieldError(txtField: self.EmailTxtField, Button: self.emailErrorBtn, message: "\(NSLocalizedString("Email is Already exist".ar(), comment: ""))", constraint: self.emailErrorBtn_height)
                    }
                    
                    if (decoded_data.data?.phone_status ?? false) {
                        self.TxtFieldError(txtField: self.PhoneNumTxtField, Button: self.phoneErrorBtn, message: "\(NSLocalizedString("Phone is Already exist".ar(), comment: ""))", constraint: self.phoneErrorBtn_height)
                    }
                    
                    if !(decoded_data.data?.email_status ?? false) && !(decoded_data.data?.phone_status ?? false) {
                        self.EmailExistDone()
                    }

                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }
        }
        
       
    }
    
   
    func EmailExistDone() {
        if isValidEmail(emailStr: EmailTxtField.text!) {
            SignUpData.params =  ["name":UserNameTxtField.text!, "email":EmailTxtField.text! , "password":PasswordTxtField.text! , "phone":"\(chosenPhoneCode)\(PhoneNumTxtField.text!)" , "country_id":ChosenCountryID , "city_id":ChosenCityID , "locale":"en" , "device_token": UserDefaults.standard.string(forKey: "FCM_new") ?? "" , "device_id": UIDevice.current.identifierForVendor!.uuidString]
            
            if chosenPhoneCode == "+20" {
                if PhoneNumTxtField.text?.count == 11 && PhoneNumTxtField.text?.first == "0"{
                   SignUpData.params["phone"] = "+2\(PhoneNumTxtField.text!)"
                }
            }

            
            SendPhoneNumber()
            
        }else {
           self.TxtFieldError(txtField: self.EmailTxtField, Button: self.emailErrorBtn, message: "\(NSLocalizedString("Please enter a valid email", comment: ""))", constraint: self.emailErrorBtn_height)
        }
    }
    
    
    func SendPhoneNumber() {
        Auth.auth().languageCode = UserDefaults.standard.string(forKey: "Language") ?? "en"
        PhoneAuthProvider.provider().verifyPhoneNumber(chosenPhoneCode + PhoneNumTxtField.text!, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                HUD.flash(.labeledError(title: "حدث خطأ", subtitle: error.localizedDescription), onView: self.view, delay: 1.0, completion: nil)
                
                return
            }
            // Sign in using the verificationID and the code sent to the user
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
          //  UserDefaults.standard.set(self.phonecode + self.mobileTF.text!, forKey: "regPhone")
            
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "SMSAuthVC") as! SMSAuthVC
            self.navigationController?.pushViewController(loginViewController, animated: true)
        }

    }

    
    // MARK: - LoginBtn
    @IBAction func LoginBtn_pressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    // MARK: - CountryBtn_pressed
    @IBAction func CountryBtn_pressed(_ sender: Any) {
        ChosenCityID = ""
        GovernmentBtn.setTitle("\(NSLocalizedString("City", comment: ""))", for: .normal)
        GovernmentBtn.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopUpListVC") as! PopUpListVC
        vc.delegate = self
        vc.countriesList = countriesList
        vc.currentList = .countries
        vc.modalPresentationStyle = .overCurrentContext
        self.view.AddViewBlurEffect(blueEffectStrength: 0.4, tag: 200)
        self.present(vc, animated: true, completion: nil)
    }
    
    
    
    // MARK: - CiyBtn
    @IBAction func CityBtn_pressed(_ sender: Any) {
        if ChosenCountryID != "" {
            cityErrorBtn_height.constant = 5
            cityErrorBtn.setTitle("", for: .normal)
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopUpListVC") as! PopUpListVC
            vc.delegate = self
            vc.citiesList = citiesList
            vc.currentList = .cities
            vc.modalPresentationStyle = .overCurrentContext
            self.view.AddViewBlurEffect(blueEffectStrength: 0.4, tag: 200)
            self.present(vc, animated: true, completion: nil)
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
                    self.ChosenCountryID = "\(self.countriesList.data?[0].id ?? Int())"
                    self.SetImage(image: self.flagIconImage, link: self.countriesList.data?[0].flag_icon ?? "")
                    self.chosenPhoneCode = self.countriesList.data?[0].phone_code ?? ""
                    self.phoneLength = Int(self.countriesList.data?[0].phone_length ?? "0") ?? 0
                    self.phoneMinLength = Int(self.countriesList.data?[0].phone_min_length ?? "0") ?? 0
                    self.GetCities()
                    
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
                    self.GovernmentBtn.setTitle("City".ar(), for: .normal)
                    self.GovernmentBtn.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
//                    self.citiesList.data?.forEach({ (city) in
//                        if city.city_name != "" {
//                            self.cities.append(city.city_name ?? "")
//                        }
//                    })
                    
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
        else if textField == EmailTxtField { PasswordTxtField.becomeFirstResponder() }
        else if textField == PasswordTxtField { PhoneNumTxtField.becomeFirstResponder() }
        else if textField == PhoneNumTxtField { textField.resignFirstResponder() }
        
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField {
        case UserNameTxtField:
            userNameErrorBtn_height.constant = 5
            userNameErrorBtn.setTitle("", for: .normal)
        case EmailTxtField:
            trueEmailImage.isHidden = true
            emailErrorBtn_height.constant = 5
            emailErrorBtn.setTitle("", for: .normal)
        case PasswordTxtField:
            errorMsgBtn_hieght.constant = 5
            errorMsgBtn.setTitle("", for: .normal)
        case PhoneNumTxtField:
            phoneErrorBtn_height.constant = 5
            phoneErrorBtn.setTitle("", for: .normal)
        default:
            return
        }

        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == EmailTxtField {
            
            if isValidEmail(emailStr: EmailTxtField.text!) {
                trueEmailImage.image = #imageLiteral(resourceName: "true")
            }else {
                trueEmailImage.image = #imageLiteral(resourceName: "false")
            }
            
            trueEmailImage.isHidden = false
        }
        
        if textField == PasswordTxtField {
            if textField.text?.count ?? 0 < 8 {
                errorMsgBtn_hieght.constant = 15
                errorMsgBtn.setTitle("\(NSLocalizedString("Password length must be at least 8", comment: ""))", for: .normal)
            }
        }
        
    }
    
    
}

// MARK: - ChooseSignUpPopUp
extension SignUpVC:ChooseSignUpPopUp {
    
    func CloseBtn() {
        self.view.RemoveViewBlurEffect(tag: 200)
    }
    
    func ChooseCountry(id: Int, name: String, icon: String, phoneCode: String, phoneLength: Int, phoneMinLength: Int) {
        self.view.RemoveViewBlurEffect(tag: 200)
        ChosenCountryID = "\(id)"
        SetImage(image: flagIconImage, link: icon)
        chosenPhoneCode = phoneCode
        self.phoneLength = phoneLength
        self.phoneMinLength = phoneMinLength
        GetCities()
    }

    
    func ChooseCity(id:Int, name:String) {
        self.view.RemoveViewBlurEffect(tag: 200)
        ChosenCityID = "\(id)"
        GovernmentBtn.setTitle("\(name)", for: .normal)
        GovernmentBtn.setTitleColor(#colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1), for: .normal)
    }
    
}

