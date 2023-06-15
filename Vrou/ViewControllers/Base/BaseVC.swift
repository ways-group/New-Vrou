//
//  BaseVC.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/8/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//
 

import UIKit
import SideMenu
 
var base = BaseVC()

class BaseVC<VM :BasePresenter,Item:BaseItem>:  UIViewController {
    
    var item: Item!
        
    var presenter : VM!
//    {
//        didSet{
//            presenter.successMessage.bind({ (sucessMessage) in
//                AppRefrence.showAlertMessage(title: Language.localizeStringForKey(word: "success"),
//                                             message: Language.localizeStringForKey(word: sucessMessage),
//                                             theme: .info)
//
//            })
//            presenter.errorMessage.bind( { (errorMessage) in
//                AppRefrence.showAlertMessage(title: Language.localizeStringForKey(word: "error"),
//                                             message: Language.localizeStringForKey(word: errorMessage),
//                                             theme: .error)
//            })
//            presenter.isLoading.bindAndFire { (loading) in
//                if loading {
//                    base.hud.show(in:self.view )
//
//                } else {
//                    base.hud.dismiss()
//
//                }
//            }
//        }
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        bindind()
    }
    func bindind() {
     //   setupSideMenu()
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let sideMenuNavigationController = segue.destination as? SideMenuNavigationController else { return }
//        sideMenuNavigationController.settings = makeSettings(self.view)
//        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
//            sideMenuNavigationController.leftSide = false
//        }else{
//             sideMenuNavigationController.leftSide = true
//        }
//    }
//    private func setupSideMenu() {
//          SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
//      }
//    
}
