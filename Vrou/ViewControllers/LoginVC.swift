//
//  LoginVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/4/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PKHUD
import MOLH
import LocalAuthentication
import SDWebImage
import FBSDKLoginKit
import AuthenticationServices
import GoogleSignIn
//import InstagramLogin
import StoreKit

class LoginVC: UIViewController, ASAuthorizationControllerDelegate , GIDSignInDelegate{
    
    
    var AdultPickerData = ["Kuwait","Egypt","Oman","Jordon"]
    
    
    // MARK: - IBOutlet
    @IBOutlet weak var UserNameTxtField: UITextField!
    @IBOutlet weak var PasswordTxtField: UITextField!
    @IBOutlet weak var Authview: UIView!
    @IBOutlet weak var LoginView: UIView!
    @IBOutlet var SocialBtns: [UIButton]!
    @IBOutlet weak var loginImage: UIImageView!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var LoginAppleView: UIView!
    @IBOutlet weak var LoginBackground: UIImageView!
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var FingerIDBtn: UIButton!
    
    // MARK: - Variables
    let toArabic = ToArabic()
    var userName = ""
    var pass = ""
    var Continue = false
    var FB_accessToken = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        UserNameTxtField.delegate = self
        PasswordTxtField.delegate = self
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            toArabic.ReverseImage(Image: loginImage)
            toArabic.ReverseImage(Image: arrowImage)
        }
        
        SetImage(image: LoginBackground, link:FirstAdds.login_ads)
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        let c = LAContext()
        var error: NSError?
        if c.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            if c.biometryType != .touchID {
                FingerIDBtn.isHidden = true
            }
        }
        
    }
    
    
    
    @IBAction func InstBtn_pressed(_ sender: Any) {
       
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            
            return
        }else {
            self.SocialLogin(token: user.authentication.accessToken, provider: "google")
        }
    }
    

     // MARK: - ForgetPasswordBtn
    @IBAction func ForgetPassBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ForgerPasswordVC") as! ForgerPasswordVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
      // MARK: - LoginBtn
    @IBAction func LoginBtn_pressed(_ sender: Any) {
        login()
        //rateApp()
    }
    
    func login()  {
        if UserNameTxtField.text == "" || PasswordTxtField.text == "" {
            if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                HUD.flash(.label("Please Enter your email & password") , onView: self.view , delay: 1.5)
                
            }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                HUD.flash(.label("الرجاء ادخال اسم المستخدم و كلمة المرور") , onView: self.view , delay: 1.5)
            }
        }else {
            if isValidEmail(emailStr: UserNameTxtField.text!) {
                userName = UserNameTxtField.text!
                pass = PasswordTxtField.text!
                Login()
                
            }else {
                if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                    HUD.flash(.label("Please Enter a valid email") , onView: self.view , delay: 1.5)
                }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                    HUD.flash(.label("الرجاء ادخال بريد الكتروني صحيح") , onView: self.view , delay: 1.5)
                }
            }
        }
    }
    
    
    
    func isValidEmail(emailStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }
    
    // MARK: - CreateAccountBtn
    @IBAction func CreateAccountBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
      // MARK: - FacebookBtn
    @IBAction func FacebookBtn_pressed(_ sender: Any) {
        self.facebooklogin()
    }
    
    func facebooklogin() {
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["email"], from: self, handler: { (result, error) -> Void in
        
            if (error == nil) {
                if(result?.isCancelled ?? false) {
                    //Show Cancel alert
                } else if(result?.grantedPermissions.contains("email") ?? false) {
                    
                    self.returnUserData()
                }
            }
        })
        
    }
    
    func returnUserData() {
        let graphRequest : GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"email,name"])
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            if ((error) != nil) {
                // Process error
                print("\n\n Error: \(error)")
            } else {
                let resultDic = result as! NSDictionary
                print("\n\n  fetched user: \(result)")
                if (resultDic.value(forKey:"name") != nil) {
                    let userName = resultDic.value(forKey:"name")! as! String as NSString?
                    print("\n User Name is: \(userName)")
                    if let accessToken = AccessToken.current {
                        // User is logged in, use 'accessToken' here.
                        print(accessToken.tokenString)
                        self.FB_accessToken = accessToken.tokenString
                        self.SocialLogin(token: accessToken.tokenString, provider: "facebook")
                    }
                }
                
                if (resultDic.value(forKey:"email") != nil) {
                    let userEmail = resultDic.value(forKey:"email")! as! String as NSString?
                    print("\n User Email is: \(userEmail)")
                }
            }
        })
    }
    
    
    @IBAction func FingerPrintBtn_pressed(_ sender: Any) {
        if KeyChain.load(key: "passKey") != nil  && (UserDefaults.standard.string(forKey: "userNameKey") != nil) {
            authenticateUser()
        }else {
            HUD.flash(.label("Register to VROU to enable TouchID/FaceID next login") , onView: self.view , delay: 1.6 , completion: nil)
        }
        
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage: nil, options: .highPriority , completed: nil)
    }
    
    // MARK: - LoginFunction (not social)
    func Login() {
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.Login.description, method: .post, parameters: ["email": userName , "password" : pass , "device_token": UserDefaults.standard.string(forKey: "FCM_new") ?? "" , "device_id": UIDevice.current.identifierForVendor!.uuidString], encoding: URLEncoding.default, Header: [
            "Accept": "application/json",
            "locale":  UserDefaults.standard.string(forKey: "Language") ?? "en",
            "timezone": TimeZoneValue.localTimeZoneIdentifier
        ], ExtraParams: "", view: self.view) { (data, tmp) in
            HUD.hide()
            if tmp == nil {
                
                User.shared.SaveUser(data: data!)
                if User.shared.fetchUser(){
                    
                    let passwordData = Data(from:self.pass)
                    KeyChain.save(key: "passKey", data: passwordData)
                    FirstAdds.marketPlace = User.shared.data?.user?.marketplace ?? "0"
                    
                    UserDefaults.standard.set(self.userName, forKey: "userNameKey")
                    UserDefaults.standard.set(User.shared.data?.user?.locale, forKey: "Language")
                    MOLH.setLanguageTo(User.shared.data?.user?.locale ?? "en")
                    MOLH.reset()
                    
                    if !self.Continue {
                        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "BeautyWorldNavController") as! BeautyWorldNavController
                        User.shared.SaveToken(data: User.shared.data?.token! ?? "")
                        User.shared.SaveHashID(data: User.shared.data?.user_hash_id! ?? "")
                        UIApplication.shared.keyWindow?.rootViewController = vc
                    }else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }    else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
                UIApplication.shared.keyWindow?.rootViewController = vc
                
            }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.Login()
                }
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    
    
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?
       
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)  {
            let reason = "Login with your FingerID"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] success, authenticationError in
                
                DispatchQueue.main.async {
                    if success {
                        //self.runSecretCode()
                        if let PassData = KeyChain.load(key: "passKey") {
                            self.pass = PassData.to(type: String.self)
                            self.userName = UserDefaults.standard.string(forKey: "userNameKey") ?? ""
                            self.Login()
                        }
                        
                        // self.loadp
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: "Sorry!", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                }
            }
        } else {
            
            let ac = UIAlertController(title: "Touch ID not available", message: "Your device is not configured for Touch ID.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
      // MARK: - SocialLoginFunction
    func SocialLogin(token:String , provider:String) {
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.SocialLogin.description, method: .post, parameters: ["provider": provider , "access_token" : token], encoding: URLEncoding.default, Header: [
            "Accept": "application/json",
            "locale":  UserDefaults.standard.string(forKey: "Language") ?? "en",
            "timezone": TimeZoneValue.localTimeZoneIdentifier
        ], ExtraParams: "", view: self.view) { (data, tmp) in
            HUD.hide()
            if tmp == nil {
                
                User.shared.SaveUser(data: data!)
                
                if User.shared.fetchUser(){
                    
                    let passwordData = Data(from:self.pass)
                    UserDefaults.standard.set(User.shared.data?.user?.locale, forKey: "Language")
                    User.shared.SaveToken(data: User.shared.data?.token! ?? "")
                    User.shared.SaveHashID(data: User.shared.data?.user_hash_id! ?? "")
                    let nulls = ["0" , nil , ""]
                    FirstAdds.marketPlace = User.shared.data?.user?.marketplace ?? "0"
                    let u = User.shared.data?.user
                    if  nulls.contains(u?.phone) || nulls.contains(u?.country_id) || nulls.contains(u?.city_id) {
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditAccountVC") as! EditAccountVC
                        
                        vc.SocialLogin = true
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }else {
                        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "BeautyWorldNavController") as! BeautyWorldNavController
                        UIApplication.shared.keyWindow?.rootViewController = vc
                    }
                }
            }    else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
                UIApplication.shared.keyWindow?.rootViewController = vc
                
            }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.Login()
                }
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    
    
    
}

  // MARK: - WebView delegate
extension LoginVC : UIWebViewDelegate , WKNavigationDelegate {
    
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request:URLRequest, navigationType: UIWebView.NavigationType) -> Bool{
        
        return checkRequestForCallbackURL(request: request)
    }
    
    func checkRequestForCallbackURL(request: URLRequest) -> Bool {
        let requestURLString = (request.url?.absoluteString)! as String
        if requestURLString.hasPrefix(Instagram_API.INSTAGRAM_REDIRECT_URI) {
            let range: Range<String.Index> = requestURLString.range(of: "#access_token=")!
            handleAuth(authToken: requestURLString.substring(from: range.upperBound))
            return false;
        }
        return true
    }
    
    func handleAuth(authToken: String) {
        print("Instagram authentication token ==", authToken)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void)
    {
        if(navigationAction.navigationType == .other)
        {
            if navigationAction.request.url != nil
            {
                //do what you need with url
                //self.delegate?.openURL(url: navigationAction.request.url!)
            }
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    
}

  // MARK: - TextField delegate
extension LoginVC : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == UserNameTxtField{
            PasswordTxtField.becomeFirstResponder()
            print("1")
        }else{
            textField.resignFirstResponder()
            login()
            print("2")
        }
        return false
    }
    
    func rateApp(){
        SKStoreReviewController.requestReview()
    }

}

