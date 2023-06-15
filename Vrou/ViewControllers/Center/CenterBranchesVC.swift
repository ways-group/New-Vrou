////
////  CenterBranchesVC.swift
////  BeautySalon
////
////  Created by MacBook Pro on 9/15/19.
////  Copyright © 2019 waysGroup. All rights reserved.
////
//
//import UIKit
//import MXParallaxHeader
//import ViewAnimator
//import Alamofire
//import SwiftyJSON
//import PKHUD
//import SDWebImage
//import GoogleMaps
//import SideMenu
//
//class CenterBranchesVC: UIViewController , MXParallaxHeaderDelegate , UIScrollViewDelegate {
//
//    // MARK: - IBOutlet
//    @IBOutlet var headerView: UIView!
//    @IBOutlet weak var BranchesCollection: UICollectionView!
//    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var PageControl: UIPageControl!
//    
//    @IBOutlet weak var MainBranchMap: GMSMapView!
//    @IBOutlet weak var MainBranchName: UILabel!
//    @IBOutlet weak var MainBranchLocation: UILabel!
//    @IBOutlet weak var MainBranchWorkTime: UILabel!
//    
//    @IBOutlet weak var SalonBackground: UIImageView!
//    @IBOutlet weak var SalonImage: UIImageView!
//    @IBOutlet weak var SalonName: UILabel!
//    
//    @IBOutlet weak var BrowserBtn: UIButton!
//    @IBOutlet weak var SnapChatBtn: UIButton!
//    @IBOutlet weak var FacebookBtn: UIButton!
//    @IBOutlet weak var TwitterBtn: UIButton!
//    @IBOutlet weak var InstgramBtn: UIButton!
//    @IBOutlet weak var WhatsAppBtn: UIButton!
//    @IBOutlet weak var MailBtn: UIButton!
//    @IBOutlet weak var youtubeBtn: UIButton!
//    
//    @IBOutlet weak var mainView: FBShimmeringView!
//    @IBOutlet weak var logo: UIImageView!
//    
//    @IBOutlet weak var is_openSalon: UILabel!
//    @IBOutlet weak var MainBranch_phoneBtn: UIButton!
//    
//   
//    
//    // MARK: - Variables
//    var itemSize = CGSize(width: 0, height: 0)
//    fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    
//    // CollectionViewsAnimationsParams
//    private var items = [Any?]()
//    private let animations = [AnimationType.from(direction: .left, offset: 60.0)]
//    
//    var SalonID = 1
//    var salonBranches = SalonBranches()
//    var tabs = [String]()
//    var uiSupport = UISupport()
//    var toArabic = ToArabic()
//    
//    // MARK: - viewDidLoad
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupSideMenu()
//        if let nav = self.navigationController {
//            uiSupport.TransparentNavigationController(navController: nav)
//        }
//        // Loading indicator setup
//        mainView.isHidden = false
//        mainView.contentView = logo
//        mainView.isShimmering = true
//        mainView.shimmeringSpeed = 550
//        mainView.shimmeringOpacity = 1
//        
//        SetUpCollectionView(collection: BranchesCollection)
//        //ScrollHraderSetup
//        scrollView.parallaxHeader.view = headerView
//        scrollView.parallaxHeader.height = 350
//        scrollView.parallaxHeader.mode = .bottom
//        scrollView.parallaxHeader.delegate = self
//        
//        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
//        
//        GetSalonBranchesData()
//    }
//    
//
//    func SetupAnimation() {
//        items = Array(repeating: nil, count: 1)
//        BranchesCollection?.performBatchUpdates({
//            UIView.animate(views: BranchesCollection.visibleCells,
//                           animations: animations,
//                           duration:0.5 )
//        }, completion: nil)
//        
//    }
//
//    
//    func SetUpCollectionView(collection:UICollectionView){
//        collection.delegate = self
//        collection.dataSource = self
//    }
//    
//     // MARK: - SetupSideMenu
//    private func setupSideMenu() {
//        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let sideMenuNavigationController = segue.destination as? SideMenuNavigationController else { return }
//        sideMenuNavigationController.settings = makeSettings()
//        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
//            sideMenuNavigationController.leftSide = false
//        }
//    }
//    
//    private func makeSettings() -> SideMenuSettings {
//        let presentationStyle = selectedPresentationStyle()
//        presentationStyle.menuStartAlpha = 1.0
//        presentationStyle.onTopShadowOpacity = 0.0
//        presentationStyle.presentingEndAlpha = 1.0
//        
//        var settings = SideMenuSettings()
//        settings.presentationStyle = presentationStyle
//        settings.menuWidth = min(view.frame.width, view.frame.height)  * 0.9
//        settings.statusBarEndAlpha = 0
//        
//        return settings
//    }
//    
//    private func selectedPresentationStyle() -> SideMenuPresentationStyle {
//        return .viewSlideOutMenuIn
//    }
//    
//     // MARK: - SetupSlider
//    func SetUpSlider(collection:UICollectionView) -> CGSize {
//        
//        if let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.minimumLineSpacing = 0
//            layout.minimumInteritemSpacing = 0
//        }
//        collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        collection.isPagingEnabled = false
//        loadViewIfNeeded()
//        
//        let width = collection.bounds.size.width-24
//        var height = CGFloat()
//        height = collection.bounds.size.height
//        
//        
//        itemSize = CGSize(width: width, height: height)
//        loadViewIfNeeded()
//        return itemSize
//
//    }
//        
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if scrollView == BranchesCollection {
//            let tt = ceil(scrollView.contentOffset.x) / (scrollView.frame.width)
//            var t = Int(ceil(scrollView.contentOffset.x) / (scrollView.frame.width))
//            
//            if (tt - floor(tt) > 0.000001) {
//                t = t+1
//            }
//            
//        PageControl.currentPage = t
//            
//        }
//        
//    }
//    
//    
//    
//    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        
//        if scrollView == BranchesCollection {
//            let pageWidth = itemSize.width
//            targetContentOffset.pointee = scrollView.contentOffset
//            var factor: CGFloat = 0.5
//            if velocity.x < 0 {
//                factor = -factor
//                print("right")
//            } else {
//                print("left")
//            }
//            
//            let a:CGFloat = scrollView.contentOffset.x/pageWidth
//            var index = Int( round(a+factor) )
//            if index < 0 {
//                index = 0
//            }
//            if index > (salonBranches.data?.branches?.count ?? 0)-1 {
//                index = (salonBranches.data?.branches?.count ?? 0)-1 
//            }
//            let indexPath = IndexPath(row: index, section: 0)
//            
//            if scrollView == BranchesCollection {
//                BranchesCollection?.scrollToItem(at: indexPath, at: .left, animated: true)
//            }
//            
//        }
//        
//    }
//    
//     // MARK: - PhoneBtn
//    @IBAction func PhoneBtn_pressed(_ sender: Any) {
//        let url: NSURL = URL(string: "TEL://\(self.salonBranches.data?.main_branch?.phone ?? "")")! as NSURL
//        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
//    }
//    
//     // MARK: - MapBtn
//    @IBAction func MapBtn_pressed(_ sender: Any) {
//        
//        if self.salonBranches.data?.main_branch?.lat ?? "" != "" && self.salonBranches.data?.main_branch?.long ?? "" != "" {
//            
//            let lat = round(1000*Double(self.salonBranches.data?.main_branch?.lat ?? "")!)/1000
//            let lon =  round(1000*Double(self.salonBranches.data?.main_branch?.long ?? "")!)/1000
//            if (UIApplication.shared.canOpenURL(NSURL(string:"https://maps.google.com")! as URL))
//            {
//                UIApplication.shared.openURL(NSURL(string:
//                    "https://maps.google.com/?q=\(lat ?? Double()),\(lon ?? Double())")! as URL)
//            }
//        }
//    }
//    
//    
//    // Footer Buttons clicks Handlers moved to SalonProfileRoot
//     // MARK: - SocialMediaBtns
//    @IBAction func BrowserBtn_pressed(_ sender: Any) {
//        OpenLink(link: salonBranches.data?.social_media?.website ?? "")
//    }
//
//    @IBAction func Youtube_pressed(_ sender: Any) {
//        OpenLink(link: salonBranches.data?.social_media?.youtube ?? "")
//    }
//    
//    
//    @IBAction func SnapCharBtn_pressed(_ sender: Any) {
//        OpenLink(link: salonBranches.data?.social_media?.snapchat ?? "")
//
//    }
//    
//    @IBAction func FacebookBtn_pressed(_ sender: Any) {
//        OpenLink(link: salonBranches.data?.social_media?.facebook ?? "")
//
//    }
//    
//    
//    @IBAction func TwitterBtn_pressed(_ sender: Any) {
//        OpenLink(link: salonBranches.data?.social_media?.twitter ?? "")
//
//    }
//    
//
//    @IBAction func InstgramBtn_pressed(_ sender: Any) {
//        OpenLink(link: salonBranches.data?.social_media?.instagram ?? "")
//
//    }
//    
//    
//    @IBAction func WhatsAppBtn_pressed(_ sender: Any) {
//        OpenLink(link: salonBranches.data?.social_media?.whatsapp ?? "")
//
//    }
//    
//    
//    @IBAction func MailBtn_pressed(_ sender: Any) {
//        open_email(email: salonBranches.data?.social_media?.email ?? "")
//    }
//    
//    
//    func OpenLink(link:String) {
//        
//        guard let url = URL(string: link)  else { return }
//        if UIApplication.shared.canOpenURL(url) {
//            if #available(iOS 10.0, *) {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            } else {
//                UIApplication.shared.openURL(url)
//            }
//        }
//    }
//    
//    func open_email(email: String){
//        
//        guard let url = URL(string: "mailto:\(email)")  else { return }
//        if UIApplication.shared.canOpenURL(url) {
//            if #available(iOS 10.0, *) {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            } else {
//                UIApplication.shared.openURL(url)
//            }
//        }
//    }
//
//
//
//}
//
//extension CenterBranchesVC {
//     // MARK: - SalonBranches_API
//    func GetSalonBranchesData() {
//        let FinalURL = "\(ApiManager.Apis.SalonBranches.description)\(SalonID)"
//        
//        ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: [ "Accept": "application/json",
//        "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
//            
//            if tmp == nil {
//                HUD.hide()
//                do {
//                    self.salonBranches = try JSONDecoder().decode(SalonBranches.self, from: data!)
//                    self.BranchesCollection.reloadData()
//                    self.MainBranchLocation.text = self.salonBranches.data?.main_branch?.address ?? ""
//                    self.SetImage(image: self.SalonBackground, link: self.salonBranches.data?.salon?.salon_background ?? "")
//                    self.SetImage(image: self.SalonImage, link: self.salonBranches.data?.salon?.salon_logo ?? "")
//                    self.SalonName.text = self.salonBranches.data?.salon?.salon_name ?? ""
//                    
//                    
//                    if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
//                        self.toArabic.ReverseCollectionDirection(collectionView: self.BranchesCollection)
//                    }
//                    
//                    if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
//                        if self.salonBranches.data?.main_branch?.work_times?.count ?? 0 > 0 {
//                            self.MainBranchWorkTime.text = "Working Hours: \(self.salonBranches.data?.main_branch?.work_times?[0].from ?? "") to \(self.salonBranches.data?.main_branch?.work_times?[0].to ?? "")"
//                            
//                            if self.salonBranches.data?.main_branch?.work_times?[0].is_open_now == 0 {
//                                self.is_openSalon.text = "Closed"
//                            }else {
//                                self.is_openSalon.text = "Open"
//                            }
//                        }
//                        
//                    }else  if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
//                        
//                        if self.salonBranches.data?.main_branch?.work_times?.count ?? 0 > 0 {
//                            self.MainBranchWorkTime.text = "ساعات العمل: \(self.salonBranches.data?.main_branch?.work_times?[0].from ?? "") إلى \(self.salonBranches.data?.main_branch?.work_times?[0].to ?? "")"
//                            
//                            if self.salonBranches.data?.main_branch?.work_times?[0].is_open_now == 0 {
//                                self.is_openSalon.text = "مغلق"
//                            }else {
//                                self.is_openSalon.text = "مفتوح"
//                            }
//                        }
//                    }
//                    
//                    if ((self.salonBranches.data?.main_branch?.lat) == nil) {
//                        self.MainBranchMap.isHidden = true
//                    }
//                    
//                    if ((self.salonBranches.data?.main_branch?.phone ?? "") == nil || (self.salonBranches.data?.main_branch?.phone ?? "") == "") {
//                        self.MainBranch_phoneBtn.isHidden = true
//                    }
//                    
//                    let social = self.salonBranches.data?.social_media
//                    if social?.facebook != "" && social?.facebook != nil  {
//                        self.FacebookBtn.isHidden = false
//                    }
//                    if social?.twitter != "" && social?.twitter != nil {
//                        self.TwitterBtn.isHidden = false
//                    }
//                    if social?.instagram != "" && social?.instagram != nil {
//                        self.InstgramBtn.isHidden = false
//                    }
//                    if social?.whatsapp != "" && social?.whatsapp != nil {
//                        self.WhatsAppBtn.isHidden = false
//                    }
//                    if social?.snapchat != "" && social?.snapchat != nil{
//                        self.SnapChatBtn.isHidden = false
//                    }
//                    if social?.website != "" && social?.website != nil  {
//                        self.BrowserBtn.isHidden = false
//                    }
//                    if social?.email != "" && social?.email != nil  {
//                        self.MailBtn.isHidden = false
//                    }
//                    if social?.youtube != "" && social?.youtube != nil {
//                        self.youtubeBtn.isHidden = false
//                    }
//                    
//                    
//                    
//                    let camera = GMSCameraPosition.camera(withLatitude: Double (self.salonBranches.data?.main_branch?.lat ?? "") ?? Double(), longitude: Double (self.salonBranches.data?.main_branch?.long ?? "") ?? Double(), zoom: 16.0)
//                    let mapView = GMSMapView.map(withFrame: self.MainBranchMap.bounds, camera: camera)
//                    self.MainBranchMap.addSubview(mapView)
//                    
//                    
//                    let marker = GMSMarker()
//                    
//                    // I have taken a pin image which is a custom image
//                    let markerImage = self.SalonImage.image?.withRenderingMode(.automatic)
//                    
//                    //creating a marker view
//                    let markerView = UIImageView(image: markerImage)
//                    
//                    markerView.contentMode = .scaleAspectFit
//                    markerView.clipsToBounds = true
//                    markerView.frame = CGRect(x: markerView.frame.origin.x , y: markerView.frame.origin.x, width: 30, height: 30)
//                    markerView.cornerRadius = 15
//                    marker.position = CLLocationCoordinate2D(latitude: Double(self.salonBranches.data?.main_branch?.lat ?? "") ?? Double(), longitude: Double(self.salonBranches.data?.main_branch?.long ?? "") ?? Double())
//                    
//                    marker.iconView = markerView
//                    marker.title = self.SalonName.text
//                    marker.snippet = self.salonBranches.data?.main_branch?.city?.city_name ?? ""
//                    marker.map = mapView
//                    
//                    mapView.selectedMarker = marker
//                    
//                    
//                    self.SetupAnimation()
//                    self.mainView.isHidden = true
//                    self.mainView.isShimmering = false
//                    
//                }catch {
//                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
//                }
//                
//            }else if tmp == "401" {
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
//                keyWindow?.rootViewController = vc
//                
//            }else if tmp == "NoConnect" {
//                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
//                vc.callbackClosure = { [weak self] in
//                    self?.GetSalonBranchesData()
//                }
//                self.present(vc, animated: true, completion: nil)
//            }
//            
//        }
//    }
//    
//    func SetImage(image:UIImageView , link:String) {
//        let url = URL(string:link )
//        image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
//    }
//    
//}
//
//
//
//
// // MARK: - CollectionViewDelegate
//extension CenterBranchesVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if collectionView == BranchesCollection {
//            return salonBranches.data?.branches?.count ?? 0
//        }
//        
//        return 5
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//        
//        if collectionView == BranchesCollection {
//            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CenterBranchesCollCell", for: indexPath) as? CenterBranchesCollCell {
//                
//                cell.UpdateView(branch: salonBranches.data?.branches?[indexPath.row] ?? SalonBranch(), mainBranchIcon: self.SalonImage.image ?? #imageLiteral(resourceName: "BeautyLogo"))
//                
//                return cell
//            }
//        }
//        
//        
//        return ForYouCollCell()
//    }
//    
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        if collectionView == BranchesCollection {
//            let height:CGSize = CGSize(width: self.BranchesCollection.frame.width , height: self.BranchesCollection.frame.height)
//            
//            
//            return SetUpSlider(collection: BranchesCollection)
//        }
//        
//        return CGSize()
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        
//        
//        return 0;
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        
//        return 0
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//    }
//    
//    
//}
