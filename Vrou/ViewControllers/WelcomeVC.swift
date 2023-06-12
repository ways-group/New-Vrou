//
//  WelcomeVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/4/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import RSSelectionMenu
import MOLH
import SDWebImage
import IntentsUI

class WelcomeVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var BeautyLogo: UIImageView!
    @IBOutlet weak var LoginBtn: UIButton!
    @IBOutlet weak var DiscoverBtn: UIButton!
    @IBOutlet weak var WelcomeImage: UIImageView!
    @IBOutlet weak var LanguageBtn: UIButton!
    
    // MARK: - Variables
    var uiSUpport = UISupport()
    var imageView = ["", "", ""] // 0 for discover  1 for login // 2 for register
    var languages = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            languages = ["ar"]
        }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            languages = ["en"]
        }
        
        if let nav = self.navigationController {
            uiSUpport.TransparentNavigationController(navController: nav)
        }
        
        SetImage(image: WelcomeImage, link: FirstAdds.discover_ads )
        
        
        //Siri
        // addSiriButton(to: self.view)
        
    }
    
    
//    func addSiriButton(to view: UIView) {
//      if #available(iOS 12.0, *) {
//          let button = INUIAddVoiceShortcutButton(style: .whiteOutline)
//              button.shortcut = INShortcut(intent: intent )
//              button.delegate = self
//              button.translatesAutoresizingMaskIntoConstraints = false
//              view.addSubview(button)
//              view.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
//              view.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
//          }
//      
//      }
    func showMessage() {
         let alert = UIAlertController(title: "Done!", message: "This is your first shortcut action!", preferredStyle: UIAlertController.Style.alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
         self.present(alert, animated: true, completion: nil)
     }
    
    
    
     // MARK: - LoginBtn
    @IBAction func LoginBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
     // MARK: - DiscoverBtn
    @IBAction func DiscoverBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "BeautyWorldNavController") as! BeautyWorldNavController
        UIApplication.shared.keyWindow?.rootViewController = vc
        
    }
    
     // MARK: - ChangeLanguageBtn
    @IBAction func ChangeBtn_pressed(_ sender: Any) {
        
        let current_lang = UserDefaults.standard.string(forKey: "Language") ?? "en"
        let lang = current_lang  == "ar" ? "en" : "ar"
        
        MOLH.setLanguageTo(lang)
        UserDefaults.standard.set(lang, forKey: "Language")
        print(UserDefaults.standard.string(forKey: "Language") ?? "en")
        MOLH.reset()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginNavController") as! LoginNavController
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage: nil, options: .highPriority , completed: nil)
    }
    
}


    // MARK: - Siri

//extension WelcomeVC {
//    @available(iOS 12.0, *)
//      public var intent: DoSomethingIntent {
//          let testIntent = DoSomethingIntent()
//          testIntent.suggestedInvocationPhrase = "Test vrou"
//          return testIntent
//      }
//}

extension WelcomeVC:INUIAddVoiceShortcutButtonDelegate {
    
    @available(iOS 12.0, *)
     func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
         addVoiceShortcutViewController.delegate = self
         addVoiceShortcutViewController.modalPresentationStyle = .formSheet
         present(addVoiceShortcutViewController, animated: true, completion: nil)
     }
    
    
    @available(iOS 12.0, *)
      func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
          editVoiceShortcutViewController.delegate = self
          editVoiceShortcutViewController.modalPresentationStyle = .formSheet
          present(editVoiceShortcutViewController, animated: true, completion: nil)
      }
    
}


extension WelcomeVC: INUIAddVoiceShortcutViewControllerDelegate {
    
    @available(iOS 12.0, *)
     func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
         controller.dismiss(animated: true, completion: nil)
     }
     
     @available(iOS 12.0, *)
     func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
         controller.dismiss(animated: true, completion: nil)
     }
}


extension WelcomeVC:INUIEditVoiceShortcutViewControllerDelegate {
    
    @available(iOS 12.0, *)
     func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
         controller.dismiss(animated: true, completion: nil)
     }
     
     @available(iOS 12.0, *)
     func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
         controller.dismiss(animated: true, completion: nil)
     }
     
     @available(iOS 12.0, *)
     func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
         controller.dismiss(animated: true, completion: nil)
     }
    
}


