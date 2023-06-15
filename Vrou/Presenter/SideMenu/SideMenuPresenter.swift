//
//  SideMenuPresenter.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/8/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

 class SideMenuPresenter: BasePresenter {
    var router: RouterManagerProtocol!
    var selected = 1
    init(router: RouterManagerProtocol) {
         self.router = router
    }
    func itemsRoute(_ tag: Int){
        globalValues.sideMenu_selected = tag - 1
        switch tag {
        case 1:
            router.push(controller: View.homeRootView.identifyViewController(viewControllerType: HomeRootView.self))
           // router.push(view: .homeRootView, presenter: BasePresenter.self, item: BaseItem())
        case 2://        CenterParams.SectionID = "0"
            router.push(view: .centerViewController, presenter: BasePresenter.self, item: BaseItem())
        case 3:
             !User.shared.isLogedIn() ?  openSigninRequired() :
            router.push(view: .yourWorldVC, presenter: YourWorldPresenter.self, item: BaseItem())
        case 4://tutorial
            router.push(view: .tutorialView, presenter: TutorialPresenter.self, item: BaseItem())
//        case 5://
//            router.push(view: .shopViewController, presenter: BasePresenter.self, item: BaseItem())
        case 5://cart
            !User.shared.isLogedIn() ?  openSigninRequired() :
            router.push(view: .cartVC, presenter: BasePresenter.self, item: BaseItem())
        case 6://
            router.push(view: .mapVC, presenter: BasePresenter.self, item: BaseItem())
        case 7://WATCH
            router.push(view: .watchVC, presenter: BasePresenter.self, item: BaseItem())
        case 8://HELP & SUPPORT
            router.push(view: .aboutAppVC, presenter: BasePresenter.self, item: BaseItem())
        case 9://SETTINGS
            router.push(view: .settingVC, presenter: BasePresenter.self, item: BaseItem())
        case 10://signout
            User.shared.isLogedIn() ?  signOut() : router.push(view: View.loginVC, presenter: BasePresenter.self, item: BaseItem())
        case 12://
            !User.shared.isLogedIn() ?  openSigninRequired() :
            router.push(view: .notificationsVC, presenter: BasePresenter.self, item: BaseItem())
        case 13://
            router.push(view: .changeLanguageView, presenter: BasePresenter.self, item: BaseItem())
        case 14://
            let vc = UIStoryboard(name: Storyboard.search.rawValue, bundle: nil).instantiateViewController(withIdentifier: "CentersSearchNavController") as! CentersSearchNavController
            keyWindow?.rootViewController = vc
        case 15://my account
            !User.shared.isLogedIn() ?
                router.push(view: View.loginVC, presenter: BasePresenter.self, item: BaseItem())
                : router.push(controller:   View.userProfileVC.identifyViewController(viewControllerType: ProfileVC.self))
        default:
            break
        }
    }
    
    func signOut(){
        User.shared.remove()
        goToSplash()
    }
    func goToSplash(){
        let vc = View.splashVC.identifyViewController(viewControllerType: SplashVC.self)
        let vcc = UINavigationController(rootViewController: vc)
        keyWindow?.rootViewController = vcc
    }
    func openSigninRequired(){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController")
        vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        router.present(controller: vc) //.present(vc, animated: true, completion: nil)
    }
}
/*
 
   
    
    // MARK: - MyAccountBtn
    @IBAction func MyAccountBtn_pressed(_ sender: Any) {
        if User.shared.isLogedIn() {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditAccountNavController") as! EditAccountNavController
            keyWindow?.rootViewController = vc
            
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: - AboutVrouBtn
    @IBAction func AboutVrouBtn_pressed(_ sender: Any) {
        globalValues.sideMenu_selected = 8
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AboutAppVC") as! AboutAppVC
        self.navigationController?.popViewController(animated: false )
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // MARK: - CartBtn
    @IBAction func CartBtn_pressed(_ sender: Any) {
        
        if User.shared.isLogedIn(){
            globalValues.sideMenu_selected = 5

            let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CartVC") as! CartVC
            self.navigationController?.popViewController(animated: false )
            self.navigationController?.pushViewController(vc, animated: false)
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    
    // MARK: - SettingBtn
    @IBAction func SettingBtn_pressed(_ sender: Any) {
        
        if User.shared.isLogedIn() {
            globalValues.sideMenu_selected = 9

            let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
            self.navigationController?.popViewController(animated: false )
            self.navigationController?.pushViewController(vc, animated: false)
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    // MARK: - NotificationsBtn
    @IBAction func NotificationsBtn_pressed(_ sender: Any) {
        
        if User.shared.isLogedIn(){
            let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NotificationsVC") as! NotificationsVC
            self.navigationController?.popViewController(animated: false )
            self.navigationController?.pushViewController(vc, animated: false)
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: - SignoutBtn
    @IBAction func SignOutBtn_pressed(_ sender: Any) {
        if User.shared.isLogedIn() {
            SignOut()
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WelcomeNavController") as! WelcomeNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: - SearchBtn
    @IBAction func SearchBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "CentersSearchNavController") as! CentersSearchNavController
        keyWindow?.rootViewController = vc
    }
    
    
}
 
    
    
    // MARK: - SignOutAPI
    func SignOut() {
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.Logout.description, method: .post, parameters: ["":""] , encoding: URLEncoding.default, Header: ["Authorization" : "Bearer \(User.shared.TakeToken())" , "Accept":"application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                User.shared.remove()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
                keyWindow?.rootViewController = vc
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                keyWindow?.rootViewController = vc
                
            }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.SignOut()
                }
                self.present(vc, animated: true, completion: nil)
            }
            
            
        }
    }
}
*/
