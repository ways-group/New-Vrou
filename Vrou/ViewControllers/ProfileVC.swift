//
//  ProfileVC.swift
//  BeautySalon
//
//  Created by Islam Elgaafary on 10/13/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import MXParallaxHeader
import SwiftyJSON
import PKHUD
import ViewAnimator
import Alamofire
import SDWebImage
import SideMenu
import MOLH
import BSImagePicker
import Photos
import AVKit


class ProfileVC: UIViewController , MXParallaxHeaderDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var headerView: UIView!
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
    @IBOutlet weak var ReservationPriceDuration: UILabel!
    @IBOutlet weak var salonImage: UIImageView!
    @IBOutlet weak var salonName: UILabel!
    @IBOutlet weak var salonCity: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var employee: UILabel!
    @IBOutlet weak var CommingServiceHeight: NSLayoutConstraint!
    @IBOutlet weak var CommingServiceLblHeight: NSLayoutConstraint!
    @IBOutlet weak var ViewAllHeight: NSLayoutConstraint!
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var ViewAllBtn: UIButton!
    @IBOutlet weak var MyPhotosCollection: UICollectionView!
    @IBOutlet weak var MyVideosCollection: UICollectionView!
    @IBOutlet weak var FollowBtn: UIButton!
    @IBOutlet weak var myPhotosHeight: NSLayoutConstraint!
    @IBOutlet weak var myvideosHieght: NSLayoutConstraint!
    
    @IBOutlet weak var ordersView: UIView!
    @IBOutlet weak var reservationView: UIView!
    
    @IBOutlet weak var walletView: UIView!
    @IBOutlet weak var eventView: UIView!
    @IBOutlet weak var collectionView: UIView!
    
    @IBOutlet weak var newPhotosBtn: UIButton!
    @IBOutlet weak var newVideosBtn: UIButton!
    
    @IBOutlet weak var countsDataView: UIView!
    @IBOutlet weak var profileOptionsView: UIView!
    @IBOutlet weak var myPhotosView: UIView!
    @IBOutlet weak var myVideosView: UIView!
    
    @IBOutlet weak var editProfileBtn: UIButton!
    @IBOutlet weak var sideMenuBtn: UIButton!
    
    
    // MARK: - Variables
    var profile = Profile()
    var uiSupport = UISupport()
    let toArabic = ToArabic()
    var success = ErrorMsg()
    var FriendProfile = false
    let imagePicker = UIImagePickerController()
    var dataImage : [Data] = []
    var requested = false
    
    var userID = ""
    
    // MARK: - IBOutlet
    override func viewDidLoad() {
        super.viewDidLoad()
        if let nav = self.navigationController {
            uiSupport.TransparentNavigationController(navController: nav)
        }
        
        imagePicker.delegate = self
        mainView.contentView = logo
        mainView.isShimmering = true
        mainView.shimmeringSpeed = 550
        mainView.shimmeringOpacity = 1
        // Parallax Header
        scrollView.parallaxHeader.view = headerView // You can set the parallax header view from the floating view
        scrollView.parallaxHeader.height = 500
        scrollView.parallaxHeader.mode = .center
        scrollView.parallaxHeader.delegate = self
        
        setupSideMenu()
        SetUpCollectionView(collection: MyPhotosCollection)
        SetUpCollectionView(collection: MyVideosCollection)
        
        if FriendProfile {
            GetFriendProfileData()
            FollowBtn.isHidden = false
            ordersView.isHidden = true
            reservationView.isHidden = true
            walletView.isHidden = true
            eventView.isHidden = true
            collectionView.isHidden = true
            newPhotosBtn.isHidden = true
            newVideosBtn.isHidden = true
            editProfileBtn.isHidden = true
            sideMenuBtn.isHidden = true
        }else {
            GetProfileData()
            FollowBtn.isHidden = true
            ordersView.isHidden = false
            reservationView.isHidden = false
            walletView.isHidden = false
            eventView.isHidden = false
            collectionView.isHidden = false
            newPhotosBtn.isHidden = false
            newVideosBtn.isHidden = false
        }
       
        // Do any additional setup after loading the view.
    }
    

    
    // setupCollectionView
    func SetUpCollectionView(collection:UICollectionView){
        collection.delegate = self
        collection.dataSource = self
    }
    
    // MARK: - setupSideMenu
    private func setupSideMenu() {
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sideMenuNavigationController = segue.destination as? SideMenuNavigationController else { return }
        sideMenuNavigationController.settings = makeSettings()
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            sideMenuNavigationController.leftSide = false
        }
    }
    
    private func makeSettings() -> SideMenuSettings {
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
    
    // MARK: - ImagePickerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            dataImage = [pickedImage.jpegData(compressionQuality: 0.2)!]
            print("%%%%%%")
            print(dataImage)
            //self.UploadMedia(url: ApiManager.Apis.uploadUserMedia.description)

        }else {
            let chosenVideo = info[UIImagePickerController.InfoKey.mediaURL] as! URL
            dataImage = [try! Data(contentsOf: chosenVideo, options: [])]
           // self.UploadMedia(url: ApiManager.Apis.uploadUserMedia.description, url2: chosenVideo)
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    

    
    
    
    // MARK: - ProfileQR_Btn
    @IBAction func ProfileQRBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileQrVC") as! ProfileQrVC
        vc.QrCodeLink = profile.data?.user?.qr_code ?? ""
        vc.QrCodeString = profile.data?.user?.user_number ?? ""
        vc.ProfileImage = profile.data?.user?.image ?? ""
        vc.ProfileName = profile.data?.user?.name ?? ""
        vc.City = profile.data?.user?.city?.city_name ?? ""
        vc.credit = "\(profile.data?.user?.credit ?? "") \(profile.data?.user?.currency ?? "")"
        vc.modalPresentationStyle = .overCurrentContext
        
        self.present(vc, animated: true, completion: nil)
    }
    
    
     // MARK: - MyReservationsBtn
    @IBAction func MyReservationsBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScheduledReservationsVC") as! ScheduledReservationsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
     // MARK: - MyPurchsesBtn
    @IBAction func MyPurchasesBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyPurchasesVC") as! MyPurchasesVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
     // MARK: - MyFavoritesBtn
    @IBAction func MyFavoritesBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyFavouritesVC") as! MyFavouritesVC
        self.navigationController?.pushViewController(vc, animated: true)
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
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CollectionVC") as! CollectionVC
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    
    @IBAction func ReviewsBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserReviewsVC") as! UserReviewsVC
        if self.profile.data?.user?.following_status == 2 {
            vc.FriendReviews = true
            vc.friendUserID = "\(self.profile.data?.user?.id ?? Int())"
        }
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    
    
    @IBAction func PinInBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PinInVC") as! PinInVC
        if self.profile.data?.user?.following_status == 2 {
            vc.FriendPins = true
            vc.friendUserID = "\(self.profile.data?.user?.id ?? Int())"
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func WalletBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileQrVC") as! ProfileQrVC
              vc.QrCodeLink = profile.data?.user?.qr_code ?? ""
              vc.QrCodeString = profile.data?.user?.user_number ?? ""
              vc.ProfileImage = profile.data?.user?.image ?? ""
              vc.ProfileName = profile.data?.user?.name ?? ""
              vc.City = profile.data?.user?.city?.city_name ?? ""
              vc.credit = "\(profile.data?.user?.credit ?? "") \(profile.data?.user?.currency ?? "")"
              vc.modalPresentationStyle = .overCurrentContext
              
           self.present(vc, animated: true, completion: nil)
    }
    
    
    
    @IBAction func NewPhotoBtn_pressed(_ sender: Any) {
        SelectImages()
    }
    
    
    @IBAction func NewVideoBtn_pressed(_ sender: Any) {
        SelectVideos()
    }
    
    func SelectImages()  {

        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 5
        imagePicker.albumButton.tintColor = UIColor.green
        imagePicker.cancelButton.tintColor = UIColor.red
        imagePicker.doneButton.tintColor = UIColor.purple
        imagePicker.doneButton.title = "Done"
        
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
        
        self.presentImagePicker(imagePicker, select: { (asset) in
            print("Selected: \(asset)")
             imagePicker.doneButton.title = "Done"
        }, deselect: { (asset) in
            print("Deselected: \(asset)")
             imagePicker.doneButton.title = "Done"
            }, cancel: { (assets) in
              print("Canceled with selections: \(assets)")
            }, finish: { (assets) in
                print("Finished with selections: \(assets)")
                
                var counter = 0
                
                // prepare selected photos for uploading...... [UIImage TO DATA]
                self.dataImage.removeAll()
                for i in assets {
                    
                    PHImageManager.default().requestImage(for: i, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil) { (image, info) in
                        
                        let degraded = info?[PHImageResultIsDegradedKey] as? Bool // To check if the real image (not the thunmbil) is choosen one
                        if degraded == nil || degraded == false {
                            self.dataImage.append((image?.jpegData(compressionQuality: 0.3))!)
                            counter+=1
                            if counter == assets.count {
                                self.UploadMedia(isImages: true)
                                return
                            }
                            
                        }
                        
                    }
                    
                }
                
        }, completion: {
            print("complete")
        })
        
        
          }

 
func SelectVideos()  {

         let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 5
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.video]
        self.presentImagePicker(imagePicker, select: { (asset) in
            print("Selected: \(asset)")
            imagePicker.doneButton.title = "Done"
        }, deselect: { (asset) in
          print("Deselected: \(asset)")
            imagePicker.doneButton.title = "Done"
        }, cancel: { (assets) in
          print("Canceled with selections: \(assets)")
        }, finish: { (assets) in
            print("Finished with selections: \(assets)")
            let counter = (assets.count) - 1
            print(counter)
            
            if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                HUD.show(.label("Loading ..."), onView: self.view)
                
            }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                HUD.show(.label("جار التحميل"), onView: self.view)
            }
            // prepare selected videos for uploading...... [VideoURL TO DATA]
            var counter_2 = 0
            self.dataImage.removeAll()
            for i in assets {
                PHImageManager.default().requestPlayerItem(forVideo: i, options: nil) { (avplayer, info) in
                    
                    let assetURL : AVURLAsset = avplayer?.asset as! AVURLAsset
                    guard let video_data = try? Data(contentsOf: assetURL.url) else {return}
                    print("video ^^^^^^^^=> \(video_data)")
                    
                    //self.dataImage.append(video_data)
                    
                    
                    let degraded = info?[PHImageResultIsDegradedKey] as? Bool // To check if the real image (not the thunmbil) is choosen one
                    if degraded == nil || degraded == false {
                        self.dataImage.append(video_data)
                        counter_2+=1
                        
                        if counter_2 == assets.count {
                           
                            self.UploadMedia(isImages: false)
                            return
                        }
                        
                    }
                    
//                    if (assets[counter] == i){
//                        print("Start Uploading .......")
//                        self.UploadMedia(isImages: false)
//                    }

                }
            }
            
        }, completion: {
           print("completion")
        })
      }

    
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
                        }else {
                            self.CommingServiceHeight.constant = 0
                            self.CommingServiceLblHeight.constant = 0
                            self.ViewAllHeight.constant = 0
                            self.ViewAllBtn.isHidden = true
                        }
                        self.mainView.isHidden = true
                        self.mainView.isShimmering = false
                        self.requested = true
                        self.MyPhotosCollection.reloadData()
                        self.MyVideosCollection.reloadData()
                        
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
                        
                        self.CommingServiceHeight.constant = 0
                        self.CommingServiceLblHeight.constant = 0
                        self.ViewAllHeight.constant = 0
                        self.ViewAllBtn.isHidden = true
                        
                        self.mainView.isHidden = true
                        self.mainView.isShimmering = false
                        self.requested = true
                        
                        self.FollowBtn.setTitle(self.profile.data?.user?.following_status_message ?? "", for: .normal)
                        
                        if self.profile.data?.user?.following_status == 0 || self.profile.data?.user?.following_status == 1 { // pending OR unfriend profile
                            self.countsDataView.isHidden = true
                            self.profileOptionsView.isHidden = true
                            self.myPhotosView.isHidden = true
                            self.myVideosView.isHidden = true
                            self.scrollView.isScrollEnabled = false
                        }
                        
                        if self.profile.data?.user?.following_status == 2 { // Fried profile
                            self.countsDataView.isHidden = false
                            self.profileOptionsView.isHidden = false
                            self.myPhotosView.isHidden = false
                            self.myVideosView.isHidden = false
                            self.scrollView.isScrollEnabled = true
                            self.MyPhotosCollection.reloadData()
                            self.MyVideosCollection.reloadData()
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
//                                if follow == "1" {
//                                    self.FollowBtn.setTitle("Unfollow", for: .normal)
//                                }else if follow == "0" {
//                                     self.FollowBtn.setTitle("Follow", for: .normal)
//                                }
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
    
    
    

// MARK: - Upload Images + Videos
    func UploadMedia(isImages : Bool){
        
        let url = ApiManager.Apis.uploadUserMedia.description
       
        if isImages {
            if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                HUD.show(.label("Uploading Media ..."), onView: self.view)
                
            }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                HUD.show(.label("جاري رفع الوسائط"), onView: self.view)
            }
        }
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            HUD.hide()
            
            var fileName = "image.jpeg"
            var mimeType = "image/jpeg"
            
            if (!isImages){
                fileName = "video.mp4"
                mimeType = "video/mp4"
            }
 
            for (index, item) in self.dataImage.enumerated() {
                multipartFormData.append(item, withName: "uploads[\(index)]", fileName: fileName, mimeType: mimeType)
                
                print("index multipart ==> \(index)")
            }
            
    
 
            print(multipartFormData)
            print(url)
            
        }, usingThreshold: UInt64.init(), to: url, method: .post , headers :
            [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ] )
            {
                
        
                (result) in
            switch result{
            case .success(let upload, _, _):
               
                upload.uploadProgress(closure: { (progress) in
                   
                  print(progress.fractionCompleted)
                   
                  let n = Float(progress.fractionCompleted)
                  //self.addPostController?.navigationController?.setProgress(n, animated: true)
                })
                
                upload.responseJSON { response in
                    if (response.response?.statusCode ?? 404) < 300{ //
                        
                        do {
                            self.success = try JSONDecoder().decode(ErrorMsg.self, from: response.data!)
                            HUD.flash(.label(self.success.msg?[0] ?? ""), onView: self.view, delay: 1.0, completion: nil)
                            if isImages {
                                self.GetProfileData()
                            }
                            
                        }catch {
                            HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                        }
                        
                    }else{
                        do {
                            let temp = try JSONDecoder().decode(ErrorMsg.self, from: response.data!)
                            HUD.flash(.labeledError(title: "حدث خطأ", subtitle: nil), onView: self.view, delay: 1.0, completion: nil)
                            HUD.hide()
                        }catch{
                            HUD.flash(.labeledError(title: "حدث خطأ", subtitle: nil), onView: self.view, delay: 1.0, completion: nil)
                        }
                    }
                    
                    if let err = response.error{
                        HUD.hide()
                        HUD.flash(.labeledError(title: "حدث خطأ", subtitle: nil), onView: self.view, delay: 1.0, completion: nil)
                        print(err)
                        return
                    }
                    
                }
            case .failure(let error):
                HUD.flash(.labeledError(title: "حدث خطأ في رفع الصور", subtitle: nil), onView: self.view, delay: 1.0, completion: nil)
                print("Error in upload: \(error.localizedDescription)")
            }
        }
        
    }
    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
    }
    
    
    
     // MARK: - EditProfileBtn
    @IBAction func EditProfileBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditAccountVC") as! EditAccountVC
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
     // MARK: - ViewAllBtn
    @IBAction func ViewAllBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScheduledReservationsVC") as! ScheduledReservationsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - EventsBtn
    @IBAction func EventsBtnPressed(_ sender: Any) {
     let vc = self.storyboard?.instantiateViewController(withIdentifier: "EventsVC") as! EventsVC
     self.navigationController?.pushViewController(vc, animated: true)
    }
    
}






    // MARK: - CollectionViewDelegate
    extension ProfileVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout  {
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
            if collectionView == MyPhotosCollection {
                if requested
                {
                    if profile.data?.user?.images?.count ?? 0 == 0 {
                         myPhotosHeight.constant = 50
                    }else {
                         collectionView.layoutIfNeeded()
                         myPhotosHeight.constant = 350
                    }
                }
                
                return profile.data?.user?.images?.count ?? 0
            }
            
            
            if collectionView == MyVideosCollection {
                if requested
                {
                    if profile.data?.user?.videos?.count ?? 0 == 0 {
                        myvideosHieght.constant = 50
                    }else {
                        collectionView.layoutIfNeeded()
                        myvideosHieght.constant = 350
                    }
                }
                return profile.data?.user?.videos?.count ?? 0
            }
            
            return 0
        }
        
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            if collectionView == MyPhotosCollection {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FullImageCollCell", for: indexPath) as? FullImageCollCell {
                    cell.UpdateView(image: profile.data?.user?.images?[indexPath.row].path ?? "", video: false)
                    return cell
                }
            }
            
            if collectionView == MyVideosCollection {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FullImageCollCell", for: indexPath) as? FullImageCollCell {
                    cell.UpdateView(image: profile.data?.user?.videos?[indexPath.row].path ?? "", video: false)
                    return cell
                }
            }
            
            return FullImageCollCell()
            
        }
        
        
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
            if collectionView == MyPhotosCollection || collectionView == MyVideosCollection
            {
                
               return CGSize(width: self.MyPhotosCollection.frame.width/3 , height: self.MyPhotosCollection.frame.height/2)
                
            }
            
            return CGSize()
            
        }
        
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            
            
            return 0;
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            
            return 0
        }
        
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            if collectionView == MyVideosCollection {
                
                playVideo(url: URL(string: profile.data?.user?.videos?[indexPath.row].path ?? "")!)
                    
            }
            
            if collectionView == MyPhotosCollection {
                
                let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "SalonGalleryViewController") as! SalonGalleryViewController
                
                vc.selected_image = profile.data?.user?.images?[indexPath.row].path ?? ""
                vc.selected_index = indexPath
                vc.Profile = true
                vc.ProfileAlbums  = profile.data?.user?.images
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
           
            
        }
        
        
        
        func playVideo(url: URL) {
            let player = AVPlayer(url: url)
            
            let vc = AVPlayerViewController()
            vc.player = player
            
            self.present(vc, animated: true) { vc.player?.play() }
        }
        
}
    

