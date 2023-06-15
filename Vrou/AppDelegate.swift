//
//  AppDelegate.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/4/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import MOLH
import FirebaseCore
import UserNotifications
import Alamofire
import SwiftyJSON
import PKHUD
import FacebookCore
import IQKeyboardManagerSwift
import GoogleSignIn
import FirebaseMessaging
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MOLHResetable,  UNUserNotificationCenterDelegate {
    
    var launchedShortcutItem: UIApplicationShortcutItem?
    var window: UIWindow?
   
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        switch shortcutItem.type {
        case "com.Vrou.Offers":
            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "OffersNavController") as! OffersNavController
            keyWindow?.rootViewController = vc
            completionHandler(true)
        case "com.Vrou.Places":
            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "CenterNavController") as! CenterNavController
            keyWindow?.rootViewController = vc
            completionHandler(true)
        case "com.Vrou.Services":
            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "ServicesNavController") as! ServicesNavController
            keyWindow?.rootViewController = vc
            completionHandler(true)
        case "com.Vrou.Marketplace":
            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "ShopNavController") as! ShopNavController
            keyWindow?.rootViewController = vc
            completionHandler(true)
        default:
            break
        }
        
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("user clicked on the notification")
        let userInfo = response.notification.request.content.userInfo
        let targetValue = userInfo["notification_type"] as? String ?? "0"

        if targetValue == "2"
        {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessagesNavController") as! MessagesNavController
            keyWindow?.rootViewController = vc
            completionHandler()
            
        }
        else if targetValue == "1"
        {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NotificationsNavController") as! NotificationsNavController
            keyWindow?.rootViewController = vc
            completionHandler()
            
        }else {
            
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "BeautyWorldNavController") as! BeautyWorldNavController
            keyWindow?.rootViewController = vc
            completionHandler()
        }
        
    }
 
    
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let facebookValue = ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        let googleValue = GIDSignIn.sharedInstance.handle(url)
        return facebookValue && googleValue
    }
    
    func reset() {
        setupGlobalAppearance()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
         var shouldPerformAdditionalDelegateHandling = true
         
                if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {

                    launchedShortcutItem = shortcutItem

                    // This will block "performActionForShortcutItem:completionHandler" from being called.
                    
                    shouldPerformAdditionalDelegateHandling = false

                }
        
        setupGlobalAppearance()
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        FirebaseApp.configure()
        
        //Keyborad
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysShow
        IQKeyboardManager.shared.toolbarPreviousNextAllowedClasses.append(UIStackView.self)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        GMSServices.provideAPIKey(GoogleClientID)
        GMSPlacesClient.provideAPIKey(GoogleClientID)

        MOLHLanguage.setDefaultLanguage("en")

        MOLH.shared.activate(true)
        if (UserDefaults.standard.string(forKey: "Language") != nil) {
            UserDefaults.standard.set(MOLHLanguage.currentAppleLanguage(), forKey: "Language")
        }else {
            UserDefaults.standard.set("en", forKey: "Language")
        }
        
        
        if #available(iOS 12.1, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {granted,error in
            })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            
        }
        
        application.registerForRemoteNotifications()
        
        
        
        print(Messaging.messaging().fcmToken as Any)
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
            
            UserDefaults.standard.set(Messaging.messaging().fcmToken ?? "", forKey: "FCM_new")
            
            print( "NEW" + (UserDefaults.standard.string(forKey: "FCM_new") ?? ""))
            print( "OLD" + (UserDefaults.standard.string(forKey: "FCM_old") ?? ""))
            
            if UserDefaults.standard.string(forKey: "FCM_new") != UserDefaults.standard.string(forKey: "FCM_old") {
                
                UserDefaults.standard.set(true, forKey: "FCM_changed")
                UserDefaults.standard.set(UserDefaults.standard.string(forKey: "FCM_old"), forKey: "FCM_old_2")
                UserDefaults.standard.set(UserDefaults.standard.string(forKey: "FCM_new"), forKey: "FCM_old")
                
            }
            
            
        } else {
            print("First launch, setting UserDefault.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            
            Messaging.messaging().token { token, error in
                if let error = error {
                    print("Error fetching FCM registration token: \(error)")
                } else if let token = token {
                    print("FCM registration token: \(token)")
                    UserDefaults.standard.set(token, forKey: "FCM_new")
                    UserDefaults.standard.set(token, forKey: "FCM_old")
                }
            }
        }
        return shouldPerformAdditionalDelegateHandling
    }
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        RefreshDeviceToken()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
//        AppEvents.activateApp()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationsCounter.count = UIApplication.shared.applicationIconBadgeNumber
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        guard let shortcut = launchedShortcutItem else { return }
        handleShortcut(shortcutItem: shortcut)
        launchedShortcutItem = nil
    }
    
    
    @discardableResult func handleShortcut( shortcutItem:UIApplicationShortcutItem ) -> Bool {
        var handled = false
        
        switch shortcutItem.type {
        case "com.Vrou.Offers":
            Shortcuts.ID = "com.Vrou.Offers"
            Shortcuts.shortcut = true
            handled = true
        case "com.Vrou.Places":
            Shortcuts.ID = "com.Vrou.Places"
            Shortcuts.shortcut = true
            handled = true
        case "com.Vrou.Services":
            Shortcuts.ID = "com.Vrou.Services"
            Shortcuts.shortcut = true
            handled = true
        case "com.Vrou.Marketplace":
            Shortcuts.ID = "com.Vrou.Marketplace"
            Shortcuts.shortcut = true
            handled = true
        default:
            break
        }
        
        return handled
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        return GIDSignIn.sharedInstance().handle(url)
//    }

    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
        
    // MARK: - Appearance.
    func setupGlobalAppearance(){
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            
            
            //setupGlobalAppearance()
            let customFont = UIFont.appRegularFontWith(size: 17)
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: customFont], for: .normal)
            UILabel.appearance().substituteFontName = Constants.App.regularFont
            UILabel.appearance().substituteFontNameBold = Constants.App.boldFont
            
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar"  {
            
            let customFont = UIFont.appRegularFontWith(size: 17)
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: customFont], for: .normal)
            UILabel.appearance().substituteFontName = Constants.App.regularFont_ar
            UILabel.appearance().substituteFontNameBold = Constants.App.boldFont_ar
            
            
        }
    }
    
}

extension AppDelegate {
    
    func RefreshDeviceToken() {
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.RefreshDeviceToken.description, method: .post, parameters: ["device_token": UserDefaults.standard.string(forKey: "FCM_new") ?? "" , "device_id": UIDevice.current.identifierForVendor!.uuidString],encoding: URLEncoding.default, Header:["Authorization" : "Bearer \(User.shared.TakeToken())" , "Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: UIView()) { (data, tmp) in
            if tmp == nil {
                // HUD.hide()
                //                       do {
                //                        // self.success = try JSONDecoder().decode(Error.self, from: data!)
                //                        // HUD.flash(.label(self.success.msg?[0] ?? "Added to Cart") , onView: self.view , delay: 1.6 , completion: nil)
                //
                //                       }catch {
                //                           HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                //                       }
            }
            //                   }else if tmp == "401" {
            //                       let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            //                       keyWindow?.rootViewController = vc
            //
            //                   }
            
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
}




