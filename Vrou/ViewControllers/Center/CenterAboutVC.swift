//
//  CenterAboutVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/14/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import ViewAnimator
import AVKit
import AVFoundation
import Alamofire
import SwiftyJSON
import PKHUD
import HCSStarRatingView
import SDWebImage
import SideMenu
import MOLH
import ImageSlideshow
import GoogleMaps


class CenterAboutVC: UIViewController {
    
   
    // MARK: - IBOutlet
   
    @IBOutlet weak var slideshow: ImageSlideshow!
    @IBOutlet weak var SalonIcon: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var SalonCategory: UILabel!
    @IBOutlet weak var SalonRateStars: HCSStarRatingView!
    @IBOutlet weak var servicesCountLbl: UILabel!
    @IBOutlet weak var OfferCountLbl: UILabel!
    @IBOutlet weak var ProductCountLbl: UILabel!
    @IBOutlet weak var AboutLbl: UILabel!
    @IBOutlet weak var FollowBtn: UIButton!
    @IBOutlet weak var VerifyImage: UIImageView!
    @IBOutlet weak var MainBranchMap: GMSMapView!
    @IBOutlet weak var MainBranchName: UILabel!
    @IBOutlet weak var MainBranchLocation: UILabel!
    @IBOutlet weak var MainBranchWorkTime: UILabel!
    @IBOutlet weak var is_openSalon: UILabel!
    @IBOutlet weak var MainBranch_phoneBtn: UIButton!
    
    @IBOutlet weak var GalleryCollection: UICollectionView!
    @IBOutlet weak var TutorialCollection: UICollectionView!
    @IBOutlet weak var Specialists: UICollectionView!
    @IBOutlet weak var FeaturesCollection: UICollectionView!
    @IBOutlet weak var followersCollection: UICollectionView!
    @IBOutlet weak var BranchesCollection: UICollectionView!
    
    @IBOutlet weak var Rate: UILabel!
    @IBOutlet weak var RateCount: UILabel!
    
    @IBOutlet weak var AboutHeight: NSLayoutConstraint!
    @IBOutlet weak var GalleryHeight: NSLayoutConstraint!
    @IBOutlet weak var VideosHeight: NSLayoutConstraint!
    @IBOutlet weak var SpeciallistHeight: NSLayoutConstraint!
    @IBOutlet weak var FeaturesHeight: NSLayoutConstraint!
    
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var followersCount: UILabel!
        
    
    @IBOutlet weak var BrowserBtn: UIButton!
    @IBOutlet weak var SnapChatBtn: UIButton!
    @IBOutlet weak var FacebookBtn: UIButton!
    @IBOutlet weak var TwitterBtn: UIButton!
    @IBOutlet weak var InstgramBtn: UIButton!
    @IBOutlet weak var WhatsAppBtn: UIButton!
    @IBOutlet weak var MailBtn: UIButton!
    @IBOutlet weak var youtubeBtn: UIButton!
    @IBOutlet weak var PinBtn: UIButton!
    @IBOutlet weak var AboutTitle: UILabel!
    @IBOutlet weak var AboutTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var socialsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var followLbl: UILabel!
    @IBOutlet weak var mainBranchLbl: UILabel!
    
    // MARK: - Variables
    private var items = [Any?]()
    private let animations = [AnimationType.from(direction: .left, offset: 60.0)]
    
    var SalonID = 1

    var salonAbout = SalonAbout()
    
    var featuresNames = ["Free internet","Swimming pool","Waiting lounge","Pets","hospitality"]
    var featuresImages = [#imageLiteral(resourceName: "wifi") , #imageLiteral(resourceName: "swim") , #imageLiteral(resourceName: "tv") , #imageLiteral(resourceName: "pet") , #imageLiteral(resourceName: "drink")]
    
    var Requested = false
    var success = ErrorMsg()
    
    var tabs = [String]()
    let toArabic = ToArabic()
    var uiSUpport = UISupport()
    
    var imageSource = [InputSource]()
       
    override func viewDidLoad() {
        super.viewDidLoad()

        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            CheckArabicSetup()
        }
        mainView.contentView = logo
        mainView.isShimmering = true
        mainView.shimmeringSpeed = 550
        mainView.shimmeringOpacity = 1
        SetUpCollectionView(collection: GalleryCollection)
        SetUpCollectionView(collection: TutorialCollection)
        SetUpCollectionView(collection: Specialists)
        SetUpCollectionView(collection: FeaturesCollection)
        SetUpCollectionView(collection: followersCollection)
        SetUpCollectionView(collection: BranchesCollection)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
       
        followLbl.text = NSLocalizedString("Followers", comment: "")
        mainBranchLbl.text = NSLocalizedString("Main Branch", comment: "")
        SetupAnimation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        GetCenterAboutData()
    }
    
    
     func SetUpCollectionView(collection:UICollectionView){
         collection.delegate = self
         collection.dataSource = self
     }
    
    // MARK: - SetupSlideShow
    func SetUpSlideShow(slider:Bool) {
         
         slideshow.slideshowInterval = 2.0
         slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
         slideshow.contentScaleMode = UIView.ContentMode.scaleAspectFill
         
         let pageControl = UIPageControl()
         pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)
         pageControl.pageIndicatorTintColor =  UIColor.lightGray
         slideshow.pageIndicator = pageControl
         
         slideshow.activityIndicator = DefaultActivityIndicator()
         imageSource.removeAll()
       
        if slider {
            salonAbout.data?.about?.sliders?.forEach({ (image) in
                imageSource.append(AlamofireSource(urlString: image.image ?? "") ?? ImageSource(image: UIImage(named: "Logoface") ?? UIImage()))
            })
        }else {
            imageSource.append(AlamofireSource(urlString: salonAbout.data?.about?.salon_background ?? "") ?? ImageSource(image: UIImage(named: "Logoface") ?? UIImage()))
        }
         
         
         self.slideshow.setImageInputs(self.imageSource)
         self.slideshow.reloadInputViews()
     }
    
    
    func CheckArabicSetup() {
        toArabic.ReverseLabelAlignment(label: AboutLbl)
    }

    func SetupAnimation() {
        items = Array(repeating: nil, count: 1)
        GalleryCollection?.performBatchUpdates({
            UIView.animate(views: GalleryCollection.visibleCells,
                           animations: animations,
                           duration: 0.5)
        }, completion: nil)
        
        TutorialCollection?.performBatchUpdates({
            UIView.animate(views: TutorialCollection.visibleCells,
                           animations: animations,
                           duration:0.5 )
        }, completion: nil)
    }
    
    
    func playVideo(url: URL) {
        let player = AVPlayer(url: url)
        
        let vc = AVPlayerViewController()
        vc.player = player
        
        self.present(vc, animated: true) { vc.player?.play() }
    }

    // MARK: - QRcodeBtn
    @IBAction func QrCodeBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "QR_codeVC") as! QR_codeVC
        vc.salonLogo = SalonIcon.image ?? UIImage()
        vc.salonName  = SalonName.text ?? ""
        vc.salonCategory = SalonCategory.text ?? ""
        vc.QrCodeLink = salonAbout.data?.about?.qr_code ?? ""
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
        
    }
    
    // MARK: - FollowSalonBtn
    @IBAction func FollowBtn_pressed(_ sender: Any) {
        if User.shared.isLogedIn() {
            HUD.show(.progress , onView: view)
            if FollowBtn.titleLabel?.text == "Follow" {
                FollowSalon(follow: true, id: "\(SalonID)")
            }else {
                FollowSalon(follow: false, id: "\(SalonID)")
            }
        }else {
            if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                HUD.flash(.label("Login required to Follow the salon") , onView: self.view , delay: 1.6 , completion: nil)
            }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                HUD.flash(.label("للمتابعة .. يجب تسجيل الدخول اولاً") , onView: self.view , delay: 1.6 , completion: nil)
            }
        }
        
    }
    
    
    // MARK: - SocialMediaBtns
    @IBAction func BrowserBtn_pressed(_ sender: Any) {
        OpenLink(link: salonAbout.data?.social_media?.website ?? "")
    }

    @IBAction func Youtube_pressed(_ sender: Any) {
        OpenLink(link: salonAbout.data?.social_media?.youtube ?? "")
    }
    
    
    @IBAction func SnapCharBtn_pressed(_ sender: Any) {
        OpenLink(link: salonAbout.data?.social_media?.snapchat ?? "")

    }
    
    @IBAction func FacebookBtn_pressed(_ sender: Any) {
        OpenLink(link: salonAbout.data?.social_media?.facebook ?? "")

    }
    
    
    @IBAction func TwitterBtn_pressed(_ sender: Any) {
        OpenLink(link: salonAbout.data?.social_media?.twitter ?? "")

    }
    

    @IBAction func InstgramBtn_pressed(_ sender: Any) {
        OpenLink(link: salonAbout.data?.social_media?.instagram ?? "")

    }
    
    
    @IBAction func WhatsAppBtn_pressed(_ sender: Any) {
        OpenLink(link: salonAbout.data?.social_media?.whatsapp ?? "")

    }
    
    
    @IBAction func MailBtn_pressed(_ sender: Any) {
        open_email(email: salonAbout.data?.social_media?.email ?? "")
    }
    
    
    @IBAction func PinBtn_pressed(_ sender: Any) {
        
        if User.shared.isLogedIn() {
            HUD.show(.progress , onView: view)
            PinSalon()
        }else {
            if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                HUD.flash(.label("Login required to Check in the salon") , onView: self.view , delay: 1.6 , completion: nil)
            }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                HUD.flash(.label("للمتابعة .. يجب تسجيل الدخول اولاً") , onView: self.view , delay: 1.6 , completion: nil)
            }
        }
        
    }
    
    
    func OpenLink(link:String) {
        
        guard let url = URL(string: link)  else { return }
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func open_email(email: String){
        
        guard let url = URL(string: "mailto:\(email)")  else { return }
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    // MARK: - RatingBtns
    
    @IBAction func AddRatingBtn_pressed(_ sender: Any) {
        if User.shared.isLogedIn() {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddSalonReviewVC") as! AddSalonReviewVC
            vc.salonId = "\(SalonID)"
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func RatingBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReviewsVC") as! ReviewsVC
        vc.salonID = "\(SalonID)"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func MapBtn_pressed(_ sender: Any) {
        
        if self.salonAbout.data?.main_branch?.lat ?? "" != "" && self.salonAbout.data?.main_branch?.long ?? "" != "" {
            
            let lat = round(1000*Double(self.salonAbout.data?.main_branch?.lat ?? "")!)/1000
            let lon =  round(1000*Double(self.salonAbout.data?.main_branch?.long ?? "")!)/1000
            if (UIApplication.shared.canOpenURL(NSURL(string:"https://maps.google.com")! as URL))
            {
                UIApplication.shared.openURL(NSURL(string:
                    "https://maps.google.com/?q=\(lat ?? Double()),\(lon ?? Double())")! as URL)
            }
        }
        
    }
    
    
    @IBAction func PhoneBtn_pressed(_ sender: Any) {
        let url: NSURL = URL(string: "TEL://\(self.salonAbout.data?.main_branch?.phone ?? "")")! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    
    
}


extension CenterAboutVC {
   
    // MARK: - CenterAbout_API
    func GetCenterAboutData() {
        let FinalURL = "\(ApiManager.Apis.SalonAbout.description)"
        var params = [String():String()]
        if User.shared.isLogedIn() {
            params = ["salon_id":"\(SalonID)", "user_hash_id": User.shared.TakeHashID()]
        }else {
            params = ["salon_id":"\(SalonID)" , "user_hash_id": "0"]
        }
        
        ApiManager.shared.ApiRequest(URL: FinalURL, method: .post, parameters: params ,encoding: URLEncoding.default, Header:["Accept": "application/json" , "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view)  { (data, tmp) in
            
            if tmp == nil {
                HUD.hide()
                do {
                    self.Requested = true
                    self.salonAbout = try JSONDecoder().decode(SalonAbout.self, from: data!)
                    
                    let taps = self.salonAbout.data?.package_roles
                    //TODO: - Send notification to SalonProfileRoot with (show tabs)
                    NotificationCenter.default.post(name: .visible_tabs, object: nil, userInfo: ["data":taps])
                    ////
                    self.GalleryCollection.reloadData()
                    self.Specialists.reloadData()
                    self.TutorialCollection.reloadData()
                    self.FeaturesCollection.reloadData()
                    self.followersCollection.reloadData()
                    self.BranchesCollection.reloadData()
                    
                    
                    self.SetImage(image: self.SalonIcon, link: self.salonAbout.data?.about?.salon_logo ?? "")
                    self.SalonName.text = self.salonAbout.data?.about?.salon_name ?? ""
                    self.SalonCategory.text = self.salonAbout.data?.about?.category?.category_name ?? ""
                    self.SalonRateStars.value = CGFloat(truncating: NumberFormatter().number(from: self.salonAbout.data?.about?.rate ?? "") ?? 0)
                    if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                        self.servicesCountLbl.text = "\(self.salonAbout.data?.about?.services_count ?? Int()) Services"
                        self.OfferCountLbl.text = "\(self.salonAbout.data?.about?.offers_count ?? Int()) Offers"
                        self.ProductCountLbl.text = "\(self.salonAbout.data?.about?.products_count ?? Int()) Products"
                        self.AboutLbl.text = "\(self.salonAbout.data?.about?.salon_description ?? "")"
                        self.RateCount.text = "\(self.salonAbout.data?.about?.rate_count ?? "") ratings"
                        
                    }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                        self.servicesCountLbl.text = "\(self.salonAbout.data?.about?.services_count ?? Int()) الخدمات"
                        self.OfferCountLbl.text = "\(self.salonAbout.data?.about?.offers_count ?? Int()) العروض"
                        self.ProductCountLbl.text = "\(self.salonAbout.data?.about?.products_count ?? Int()) منتجات"
                        self.AboutLbl.text = "\(self.salonAbout.data?.about?.salon_description ?? "")"
                        self.RateCount.text = "\(self.salonAbout.data?.about?.rate_count ?? "") التقييمات"
                    }
                    
                    
                    if self.AboutLbl.text == "" {
//                        self.AboutHeight.constant = 0
                        self.AboutTitle.isHidden = true
                        self.AboutTitleHeight.constant = 0
                    }
                    
                    self.SetImage(image: self.VerifyImage, link: self.salonAbout.data?.about?.verify_image ?? "")
                    
                    self.FollowBtn.isHidden = false
                    self.followersCount.text = "\(self.salonAbout.data?.about?.followers ?? Int())"
                  
                    if User.shared.isLogedIn() {
                        if self.salonAbout.data?.is_follower == 0 {
                            self.FollowBtn.setTitle(NSLocalizedString("Follow", comment: ""), for: .normal)
                        }else if self.salonAbout.data?.is_follower == 1 {
                            self.FollowBtn.setTitle(NSLocalizedString("Unfollow", comment: ""), for: .normal)
                        }
                    }
                    
                    
                    if self.salonAbout.data?.about?.sliders?.count ?? 0 > 0 {
                        self.SetUpSlideShow(slider: true)
                    }else {
                        self.SetUpSlideShow(slider: false)
                    }
                    
                    
                    let social = self.salonAbout.data?.social_media
                    if social?.facebook != "" && social?.facebook != nil  {
                        self.FacebookBtn.isHidden = false
                    }
                    if social?.twitter != "" && social?.twitter != nil {
                        self.TwitterBtn.isHidden = false
                    }
                    if social?.instagram != "" && social?.instagram != nil {
                        self.InstgramBtn.isHidden = false
                    }
                    if social?.whatsapp != "" && social?.whatsapp != nil {
                        self.WhatsAppBtn.isHidden = false
                    }
                    if social?.snapchat != "" && social?.snapchat != nil{
                        self.SnapChatBtn.isHidden = false
                    }
                    if social?.website != "" && social?.website != nil  {
                        self.BrowserBtn.isHidden = false
                    }
                    if social?.email != "" && social?.email != nil  {
                        self.MailBtn.isHidden = false
                    }
                    if social?.youtube != "" && social?.youtube != nil {
                        self.youtubeBtn.isHidden = false
                    }
                    
                    if social  == nil {
                        self.socialsViewHeight.constant = 0
                    }
                    
                    self.Rate.text = self.salonAbout.data?.about?.rate ?? ""
                  
                    self.MainBranchLocation.text = self.salonAbout.data?.main_branch?.address ?? ""
                    
                    self.MainBranchName.text = self.salonAbout.data?.main_branch?.branch_name ?? ""
                    
                    if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                        self.toArabic.ReverseCollectionDirection(collectionView: self.BranchesCollection)
                         self.toArabic.ReverseCollectionDirection(collectionView: self.Specialists)
                    }
                    
                    if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                        if self.salonAbout.data?.main_branch?.work_times?.count ?? 0 > 0 {
                            self.MainBranchWorkTime.text = "Working Hours: \(self.salonAbout.data?.main_branch?.work_times?[0].open_from ?? "") to \(self.salonAbout.data?.main_branch?.work_times?[0].open_to ?? "")"
                            
                            if self.salonAbout.data?.main_branch?.work_times?[0].is_open_now == 0 {
                                self.is_openSalon.text = "Closed"
                            }else {
                                self.is_openSalon.text = "Open"
                            }
                        }
                        
                    }else  if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                        
                        if self.salonAbout.data?.main_branch?.work_times?.count ?? 0 > 0 {
                            self.MainBranchWorkTime.text = "ساعات العمل: \(self.salonAbout.data?.main_branch?.work_times?[0].open_from ?? "") إلى \(self.salonAbout.data?.main_branch?.work_times?[0].open_to ?? "")"
                            
                            if self.salonAbout.data?.main_branch?.work_times?[0].is_open_now == 0 {
                                self.is_openSalon.text = "مغلق"
                            }else {
                                self.is_openSalon.text = "مفتوح"
                            }
                        }
                    }
                    
                    if ((self.salonAbout.data?.main_branch?.lat) == nil) {
                        self.MainBranchMap.isHidden = true
                    }
                    
                    
                    if self.salonAbout.data?.is_visited ?? Int() == 0 {
                            self.PinBtn.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                    }else {
                            self.PinBtn.backgroundColor = #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)
                    }
                    
                    if ((self.salonAbout.data?.main_branch?.phone ?? "") == nil || (self.salonAbout.data?.main_branch?.phone ?? "") == "") {
                        self.MainBranch_phoneBtn.isHidden = true
                    }
                   
                    
                    let camera = GMSCameraPosition.camera(withLatitude: Double (self.salonAbout.data?.main_branch?.lat ?? "") ?? Double(), longitude: Double (self.salonAbout.data?.main_branch?.long ?? "") ?? Double(), zoom: 16.0)
                    let mapView = GMSMapView.map(withFrame: self.MainBranchMap.bounds, camera: camera)
                    self.MainBranchMap.addSubview(mapView)
                    
                    let marker = GMSMarker()
                    
                    // I have taken a pin image which is a custom image
                    let markerImage = self.SalonIcon.image?.withRenderingMode(.automatic)
                    
                    //creating a marker view
                    let markerView = UIImageView(image: markerImage)
                    
                    markerView.contentMode = .scaleAspectFit
                    markerView.clipsToBounds = true
                    markerView.frame = CGRect(x: markerView.frame.origin.x , y: markerView.frame.origin.x, width: 30, height: 30)
                    markerView.cornerRadius = 15
                    marker.position = CLLocationCoordinate2D(latitude: Double(self.salonAbout.data?.main_branch?.lat ?? "") ?? Double(), longitude: Double(self.salonAbout.data?.main_branch?.long ?? "") ?? Double())
                    
                    marker.iconView = markerView
                    marker.title = self.SalonName.text
                    marker.snippet = self.salonAbout.data?.main_branch?.city?.city_name ?? ""
                    marker.map = mapView
                    
                    mapView.selectedMarker = marker
                   
                    self.mainView.isHidden = true
                    self.mainView.isShimmering = false
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                keyWindow?.rootViewController = vc
                
            }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.GetCenterAboutData()
                }
                self.present(vc, animated: true, completion: nil)
            }
            
        }
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage: UIImage(), options: .highPriority , completed: nil)
    }
    
    
    // MARK: - FollowSalon_API
    func FollowSalon(follow:Bool , id:String) {
        var FinalURL = ""
        if follow {
            FinalURL = ApiManager.Apis.FollowSalon.description
        }else {
            FinalURL = ApiManager.Apis.unfollowSalon.description
        }
        
        let t = User.shared.TakeToken()
        if User.shared.isLogedIn() {
            ApiManager.shared.ApiRequest(URL: FinalURL, method: .post, parameters: ["salon_id": id], encoding: URLEncoding.default, Header: ["Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ] , ExtraParams: "", view: self.view) { (data, tmp) in
                
                if tmp == nil {
                    HUD.hide()
                    do {
                        self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                        HUD.flash(.label("\(self.success.msg?[0] ?? "Success")") , onView: self.view , delay: 1.6 , completion: {
                            (tmp) in
                            if self.FollowBtn.titleLabel?.text == "Follow" {
                                self.FollowBtn.setTitle("Unfollow", for: .normal)
                            }else {
                                self.FollowBtn.setTitle("Follow", for: .normal)
                            }
                        })
                        
                    }catch {
                        HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                    }
                    
                }else if tmp == "401" {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
        }
    }
    
    
    // MARK: - PinSalon_API
    func PinSalon() {
        let FinalURL =  ApiManager.Apis.AddDeleteVisitSalon.description
        let params  = ["salon_id":"\(SalonID)" , "action_type" : "\(salonAbout.data?.is_visited ?? Int())"]
        if User.shared.isLogedIn() {
            ApiManager.shared.ApiRequest(URL: FinalURL, method: .post, parameters: params, encoding: URLEncoding.default, Header: ["Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ] , ExtraParams: "", view: self.view) { (data, tmp) in
                
                if tmp == nil {
                    HUD.hide()
                    do {
                        self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                        HUD.flash(.label("\(self.success.msg?[0] ?? "Success")") , onView: self.view , delay: 1.6 , completion: {
                            (tmp) in
                            
                            if self.salonAbout.data?.is_visited ?? Int() == 0 {
                                self.PinBtn.backgroundColor = #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)
                            }else {
                                self.PinBtn.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                            }
                            
                            self.GetCenterAboutData()
                        })
                        
                    }catch {
                        HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                    }
                    
                }else if tmp == "401" {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
        }
    }
    
    
    
    
}

// MARK: - CollectionViewDelegate
extension CenterAboutVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        if collectionView == GalleryCollection {
            let c = salonAbout.data?.about?.albums_images?.count ?? 0
            
            if c == 0 {
                if Requested {
                    GalleryHeight.constant = 0
                }
                return c
            }
            return salonAbout.data?.about?.albums_images?.count ?? 0
        }
        
        
        if collectionView == TutorialCollection {
            let c = salonAbout.data?.about?.albums_videos?.count ?? 0

            if c == 0 {
                if Requested {
                    VideosHeight.constant = 0
                }
                return c
            }
            return salonAbout.data?.about?.albums_videos?.count ?? 0
        }
        
        
        
        if collectionView == Specialists {
            let c  = salonAbout.data?.about?.employees?.count ?? 0
            
            if c == 0 {
                if Requested {
                    SpeciallistHeight.constant = 0
                }
                return c
            }
            return salonAbout.data?.about?.employees?.count ?? 0
        }
        
        
        
        if collectionView == FeaturesCollection {
            let c = salonAbout.data?.about?.features?.count ?? 0
            
            if c == 0 {
                if Requested {
                    FeaturesHeight.constant = 0
                }
                return c
            }
            return salonAbout.data?.about?.features?.count ?? 0
        }
        
        if collectionView == followersCollection {
            return salonAbout.data?.about?.followers_list?.count ?? 0
        }
        
        if collectionView == BranchesCollection {
            return salonAbout.data?.branches?.count ?? 0
        }
        
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == GalleryCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServcisesCollCell", for: indexPath) as? ServcisesCollCell {
                
                cell.UpdateView_center(album: salonAbout.data?.about?.albums_images?[indexPath.row] ?? SalonAlbum())
                
                return cell
            }
        }
        
        if collectionView == TutorialCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServcisesCollCell", for: indexPath) as? ServcisesCollCell {

                cell.UpdateView_center(album: salonAbout.data?.about?.albums_videos?[indexPath.row] ?? SalonAlbum())
                
                return cell
            }
        }
        
        if collectionView == Specialists {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BestSpecialistCollCell", for: indexPath) as? BestSpecialistCollCell {
                
                cell.UpdateView(employee: salonAbout.data?.about?.employees?[indexPath.row] ?? Employee())
                
                return cell
            }
        }
        
        if collectionView == FeaturesCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CenterFeaturesCollCell", for: indexPath) as? CenterFeaturesCollCell {
                
                cell.UpdateView(image: salonAbout.data?.about?.features?[indexPath.row].image ?? "" , title:salonAbout.data?.about?.features?[indexPath.row].feature_name ?? "")
                
                return cell
            }
        }
        
        if collectionView == followersCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PeopleCollCell", for: indexPath) as? PeopleCollCell {
                
                cell.UpdateView(person: salonAbout.data?.about?.followers_list?[indexPath.row] ?? Person())
                
                return cell
            }
        }
        
        
        if collectionView == BranchesCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CenterBranchesCollCell", for: indexPath) as?
                CenterBranchesCollCell {
            
                cell.UpdateView(branch: salonAbout.data?.branches?[indexPath.row] ?? SalonBranch(), mainBranchIcon: self.SalonIcon.image ?? #imageLiteral(resourceName: "LogoPlaceholder"))
                
                return cell
            }
        }
        
        
        
        return ForYouCollCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        if collectionView == GalleryCollection ||  collectionView == TutorialCollection   {
            let height:CGSize = CGSize(width: self.GalleryCollection.frame.width/2.3 , height: self.GalleryCollection.frame.height)
            
            return height
        }
        
        if collectionView == Specialists {
            let height:CGSize = CGSize(width: self.Specialists.frame.width/3.2 , height: self.Specialists.frame.height)
            
            return height
        }
        
        if collectionView == FeaturesCollection {
            let height:CGSize = CGSize(width: self.FeaturesCollection.frame.width/5.2 , height: self.FeaturesCollection.frame.height)
            
            return height
        }
        
        if collectionView == followersCollection {
            let height:CGSize = CGSize(width: self.followersCollection.frame.width/9 , height: self.followersCollection.frame.height)
            
            return CGSize(width: 50, height: 50);
        }
        
        if collectionView == BranchesCollection {
            let height:CGSize = CGSize(width: self.BranchesCollection.frame.width/1.1 , height: self.BranchesCollection.frame.height)
    
            return height
        }
        
        
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        if collectionView == followersCollection {
            return 0
        }
        
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if collectionView == followersCollection {
            return -20
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == GalleryCollection {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SalonAlbumVC") as! SalonAlbumVC
            
            vc.album_id = "\(salonAbout.data?.about?.albums_images?[indexPath.row].id ?? Int())"
            vc.type = salonAbout.data?.about?.albums_images?[indexPath.row].type ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
        if collectionView == TutorialCollection {
           let vc = self.storyboard?.instantiateViewController(withIdentifier: "SalonAlbumVC") as! SalonAlbumVC
                      
                vc.album_id = "\(salonAbout.data?.about?.albums_videos?[indexPath.row].id ?? Int())"
                vc.type = salonAbout.data?.about?.albums_videos?[indexPath.row].type ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
        // To be update: Add followersColleciton for follower's profile
        
    }
    
}




