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
import FBSDKCoreKit
import FBSDKLoginKit
import AuthenticationServices
import GoogleSignIn
import StoreKit

class LoginVC: BaseVC<BasePresenter, BaseItem>, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding{
    
    
    var AdultPickerData = ["Kuwait","Egypt","Oman","Jordon"]
    
    
    // MARK: - IBOutlet
    @IBOutlet weak var UserNameTxtField: UITextField!
    @IBOutlet weak var PasswordTxtField: UITextField!
    @IBOutlet weak var trueEmailImage: UIImageView!
    @IBOutlet weak var LoginBackground: UIImageView!
  //  @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var LoginWith_FaceTouch: UIButton!
    @IBOutlet weak var forgetPassBtn: UIButton!
    @IBOutlet weak var forgetPassBtn_height: NSLayoutConstraint!
    @IBOutlet weak var createNowBtn: UIButton!
    @IBOutlet weak var showBtn: UIButton!
    @IBOutlet weak var emailErrorBtn: UIButton!
    @IBOutlet weak var emailErrorBtn_height: NSLayoutConstraint!
    @IBOutlet weak var forgetYourPasswordBtn: UIButton!
    
    @IBOutlet weak var or_img: UIImageView!
    @IBOutlet weak var fb_img: UIImageView!
    @IBOutlet weak var google_img: UIImageView!
    @IBOutlet weak var loginProviderStackView: UIStackView!
    
    
    // MARK: - Variables
    let toArabic = ToArabic()
    var userName = ""
    var pass = ""
    var Continue = false
    var FB_accessToken = ""
    var IsScurePassTxtField = true

  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        setTransparentNavagtionBar()
        
        UserNameTxtField.delegate = self
        PasswordTxtField.delegate = self
        forgetPassBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        forgetPassBtn.titleLabel?.minimumScaleFactor = 0.5
        
        CheckArabic()
        
        SetImage(image: LoginBackground, link:FirstAdds.login_ads)
        
        AddBlurEffect(view: LoginBackground)

        let c = LAContext()
        var error: NSError?
        if c.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            if c.biometryType != .touchID {
                LoginWith_FaceTouch.setTitle("LOGIN WITH FACE ID".ar(), for: .normal)
            }
        }
        
        
        if #available(iOS 13.0, *) {
            addSignInWithAppleBtn()
            performExistingAccountSetupFlows()

            // Continue implement with : https://developerinsider.co/ios-13-how-to-integrate-sign-in-with-apple-in-your-application/
            // From #9
        }
        
    }
    
 
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setCustomNavagationBar()
    }
        
    func CheckArabic() {
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
               toArabic.ReverseButtonAlignment(Button: createNowBtn)

               or_img.image = #imageLiteral(resourceName: "or_ar_icon")
               fb_img.image = #imageLiteral(resourceName: "fb_ar_icon")
               google_img.image = #imageLiteral(resourceName: "google_ar_icon")
               
               UserNameTxtField.textAlignment = .right
               PasswordTxtField.textAlignment = .right
               forgetPassBtn.contentHorizontalAlignment = .right
               emailErrorBtn.contentHorizontalAlignment = .right
               forgetYourPasswordBtn.contentHorizontalAlignment = .left
               
           }else {
               UserNameTxtField.textAlignment = .left
               PasswordTxtField.textAlignment = .left
               forgetPassBtn.contentHorizontalAlignment = .left
               emailErrorBtn.contentHorizontalAlignment = .left
               forgetYourPasswordBtn.contentHorizontalAlignment = .right
           }
    }
    
    @IBAction func LoginFaceTouchBtn_pressed(_ sender: Any) {
        if KeyChain.load(key: "passKey") != nil  && (UserDefaults.standard.string(forKey: "userNameKey") != nil) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "FaceTouchLoginVC") as! FaceTouchLoginVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            HUD.flash(.label("Register to VROU to enable TouchID/FaceID next login".ar()) , onView: self.view , delay: 1.6 , completion: nil)
        }
    }
    
    
    @IBAction func ShowBtn_pressed(_ sender: Any) {
        var title = ""
        IsScurePassTxtField = !IsScurePassTxtField
        PasswordTxtField.isSecureTextEntry = IsScurePassTxtField
        title = IsScurePassTxtField ? "SHOW".ar() : "HIDE".ar()
        showBtn.setTitle(title, for: .normal)
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
            if UserNameTxtField.text == "" {
                EmailFieldError(message: "Required Field".ar())
               
            }
            
            if PasswordTxtField.text == "" {
                PasswordFieldError(message: "Required Field".ar())
            }
            
        }else {
            if isValidEmail(emailStr: UserNameTxtField.text!) {
                
                if PasswordTxtField.text?.count ?? 0 >= 8{
                    userName = UserNameTxtField.text!
                    pass = PasswordTxtField.text!
                    Login()
                }else {
                    PasswordFieldError(message: "Password must be at least 8 characters".ar())
                }
            }else {
                EmailFieldError(message: "Please Enter valid email".ar())
            }
        }
    }
    
    func AddBlurEffect(view:UIView) {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.4
        view.addSubview(blurEffectView)
    }
    
    
    func isValidEmail(emailStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }
    
    // MARK: - EmailFieldError
    func EmailFieldError(message:String) {
        emailErrorBtn.setTitle(message, for: .normal)
        emailErrorBtn_height.constant = 15
        self.UserNameTxtField.endEditing(true)
    }
    
    // MARK: - EmailFieldError
    func PasswordFieldError(message:String) {
        forgetPassBtn.setTitle(message, for: .normal)
        forgetPassBtn_height.constant = 15
        self.PasswordTxtField.endEditing(true)
    }
    
    // MARK: - CreateAccountBtn
    @IBAction func CreateAccountBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
      // MARK: - GoogleBtn
    @IBAction func GoogleBtn_pressed(_ sender: Any) {
        GIDSignIn.sharedInstance.signOut()        
        let signInConfig = GIDConfiguration(clientID: GoogleClientID)
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }
            guard let signInResult = signInResult else { return }
            let user = signInResult.user
            let accessToken = user.accessToken.tokenString
            self.SocialLogin(token: accessToken, provider: "google")
        }
    }
    
    
      // MARK: - FacebookBtn
    @IBAction func FacebookBtn_pressed(_ sender: Any) {
        self.facebooklogin()
    }
    
    func facebooklogin() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["email"], from: self, handler: { (result, error) -> Void in

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
        let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"email,name"])

        graphRequest.start { (connection, result, error) in
            if let error = error {
                print("\n\n Error: \(error)")
            } else {
                let resultDic = result as! NSDictionary
                print("\n\n  fetched user: \(result)")
                if (resultDic.value(forKey:"name") != nil) {
                    let userName = resultDic.value(forKey:"name")! as! String as NSString?
                    print("\n User Name is: \(userName)")
                    if let accessToken = AccessToken.current, !accessToken.isExpired {
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
        }
    }
    
    
    @IBAction func FingerPrintBtn_pressed(_ sender: Any) {
        if KeyChain.load(key: "passKey") != nil  && (UserDefaults.standard.string(forKey: "userNameKey") != nil) {
            authenticateUser()
        }else {
            HUD.flash(.label("Register to VROU to enable TouchID/FaceID next login".ar()) , onView: self.view , delay: 1.6 , completion: nil)
        }
        
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage: nil, options: .highPriority , completed: nil)
    }
    
    // MARK: - LoginFunction (not social)
    func Login() {
        HUD.flash(.progress)
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
                        User.shared.SaveToken(data: User.shared.data?.token! ?? "")
                        User.shared.SaveHashID(data: User.shared.data?.user_hash_id! ?? "")
                        self.goToHome()
                    }else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }else if tmp == "401" {
                do {
                    let er = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                    self.forgetPassBtn.setTitle( "\(er.msg?[0] ?? "")", for: .normal)
                    self.forgetPassBtn_height.constant = 15
                    self.PasswordTxtField.endEditing(true)
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later"), delay: 2 , completion: nil)
                }
                
            }else if tmp == "402" {
                do {
                    let er = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                    self.emailErrorBtn.setTitle( "\(er.msg?[0] ?? "")", for: .normal)
                    self.emailErrorBtn_height.constant = 15
                    self.PasswordTxtField.endEditing(true)
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later"), delay: 2 , completion: nil)
                }
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
                        self.goToHome()
                    }
                }
            }    else if tmp == "401" {
                let vc = UIStoryboard(name: "Master", bundle: nil).instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
                let vcc = UINavigationController(rootViewController: vc)
                keyWindow?.rootViewController = vcc

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
        }else{
            textField.resignFirstResponder()
            login()
            print("2")
        }
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == UserNameTxtField {
            trueEmailImage.isHidden = true
            emailErrorBtn_height.constant = 5
            emailErrorBtn.setTitle("", for: .normal)
        }
        
        if textField == PasswordTxtField {
            forgetPassBtn_height.constant = 5
            forgetPassBtn.setTitle("", for: .normal)
        }
        
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == UserNameTxtField {
            
            if isValidEmail(emailStr: UserNameTxtField.text!) {
                trueEmailImage.image = #imageLiteral(resourceName: "true")
            }else {
                trueEmailImage.image = #imageLiteral(resourceName: "false")
            }
            
            trueEmailImage.isHidden = false
        }
        
    }
    
    func rateApp(){
        SKStoreReviewController.requestReview()
    }

}

extension LoginVC {
    
    func addSignInWithAppleBtn() {
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleLogInWithAppleIDButtonPress), for: .touchUpInside)
        loginProviderStackView.addArrangedSubview(authorizationButton)
    }
    
    @objc private func handleLogInWithAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
         return self.view.window!
    }
    
    private func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(), ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        //Handle error here
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            // Create an account in your system.
//            let userIdentifier = appleIDCredential.user
//            let userFirstName = appleIDCredential.fullName?.givenName
//            let userLastName = appleIDCredential.fullName?.familyName
//            let userEmail = appleIDCredential.email
            let token = appleIDCredential.authorizationCode
            
            if let tokenEncoded = token?.base64EncodedString() {
                self.SocialLogin(token: tokenEncoded, provider: "apple")
            }
        }
    }
}
