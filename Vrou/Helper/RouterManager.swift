//
//  File.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/8/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

enum Storyboard: String {
    case auth = "Auth"
    case master = "Master"
    case main = "Main"
    case categories = "Categories"
    case center = "Center"
    case search = "Search"
    case home = "Home"
    case salonProfile = "SalonProfile"
    case userProfile = "UserProfile"
//    case general = "General"

}

enum View: String {
    //Auth
    case loginVC = "LoginVC"
    
    //Master
    case changeLanguageView = "ChangeLanguageView"
    case homeRootView = "HomeRootView"
    case vrouWorldView = "VrouWorldView"
    case offersVC = "OffersVC"
    case HomeServicesVC = "HomeServicesVC"
    case firstAdVC = "FirstAdVC"
    case splashVC = "SplashVC"
    //Main
    case cartVC = "CartVC"
    case reservationsVC = "ReservationsVC"
    case thanxForShoppingVC = "ThanxForShoppingVC"
    case paymentVC = "PaymentVC"
    case shakeFeedbackVC = "ShakeFeedbackVC"
    case settingVC = "SettingVC"
    case aboutAppVC = "AboutAppVC"
    case watchVC = "WatchVC"
    case notificationsVC = "NotificationsVC"

    case changePasswordVC = "ChangePasswordVC"
    case settingForgetPassword = "SettingForgetPassword" //
    case contactUsVC = "ContactUsVC"
    case advertiseVC = "AdvertiseVC"
    case messagesVC = "MessagesVC"
    case friendRequestsVC = "FriendRequestsVC"
    //Categories
    case offersViewController = "OffersViewController"
    case servicesVC = "ServicesVC"
    case shopViewController = "ShopViewController"
    case centerViewController = "CenterViewController"
    case mapVC = "MapVC"
    case usersListVC = "UsersListVC"
    case commentsVC = "CommentsVC"
    case specialOfferVC = "SpecialOfferVC"
    case OfferVC = "OfferVC"
    case tutorialView = "TutorialView"
    //center
    case salonAlbumVC = "SalonAlbumVC"
    //search
    case centersSearchVC = "CentersSearchVC"
    case productsSearchVC = "ProductsSearchVC"
    case offersSearchVC = "OffersSearchVC"
    case servicesSearchVC = "ServicesSearchVC"
    //home
    case beautyWorldVC = "BeautyWorldVC"
    case yourWorldVC = "YourWorldVC"
    case singleOfferVC = "SingleOfferVC"
    case webVC = "WebVC"
    //general
    //salon profile
    case salonProfileRootView = "SalonProfileRootView"
    case salonProfileSettingsPopUp = "SalonProfileSettingsPopUp"
    case SalonSocialMediaAnimationView = "SalonSocialMediaAnimationView"
    case reviewSalonView = "ReviewSalonView"
    case aboutSalonView = "AboutSalonView"
    case reviewsVC = "ReviewsVC"
    case QR_codeVC = "QR_codeVC"
    case ServicePolicyVC = "ServicePolicyVC"
    case CenterServicesVC = "CenterServicesVC"
    case SalonOffersVC = "SalonOffersVC"
    case CenterProductsVC = "CenterProductsVC"
    
    //user profile
    case userProfileVC = "ProfileVC"
    case UserProfileGallaryVC = "UserProfileGallaryVC"
    case ProfileQrVC     = "ProfileQrVC"
    case MyPurchasesVC   = "MyPurchasesVC"
    case MyFavouritesVC  = "MyFavouritesVC"
    case CollectionVC    = "CollectionVC"
    case UserReviewsVC   = "UserReviewsVC"
    case PinInVC         = "PinInVC"
    case EditAccountVC   = "EditAccountVC"
    case EventsVC        = "EventsVC"
    case ScheduledReservationsVC = "ScheduledReservationsVC"
    case PersonProfileVC = "PersonProfileVC"
    
    private var storyboard: Storyboard {
        switch self {
        case .loginVC, .CenterServicesVC, .SalonOffersVC, .CenterProductsVC, .shopViewController:
            return .auth
        case .changeLanguageView, .homeRootView, .vrouWorldView, .splashVC,.firstAdVC, .offersVC, .HomeServicesVC:
            return .master
        case  .cartVC, .reservationsVC, .thanxForShoppingVC, .paymentVC, .shakeFeedbackVC, .settingVC, .aboutAppVC, .watchVC,
              .notificationsVC, .changePasswordVC, .settingForgetPassword, .contactUsVC, .advertiseVC, .messagesVC, .friendRequestsVC:
            return .main
        case .offersViewController, .servicesVC,
             .centerViewController, .mapVC, .usersListVC, .commentsVC,
             .specialOfferVC, .OfferVC, .tutorialView:
            return .categories
        case  .centersSearchVC, .productsSearchVC, .offersSearchVC, .servicesSearchVC:
            return .search
        case .beautyWorldVC, .yourWorldVC, .singleOfferVC, .webVC:
            return .home
        case .salonProfileRootView, .salonProfileSettingsPopUp,.aboutSalonView, .reviewSalonView, .SalonSocialMediaAnimationView:
            return .salonProfile
        case .salonAlbumVC, .reviewsVC, .QR_codeVC, .ServicePolicyVC:
            return .center
        case .userProfileVC, .UserProfileGallaryVC, .PersonProfileVC:
            return .userProfile
        case .ProfileQrVC, .MyPurchasesVC, .MyFavouritesVC, .CollectionVC, .UserReviewsVC,
            .PinInVC, .EditAccountVC, .EventsVC, .ScheduledReservationsVC:
            return .main
        }
    }
    func controller<Presenter: BasePresenter, Item: BaseItem>(presenterType: Presenter.Type, item: Item) -> BaseVC<Presenter, Item> {
        let controller = UIStoryboard.init(name: storyboard.rawValue, bundle: Bundle.main).instantiateViewController(withIdentifier: rawValue)
            as! BaseVC<Presenter, Item> //swiftlint:disable:this force_cast
        controller.item = item
        return controller
    }
    
    func identifyViewController<viewController: UIViewController>(viewControllerType: viewController.Type) -> viewController {
        let controller = UIStoryboard.init(name: storyboard.rawValue, bundle: Bundle.main).instantiateViewController(withIdentifier: rawValue)
            as! viewController //swiftlint:disable:this force_cast
        return controller
    }
    
    func baseController<viewController: UIViewController>(viewControllerType: viewController.Type) -> viewController {
        let controller = UIStoryboard.init(name: storyboard.rawValue, bundle: Bundle.main).instantiateViewController(withIdentifier: rawValue)
            as! viewController //swiftlint:disable:this force_cast
        return controller
    }
}

protocol RouterManagerProtocol {
    func push<Presenter: BasePresenter, Item: BaseItem>(view: View, presenter: Presenter.Type, item: Item )
    func present<Presenter: BasePresenter, Item: BaseItem>(view: View, presenter: Presenter.Type, item: Item)
    func startScreen<viewController: UIViewController>(view: View, controller: viewController.Type)
    func push(controller: UIViewController)
    func present(controller: UIViewController)
    func popBack()
    func dismiss()
    
}

class RouterManager: RouterManagerProtocol {
    
    var currentViewController: UIViewController
    
    func push(controller: UIViewController) {
        currentViewController.navigationController?.pushViewController(controller, animated: true)
    }
    func present(controller: UIViewController) {
        currentViewController.present(controller, animated: false)
    }
    init(_ currentViewController: UIViewController) {
        self.currentViewController = currentViewController
    }
    
    func present<Presenter: BasePresenter, Item: BaseItem>(view: View, presenter: Presenter.Type, item: Item) {
        let viewController = view.controller(presenterType: presenter, item: item)
        currentViewController.present(viewController, animated: true)
    }
    
    func push<Presenter: BasePresenter, Item: BaseItem>(view: View, presenter: Presenter.Type, item: Item ) {
        let viewController = view.controller(presenterType: presenter, item: item)
        currentViewController.navigationController?.pushViewController(viewController, animated: false)
    }
    
    
    func startScreen<viewController: UIViewController>(view: View, controller: viewController.Type) {
        let viewController = view.baseController(viewControllerType: controller)
        currentViewController.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func popBack() {
        _ = currentViewController.navigationController?.popViewController(animated: true)
    }
    func dismiss() {
        _ = currentViewController.dismiss(animated: true, completion: nil)
    }
    
}
//Open SideMenu
public func openSideMenu(vc: UIViewController){
    let menu =  UIStoryboard(name: Storyboard.master.rawValue, bundle: Bundle.main).instantiateViewController(withIdentifier: "LeftMenuNavigationController") as! SideMenuNavigationController
    menu.settings = makeSettings(vc.view)
    if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
        menu.leftSide = false
    }else{
        menu.leftSide = true
    }
    vc.present(menu, animated: true, completion: nil)
}
public func makeSettings(_ view: UIView) -> SideMenuSettings {
       let presentationStyle = selectedPresentationStyle()
       presentationStyle.menuStartAlpha = 1.0
       presentationStyle.onTopShadowOpacity = 0.0
       presentationStyle.presentingEndAlpha = 1.0
       var settings = SideMenuSettings()
       settings.presentationStyle = presentationStyle
       settings.menuWidth = min(view.frame.width, view.frame.height)  * 0.9
       settings.statusBarEndAlpha = 0
       
       return settings
   }
private func selectedPresentationStyle() -> SideMenuPresentationStyle {
       return .viewSlideOutMenuIn
}
   
