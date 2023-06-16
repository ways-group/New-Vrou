//
//  SalonProfileRootViewController.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/20/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import SideMenu
import Alamofire
import PKHUD
import XLPagerTabStrip

class SalonProfileRootView: BaseButtonBarPagerTabStripViewController<SalonProfileTabsCell> {
    
    @IBOutlet weak var collapseTabsPositionConstant: NSLayoutConstraint!
    @IBOutlet weak var tabs_view: UIView!
    @IBOutlet weak var information_view: UIView!
    @IBOutlet weak var salonName: UILabel!
    @IBOutlet weak var salonCategory: UILabel!
    @IBOutlet weak var salonAddress: UILabel!
    @IBOutlet weak var followersNumber: UILabel!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var rateCount: UILabel!
    @IBOutlet weak var salon_img: UIImageView!
    @IBOutlet weak var salonVerify_img: UIImageView!
    @IBOutlet weak var salonBachground_img: UIImageView!
    @IBOutlet weak var followBtn: UIButton!

    var salonAbout: SalonAboutData? = SalonAboutData()
    var salonId = 0
    var success = ErrorMsg()
    var firstTime = true
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buttonBarItemSpec = ButtonBarItemSpec.nibFile(nibName: "SalonProfileTabsCell", bundle: Bundle(for: SalonProfileTabsCell.self), width: { _ in
            return 4
        })
    }
    //receive header data
    func create_observer(){
        NotificationCenter.default.addObserver(self, selector: #selector(getData(_:)), name: NSNotification.Name("salonHeaderData"), object: nil)
    }
    @objc func getData(_ notification: NSNotification) {
        guard let getData = notification.userInfo?["data"] as? SalonAboutData else { return }
       salonAbout = getData
        setSalonHeaderData()
    }
    deinit {
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name("salonHeaderData"),object: nil)
    }
    override func viewDidLoad() {
        create_observer()
        settings.style.selectedBarBackgroundColor = .clear
        changeCurrentIndexProgressive = { (oldCell: SalonProfileTabsCell?, newCell: SalonProfileTabsCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.oldCellConfigue()
            newCell?.newCellConfigure()
        }
        super.viewDidLoad()
        setTransparentNavagtionBar(with: UIColor(named: "mainColor")!)
        
        tabs_view.layer.cornerRadius = 10
        tabs_view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        information_view.layer.cornerRadius = 10
        information_view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    override func viewWillAppear(_ animated: Bool) {
        setTransparentNavagtionBar(with: UIColor(named: "mainColor")!)
        super.viewWillAppear(animated)
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            containerView.isScrollEnabled = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setTransparentNavagtionBar(with: UIColor(named: "mainColor")!)
        super.viewDidAppear(animated)
       
        if firstTime {self.moveToViewController(at: 0)
            self.reloadPagerTabStripView()
        }
        firstTime = false
    }
    func animateHeader() {
      //  view.layoutIfNeeded() // force any pending operations to finish
        UIView.animate(withDuration: 0.6, animations: { () -> Void in
           self.collapseTabsPositionConstant.constant = 0
            self.view.layoutIfNeeded()
        })
    }

    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let aboutSalonView = View.aboutSalonView.identifyViewController(viewControllerType: AboutSalonView.self)
        aboutSalonView.rootView = self
        aboutSalonView.SalonID = salonId
        
        let salonSeviceView = View.CenterServicesVC.identifyViewController(viewControllerType: CenterServicesVC.self)
        salonSeviceView.rootView = self
        salonSeviceView.salonID = salonId
        
        let salonOffersView = View.SalonOffersVC.identifyViewController(viewControllerType: SalonOffersVC.self)
        salonOffersView.rootView = self
        salonOffersView.SalonID = salonId
        
        let salonProductsView = View.CenterProductsVC.identifyViewController(viewControllerType: CenterProductsVC.self)
        salonProductsView.rootView = self
        salonProductsView.SalonID = salonId
        
        let reviewSalonView = View.reviewsVC.identifyViewController(viewControllerType: ReviewsVC.self)
        reviewSalonView.rootView = self
        reviewSalonView.salonID = "\(salonId)"
       
        return [aboutSalonView, salonOffersView, salonSeviceView, salonProductsView, reviewSalonView]
    }
    
    override func configure(cell: SalonProfileTabsCell, for indicatorInfo: IndicatorInfo) {
       // cell.icon_img.image = indicatorInfo.image
        cell.title_lbl.text = indicatorInfo.title?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)
        if indexWasChanged && toIndex > -1 && toIndex < viewControllers.count {
            let child = viewControllers[toIndex] as! IndicatorInfoProvider // swiftlint:disable:this force_cast
            UIView.performWithoutAnimation({ [weak self] () -> Void in
                guard let me = self else { return }
                me.navigationItem.leftBarButtonItem?.title =  child.indicatorInfo(for: me).title
            })
        }
    }
    
    override func reloadPagerTabStripView() {
        super.reloadPagerTabStripView()
    }
}

//set Header Data
extension SalonProfileRootView {
    func setSalonHeaderData()  {
        salon_img.sd_setImage(with: URL.init(string: salonAbout?.about?.salon_logo ?? ""), completed: nil)
        salonBachground_img.sd_setImage(with: URL.init(string: salonAbout?.about?.salon_background ?? ""), completed: nil)
        //salonVerify_img.sd_setImage(with: URL.init(string: salonAbout?.about?.verify_image ?? ""), completed: nil)

        salonName.text =  salonAbout?.about?.salon_name ?? ""
        salonCategory.text =  salonAbout?.about?.category?.category_name ?? ""
        salonAddress.text =  (salonAbout?.about?.area?.area_name ?? "") + ", " + (salonAbout?.about?.city?.city_name ?? "")
        rate.text = salonAbout?.about?.rate ?? ""
        rateCount.text = salonAbout?.about?.rate_count ?? ""
        followersNumber.text = "\(salonAbout?.about?.followers ?? 0) "  + "People Followers".ar()
        if User.shared.isLogedIn() {
            (salonAbout?.is_follower == 1) ? followBtn.setTitle(NSLocalizedString("Unfollow", comment: ""), for: .normal) : followBtn.setTitle(NSLocalizedString("Follow", comment: ""), for: .normal)
        }
    }
}

//Buttons Actions
extension SalonProfileRootView {
    @IBAction func openSideMenu(_ button: UIButton){
        Vrou.openSideMenu(vc: self)
    }
    
    @IBAction func openSettingsPopUpAction(_ sender: Any) {
        let vc = View.salonProfileSettingsPopUp.identifyViewController(viewControllerType: SalonProfileSettingsPopUp.self)
        vc.salonId = salonId
        vc.salonAbout = salonAbout
        vc.parentView = self
        RouterManager(self).present(controller: vc)
    }
    
    @IBAction func makeCallAction(_ button: UIButton){
        
        let url: NSURL = URL(string: "TEL://\(salonAbout?.main_branch?.phone ?? "")")! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        
//        let vc = View.SalonSocialMediaAnimationView.identifyViewController(viewControllerType: SalonSocialMediaAnimationView.self)
//        vc.salonId = salonId
//        vc.salonAbout = salonAbout
//        vc.parentView = self
//        RouterManager(self).present(controller: vc)
    }
    
    @IBAction func followSalonAction(_ button: UIButton){
        if User.shared.isLogedIn() {
            HUD.show(.progress , onView: view)
            if followBtn.titleLabel?.text == "Follow" {
                FollowSalon(follow: true, id: "\(salonId)")
            }else {
                FollowSalon(follow: false, id: "\(salonId)")
            }
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController")
            vc.modalPresentationStyle = .fullScreen
            self.dismiss(animated: false)
            RouterManager(self).present(controller: vc)
        }
    }
    
    @IBAction func makeReservationAction(_ button: UIButton){
    }
    
    @IBAction func openRatingAction(_ button: UIButton){
        self.moveToViewController(at: 4)
        self.reloadPagerTabStripView()
    }
    
    
    // MARK: - FollowSalon_API
    func FollowSalon(follow:Bool , id:String) {
        var FinalURL = ""
        if follow {
            FinalURL = ApiManager.Apis.FollowSalon.description
        }else {
            FinalURL = ApiManager.Apis.unfollowSalon.description
        }
        if User.shared.isLogedIn() {
            ApiManager.shared.ApiRequest(URL: FinalURL, method: .post, parameters: ["salon_id": id], encoding: URLEncoding.default, Header: ["Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ] , ExtraParams: "", view: self.view) { (data, tmp) in
                
                if tmp == nil {
                    HUD.hide()
                    do {
                        self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                        HUD.flash(.label("\(self.success.msg?[0] ?? "Success")") , onView: self.view , delay: 1.6 , completion: {
                            (tmp) in
                            if self.followBtn.titleLabel?.text == "Follow" {
                                self.followBtn.setTitle("Unfollow", for: .normal)
                            }else {
                                self.followBtn.setTitle("Follow", for: .normal)
                            }
                        })
                        
                    }catch {
                        HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                    }
                }
            }
        }
        
        
    }
}
