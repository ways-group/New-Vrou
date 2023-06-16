//
//  FaceTouchLoginVC.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/8/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import LocalAuthentication
import Alamofire
import SwiftyJSON
import PKHUD
import MOLH


class FaceTouchLoginVC: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var faceTouchImage: UIImageView!
    
    // MARK: - Variables
    var userName = ""
    var pass = ""
    var reason = ""
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        backImage.AddBlurEffect(blueEffectStrength: 0.4)
        
        let c = LAContext()
        var error: NSError?
        if c.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            if c.biometryType != .touchID {
                faceTouchImage.image = #imageLiteral(resourceName: "faceID")
                reason = "Login with your FaceID"
            }else {
                reason = "Login with your TouchID"
            }
        }
        
        authenticateUser()
        setTransparentNavagtionBar()

    }
    
    // MARK: - authenticateUser API
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?
       
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)  {
           // let reason = "Login with your Finger/Face ID"
            
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
                    
                    User.shared.SaveToken(data: User.shared.data?.token! ?? "")
                    User.shared.SaveHashID(data: User.shared.data?.user_hash_id! ?? "")
                    self.goToHome()
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

    

}
