//
//  ProfileVC.swift
//  BeautySalon
//
//  Created by Islam Elgaafary on 10/13/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD
import ViewAnimator
import Alamofire
import SDWebImage
import MOLH

class ProfileVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var ProfileImage: UIImageView!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var FriendsCount: UILabel!
    @IBOutlet weak var FollowersCount: UILabel!
    @IBOutlet weak var FollowingCount: UILabel!
    @IBOutlet weak var FavoritesCount: UILabel!
    @IBOutlet weak var OrdersCount: UILabel!
    @IBOutlet weak var ReservationsCount: UILabel!
    @IBOutlet weak var ReservationImage: UIImageView!
    @IBOutlet weak var ReservationName: UILabel!
    @IBOutlet weak var ReservationDescription: UILabel!
    @IBOutlet weak var ReservationPrice: UILabel!
    @IBOutlet weak var ReservationDuration: UILabel!
    @IBOutlet weak var salonImage: UIImageView!
    @IBOutlet weak var salonName: UILabel!
    @IBOutlet weak var salonCity: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var employee: UILabel!
  //  @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var ViewAllBtn: UIButton!
    @IBOutlet weak var FollowBtn: UIButton!
    @IBOutlet weak var ordersView: UIView!
    @IBOutlet weak var reservationView: UIView!
    @IBOutlet weak var walletView: UIView!
    @IBOutlet weak var eventView: UIView!
    @IBOutlet weak var collectionView: UIView!
    
    @IBOutlet weak var countsDataView: UIView!
    @IBOutlet weak var profileOptionsView: UIView!
    @IBOutlet weak var galleryView: UIView!
    
    @IBOutlet weak var barItem_sideMenuBtn: UIBarButtonItem!
    @IBOutlet weak var comingReservation_view: UIView!
    
    // MARK: - Variables
    var profile = Profile()
    let toArabic = ToArabic()
    var success = ErrorMsg()
    var FriendProfile = false
    let imagePicker = UIImagePickerController()
    var dataImage : [Data] = []
    var requested = false
    var userID = ""
    var router: RouterManager!
    
    // MARK: - IBOutlet
    override func viewDidLoad() {
        super.viewDidLoad()
       // setTransparentNavagtionBar()
        router = RouterManager(self)
      setCustomNavagationBar()
//        mainView.contentView = logo
//        mainView.isShimmering = true
//        mainView.shimmeringSpeed = 550
//        mainView.shimmeringOpacity = 1
        
        if FriendProfile {
            navigationItem.leftBarButtonItems = []//barItem_backPressed
            GetFriendProfileData()
            FollowBtn.isHidden = false
            ordersView.isHidden = true
            reservationView.isHidden = true
            walletView.isHidden = true
            eventView.isHidden = true
            collectionView.isHidden = true
            galleryView.isHidden = true
            comingReservation_view.isHidden = true
        }else {
            GetProfileData()
            FollowBtn.isHidden = true
            ordersView.isHidden = false
            reservationView.isHidden = false
            walletView.isHidden = false
            eventView.isHidden = false
            collectionView.isHidden = false
            galleryView.isHidden = false
         }
       self.comingReservation_view.isHidden = true

    }
}

extension ProfileVC{
    
    @IBAction func openSideMenu(_ button: UIButton){
        Vrou.openSideMenu(vc: self)
    }
   
     // MARK: - MyReservationsBtn
    @IBAction func MyReservationsBtn_pressed(_ sender: UIButton) {
        let vc =  View.ScheduledReservationsVC.identifyViewController(viewControllerType: ScheduledReservationsVC.self)
        router.push(controller: vc)
    }
     // MARK: - MyPurchsesBtn
    @IBAction func MyPurchasesBtn_pressed(_ sender: Any) {
        let vc =  View.MyPurchasesVC.identifyViewController(viewControllerType: MyPurchasesVC.self)
        router.push(controller: vc)
    }
     // MARK: - MyFavoritesBtn
    @IBAction func MyFavoritesBtn_pressed(_ sender: Any) {
        let vc =  View.MyFavouritesVC.identifyViewController(viewControllerType: MyFavouritesVC.self)
              router.push(controller: vc)
    }
    // MARK: - Btns functions
    @IBAction func FollowBtn_pressed(_ sender: Any) {
        
        if profile.data?.user?.following_status == 0 {
            FollowFriend(userID: "\(profile.data?.user?.id ?? Int())", follow: "\(0)")
        }else if profile.data?.user?.following_status == 2 {
            FollowFriend(userID: "\(profile.data?.user?.id ?? Int())", follow: "\(1)")
        }
    }
    
    @IBAction func CollectionsBtn_pressed(_ sender: Any) {
        let vc =  View.CollectionVC.identifyViewController(viewControllerType: CollectionVC.self)
        router.push(controller: vc)
    }
    
    
    @IBAction func ReviewsBtn_pressed(_ sender: Any) {
        let vc =  View.UserReviewsVC.identifyViewController(viewControllerType: UserReviewsVC.self)
        if self.profile.data?.user?.following_status == 2 {
            vc.FriendReviews = true
            vc.friendUserID = "\(self.profile.data?.user?.id ?? Int())"
        }
        router.push(controller: vc)
    }
    
    @IBAction func PinInBtn_pressed(_ sender: Any) {
        let vc =  View.PinInVC.identifyViewController(viewControllerType: PinInVC.self)
        if self.profile.data?.user?.following_status == 2 {
            vc.FriendPins = true
            vc.friendUserID = "\(self.profile.data?.user?.id ?? Int())"
        }
        router.push(controller: vc)
    }
    
    @IBAction func WalletBtn_QRBtn_pressed(_ sender: UIButton) {
        let vc =  View.ProfileQrVC.identifyViewController(viewControllerType: ProfileQrVC.self)
              vc.QrCodeLink = profile.data?.user?.qr_code ?? ""
              vc.QrCodeString = profile.data?.user?.user_number ?? ""
              vc.ProfileImage = profile.data?.user?.image ?? ""
              vc.ProfileName = profile.data?.user?.name ?? ""
              vc.City = profile.data?.user?.city?.city_name ?? ""
              vc.credit = "\(profile.data?.user?.credit ?? "") \(profile.data?.user?.currency ?? "")"
              vc.modalPresentationStyle = .overCurrentContext
        router.present(controller: vc)
    }

    // MARK: - EditProfileBtn
       @IBAction func EditProfileBtn_pressed(_ sender: Any) {
        let vc =  View.EditAccountVC.identifyViewController(viewControllerType: EditAccountVC.self)
        router.push(controller: vc)
       }
       
    @IBAction func OpenUserGallery_pressed(_ sender: Any) {
        let vc =  View.UserProfileGallaryVC.identifyViewController(viewControllerType: UserProfileGallaryVC.self)
        vc.FriendProfile = FriendProfile
        vc.userID = userID
        router.push(controller: vc)
    }
       // MARK: - EventsBtn
       @IBAction func EventsBtnPressed(_ sender: Any) {
        let vc =  View.EventsVC.identifyViewController(viewControllerType: EventsVC.self)
        router.push(controller: vc)
       }
     @IBAction func openPopupMenu(_ sender: Any) {
        let vc = View.salonProfileSettingsPopUp.identifyViewController(viewControllerType: SalonProfileSettingsPopUp.self)
        vc.user = self.profile.data?.user
        vc.friendProfile = FriendProfile
        vc.parentView = self
        RouterManager(self).present(controller: vc)
    }
}

extension ProfileVC {
     // MARK: - API Requests
    func GetProfileData() {
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.profile.description , method: .get, Header: ["Authorization": "Bearer \(User.shared.TakeToken())",
            "Accept": "application/json",
            "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
                if tmp == nil {
                    HUD.hide()
                    do {
                        self.profile = try JSONDecoder().decode(Profile.self, from: data!)
                        self.SetImage(image: self.ProfileImage, link: self.profile.data?.user?.image ?? "")
                        self.Name.text = self.profile.data?.user?.name ?? ""
                        self.city.text = self.profile.data?.user?.city?.city_name ?? ""
                        self.FriendsCount.text = self.profile.data?.user?.friends ?? "0"
                        self.FollowersCount.text = self.profile.data?.user?.followers ?? "0"
                        self.FollowingCount.text = self.profile.data?.user?.following_count ?? "0"
                        self.FavoritesCount.text = self.profile.data?.user?.favorites_count ?? "0"
                        self.OrdersCount.text = self.profile.data?.user?.orders_count ?? "0"
                        self.ReservationsCount.text = self.profile.data?.user?.reservations_count ?? "0"
                        
                        if self.profile.data?.user?.coming_service != nil{
                            self.SetImage(image: self.ReservationImage, link: self.profile.data?.user?.coming_service?.service?.image ?? "")
                            self.ReservationName.text = self.profile.data?.user?.coming_service?.service?.service_name ?? ""
                            self.ReservationDescription.text = self.profile.data?.user?.coming_service?.service?.service_description ?? ""
                            self.SetImage(image: self.salonImage, link: self.profile.data?.user?.coming_service?.salon_logo ?? "")
                            self.salonName.text = self.profile.data?.user?.coming_service?.salon_name ?? ""
                            self.salonCity.text = self.profile.data?.user?.coming_service?.city ?? ""
                            self.Date.text = self.profile.data?.user?.coming_service?.service_date ?? ""
                            self.time.text = self.profile.data?.user?.coming_service?.service_time ?? ""
                            self.employee.text = self.profile.data?.user?.coming_service?.employee?.employee_name ?? ""
                           
                            self.ReservationDuration.text = "\(self.profile.data?.user?.coming_service?.service?.service_duration ?? "0") mins"
                            self.ReservationPrice.text = "\(self.profile.data?.user?.coming_service?.price ?? "") \(self.profile.data?.user?.coming_service?.currency_name ?? "")"
                            self.comingReservation_view.isHidden = false
                        }else {
//                            self.CommingServiceHeight.constant = 0
//                            self.CommingServiceLblHeight.constant = 0
//                            self.ViewAllHeight.constant = 0
//                            self.ViewAllBtn.isHidden = true
                            self.comingReservation_view.isHidden = true

                        }
//                        self.mainView.isHidden = true
//                        self.mainView.isShimmering = false
                        self.requested = true
                    }catch {
                        HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                    }
                    
                }else if tmp == "401" {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    keyWindow?.rootViewController = vc
                    
                }else if tmp == "NoConnect" {
                    guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                    vc.callbackClosure = { [weak self] in
                        self?.GetProfileData()
                    }
                    self.present(vc, animated: true, completion: nil)
                }
                
        }
    }
    
    func GetFriendProfileData() {
        ApiManager.shared.ApiRequest(URL: "\(ApiManager.Apis.UserProfile.description)\(userID)" , method: .get, Header: ["Authorization": "Bearer \(User.shared.TakeToken())",
            "Accept": "application/json",
            "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
                if tmp == nil {
                    HUD.hide()
                    do {
                        self.profile = try JSONDecoder().decode(Profile.self, from: data!)
                        self.SetImage(image: self.ProfileImage, link: self.profile.data?.user?.image ?? "")
                        
                        self.Name.text = self.profile.data?.user?.name ?? ""
                        self.city.text = self.profile.data?.user?.city?.city_name ?? ""
                        self.FriendsCount.text = self.profile.data?.user?.friends ?? "0"
                        self.FollowersCount.text = self.profile.data?.user?.followers ?? "0"
                        self.FollowingCount.text = self.profile.data?.user?.following_count ?? "0"
                        self.FavoritesCount.text = self.profile.data?.user?.favorites_count ?? "0"
                        self.OrdersCount.text = self.profile.data?.user?.orders_count ?? "0"
                        self.ReservationsCount.text = self.profile.data?.user?.reservations_count ?? "0"
//                        
//                        self.mainView.isHidden = true
//                        self.mainView.isShimmering = false
                        self.requested = true
                        
                        self.FollowBtn.setTitle(self.profile.data?.user?.following_status_message ?? "", for: .normal)
                        
                        if self.profile.data?.user?.following_status == 0 || self.profile.data?.user?.following_status == 1 { // pending OR unfriend profile
                            self.countsDataView.isHidden = true
                         //   self.profileOptionsView.isHidden = true
                            self.galleryView.isHidden = true
                          //  self.scrollView.isScrollEnabled = false
                        }
                        
                        if self.profile.data?.user?.following_status == 2 { // Fried profile
                            self.countsDataView.isHidden = false
                       //     self.profileOptionsView.isHidden = false
                            self.galleryView.isHidden = false
                        //    self.scrollView.isScrollEnabled = true
                        }
                    }catch {
                        HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                    }
                    
                }else if tmp == "401" {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    keyWindow?.rootViewController = vc
                    
                }else if tmp == "NoConnect" {
                    guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                    vc.callbackClosure = { [weak self] in
                        self?.GetProfileData()
                    }
                    self.present(vc, animated: true, completion: nil)
                }
                
        }
    }
    
    
    func FollowFriend(userID:String , follow:String) // 0 OR 1 for follow/Unfollow
    {
          HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.FollowUnfollowUser.description, method: .post, parameters: ["user_id": userID , "action_type":follow], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                     ExtraParams: "", view: self.view) { (data, tmp) in
                           if tmp == nil {
                               HUD.hide()
                               do {
                                
                                self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
//
                                if follow == "1" {
                                    self.FollowBtn.setTitle("Unfollow", for: .normal)
                                }else if follow == "0" {
                                     self.FollowBtn.setTitle("Follow", for: .normal)
                                }
                                self.GetFriendProfileData()
                                
                               }catch {
                                   HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                               }
                               
                           }else if tmp == "401" {
                               let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                               keyWindow?.rootViewController = vc
                               
                           }
                           
                       }
                   }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
    }
}
     
