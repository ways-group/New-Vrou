//
//  SceneDelegate.swift
//  Vrou
//
//  Created by Mac on 12/18/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    @available(iOS 13.0, *)
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        let alert = UIAlertController(title: "Quick Actions Tutorial", message: "Quick Action Identifier: \(shortcutItem.type)", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
//
//        switch shortcutItem.type {
//        case "com.Vrou.Offers":
//            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "OffersNavController") as! OffersNavController
//            keyWindow?.rootViewController = vc
//        case "com.Vrou.Places":
//            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "CenterNavController") as! CenterNavController
//            keyWindow?.rootViewController = vc
//        case "com.Vrou.Services":
//            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "ServicesNavController") as! ServicesNavController
//            keyWindow?.rootViewController = vc
//        case "com.Vrou.Marketplace":
//            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "ShopNavController") as! ShopNavController
//            keyWindow?.rootViewController = vc
//
//        default:
//            break
//        }
    }
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        if #available(iOS 13.0, *) {
            guard let _ = (scene as? UIWindowScene) else { return }
        } else {
            // Fallback on earlier versions
        }
    }

    @available(iOS 13.0, *)
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    @available(iOS 13.0, *)
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    @available(iOS 13.0, *)
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }


}
