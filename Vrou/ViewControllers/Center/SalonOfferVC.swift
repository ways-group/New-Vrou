//
//  SalonOfferVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/16/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import ViewAnimator
import HCSStarRatingView
import Alamofire
import SwiftyJSON
import PKHUD
import SDWebImage
import RSSelectionMenu
import MOLH
import ActiveLabel

class SalonOfferVC: UIViewController, UIScrollViewDelegate {

    // MARK: - IBOutlet
    @IBOutlet weak var OfferImage: UIImageView!
    @IBOutlet weak var SalonLogo: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var SalonCategory: UILabel!
    @IBOutlet weak var SalonRate: HCSStarRatingView!
    @IBOutlet weak var OfferName: UILabel!
    @IBOutlet weak var offer_price: UILabel!
    @IBOutlet weak var OfferDescription: ActiveLabel!
    @IBOutlet weak var OfferTime: UILabel!
    @IBOutlet weak var RelatedCollection: UICollectionView!
    @IBOutlet weak var SelectBranchBtn: UIButton!
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var RelatedOffersHeight: NSLayoutConstraint!
    @IBOutlet weak var OfferOld_price: UILabel!
    @IBOutlet weak var OfferViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var favouritesLbl: UILabel!
    @IBOutlet weak var commentsLbl: UILabel!
    @IBOutlet weak var sharesLbl: UILabel!
    @IBOutlet weak var latestCommentImage: UIImageView!
    @IBOutlet weak var LatestCommentName: UILabel!
    @IBOutlet weak var latestCommentLbl: UILabel!
    @IBOutlet weak var CommentTxtView: UITextView!
    @IBOutlet weak var viewsCountLbl: UILabel!
    @IBOutlet weak var LastCommentTime: UILabel!
    @IBOutlet weak var LastCommentHieght: NSLayoutConstraint!
    @IBOutlet weak var ReadAllBtn: UIButton!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var CommentsView: UIView!
    @IBOutlet weak var CommentsViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var AddNewCollectionView: UIView!
    @IBOutlet weak var collectionNameTxtField: UITextField!
    @IBOutlet weak var HeartLogo: UIImageView!
    @IBOutlet weak var sendBtn: UIButton!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var usersCollection: UICollectionView!
    @IBOutlet weak var selectBranchHeightBtn: NSLayoutConstraint!
    
    // MARK: - Variables
     var textHeightConstraint: NSLayoutConstraint!
    //CollectionViewAnimtionsParams
    private var items = [Any?]()
    private let animations = [AnimationType.from(direction: .left, offset: 60.0)]

    var OfferID = "1"
    var offerDetails = OfferDetails()
    var SelectedBranchID = ""
    var branches = [String]()
    var mins = 0
    var hrs = 0
    var days = 0
    var timer = Timer()
    var isTimerRunning = false
    
    var success = ErrorMsg()
    var isRequested = false
    var toArabic = ToArabic()
    
    var collections = CollectionsModel()
    var collectionsNames = [String]()
    var chossenCollectionIndex = 0
    var collectionID = ""
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.contentView = logo
        mainView.isShimmering = true
        mainView.shimmeringSpeed = 550
        mainView.shimmeringOpacity = 1
        
        CommentTxtView.delegate = self
        CommentTxtView.textColor = UIColor.lightGray
        
        mainScrollView.delegate = self
        
        SetUpCollectionView(collection: RelatedCollection)
        SetUpCollectionView(collection: usersCollection)
        
        RelatedOffersHeight.constant = 0
        ReadAllBtn.setTitle(NSLocalizedString("Read all", comment: ""), for: .normal)
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            toArabic.ReverseButton(Button: sendBtn)
        }
        GetOfferDetails()
        
        self.textHeightConstraint = CommentTxtView.heightAnchor.constraint(equalToConstant: 40)
        self.textHeightConstraint.isActive = true
        
        CommentTxtView.text = NSLocalizedString("Type a comment", comment: "")
        collectionNameTxtField.placeholder = NSLocalizedString("Collection Name", comment: "")
        saveBtn.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        cancelBtn.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
       
    }
    
    
    func SetUpCollectionView(collection:UICollectionView){
        collection.delegate = self
        collection.dataSource = self
    }
    
    func SetupAnimation() {
        items = Array(repeating: nil, count: 1)
        RelatedCollection?.performBatchUpdates({
            UIView.animate(views: RelatedCollection.visibleCells,
                           animations: animations,
                           duration: 0.5)
        }, completion: nil)
    }
    
    // MARK: - Buttons Actions
    
    @IBAction func AddOfferToCollection(_ sender: Any) {
        if User.shared.isLogedIn() {
            GetCollectionsData()
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func SalonLogoBtn_pressed(_ sender: Any) {
        if offerDetails.data?.offer?.branches?.count ?? 0 > 0 {
            NavigationUtils.goToSalonProfile(from: self, salon_id: Int (offerDetails.data?.offer?.branches?[0].salon_id ?? "0") ?? 0)
        }
        
    }
    
    @IBAction func SelectBranchBtn_pressed(_ sender: Any) {
        
        let selectionMenu =  RSSelectionMenu(dataSource: branches) { (cell, object, indexPath) in
            cell.textLabel?.text = "\(self.branches[indexPath.row])"
            cell.textLabel?.textColor = .black
            cell.textLabel?.textAlignment = .center
        }
        
        selectionMenu.setSelectedItems(items: [self.SelectBranchBtn.title(for: .normal) ?? ""]) {
            (item, index, isSelected, selectedItems)  in
            
            self.SelectBranchBtn.setTitle(item, for: .normal)
            self.SelectBranchBtn.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            self.SelectedBranchID = "\(self.offerDetails.data?.offer?.branches?[index].id ?? Int())"
        }
        
        selectionMenu.show(style: .popover(sourceView: SelectBranchBtn, size: CGSize(width: 220, height: 100)) , from: self)
        
        
    }
    
    
    
    @IBAction func AddToCartBtn_pressed(_ sender: Any) {
        if User.shared.isLogedIn() {
            AddToCart()
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func AddToFavouriteBtn_pressed(_ sender: Any) {
        if User.shared.isLogedIn() {
            if offerDetails.data?.offer?.is_favorite == 0 {
                AddToFavourite()
            }else {
                RemoveFromFavourite()
            }
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func ShareBtn_pressed(_ sender: Any) {
        
        ShareOffer(id: "\(offerDetails.data?.offer?.id ?? Int())")
        
        let url = URL(string: self.offerDetails.data?.offer?.image ?? "") ?? URL(string:"https://vrou.com")
        if let data = try? Data(contentsOf: url!)
        {
            let image: UIImage = UIImage(data: data) ?? UIImage()
            let des = self.offerDetails.data?.offer?.offer_description ?? ""
            let activityVC = UIActivityViewController(activityItems: [image,des], applicationActivities: nil)
//            activityVC.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToVimeo]
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func ReadAllBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
        
        vc.itemName = offerDetails.data?.offer?.offer_name ?? ""
        vc.timer = OfferTime.text ?? ""
        vc.itemDescription = offerDetails.data?.offer?.offer_description ?? ""
        vc.type = "offer"
        vc.id = "\(offerDetails.data?.offer?.id ?? Int())"
        
        self.present(vc, animated: true, completion: nil)
        
    }
    
    
    @IBAction func SendCommentBtn_pressed(_ sender: Any) {
        
        if CommentTxtView.text != NSLocalizedString("Type a comment", comment: "") && CommentTxtView.text != "" && User.shared.isLogedIn()
        {
            SendComment()
        }else {
            if !User.shared.isLogedIn() {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
                vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                self.present(vc, animated: true, completion: nil)
            }
            
        }
        
    }
    
    
    @IBAction func CommentsBtn_pressed(_ sender: Any) {
        mainScrollView.scrollToView(view: CommentsView, animated: true)
    }
    
    
    @IBAction func SaveBtn_pressed(_ sender: Any) {
        if collectionNameTxtField.text != "" {
            
            AddCollection(params: ["type": "1" , "collection_name": collectionNameTxtField.text! , "item_id": "\(offerDetails.data?.offer?.id ?? Int())" , "item_type": "offer"])
            AddNewCollectionView.isHidden = true
            collectionNameTxtField.text = ""
            
        }else {
            if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                HUD.flash(.label("Please Enter collection name") , onView: self.view , delay: 1.6 , completion: nil)
            }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar"  {
                HUD.flash(.label("الرجاء ادخال اسم المجموعة") , onView: self.view , delay: 1.6 , completion: nil)
            }
        }
    }
    
    @IBAction func CancelBtn_pressed(_ sender: Any) {
        AddNewCollectionView.isHidden = true
    }
    
    
}


extension SalonOfferVC {
    
     // MARK: - Offer_API
    func GetOfferDetails() {
        let FinalURL = "\(ApiManager.Apis.OfferDetails.description)"
        var params = [String():String()]
        if User.shared.isLogedIn() {
            params = ["offer_id": OfferID , "related": "1" , "user_hash_id": User.shared.TakeHashID() ]
        }else {
            params = ["offer_id": OfferID , "related": "1" , "user_hash_id": "0" ]
        }
        ApiManager.shared.ApiRequest(URL: FinalURL, method: .post, parameters: params ,encoding: URLEncoding.default, Header:["Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view) { (data, tmp) in
               
               if tmp == nil {
                   HUD.hide()
                do {
                    self.isRequested = true
                    self.offerDetails = try JSONDecoder().decode(OfferDetails.self, from: data!)
                    self.RelatedCollection.reloadData()
                    self.usersCollection.reloadData()
                    self.SetImage(image: self.OfferImage, link: self.offerDetails.data?.offer?.image ?? "")
                    self.SetImage(image: self.SalonLogo, link: self.offerDetails.data?.offer?.salon_logo ?? "")
                    self.SalonName.text = self.offerDetails.data?.offer?.salon_name ?? ""
                    self.SalonCategory.text = self.offerDetails.data?.offer?.salon_category_name ?? ""
                    self.SalonRate.value = CGFloat(truncating: NumberFormatter().number(from: self.offerDetails.data?.offer?.salon_rate ?? "") ?? 0)
                    self.OfferName.text = self.offerDetails.data?.offer?.offer_name ?? ""
                    self.OfferDescription.text = self.offerDetails.data?.offer?.offer_description ?? ""
                    
                    self.offer_price.text = (self.offerDetails.data?.offer?.new_price ?? "") + " " + (self.offerDetails.data?.offer?.currency ?? "")
                    self.OfferOld_price.text = (self.offerDetails.data?.offer?.old_price ?? "") + " " + (self.offerDetails.data?.offer?.currency ?? "")
                    
                    if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                        
                        self.OfferTime.text = "Ends After \(self.offerDetails.data?.offer?.days ?? "0")D: \(self.offerDetails.data?.offer?.hours ?? "0")H: \(self.offerDetails.data?.offer?.minutes ?? "0")M"
                        
                    }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                        self.OfferTime.text = "ينتهي العرض بعد \(self.offerDetails.data?.offer?.days ?? "0")يوم: \(self.offerDetails.data?.offer?.hours ?? "0")س: \(self.offerDetails.data?.offer?.minutes ?? "0")د"
                    }
                    
                    
                    self.mins = Int(self.offerDetails.data?.offer?.minutes ?? "0") ?? 0
                    self.hrs = Int(self.offerDetails.data?.offer?.hours ?? "0") ?? 0
                    self.days = Int(self.offerDetails.data?.offer?.days ?? "0") ?? 0
                    self.runTimer()
                    self.SetupAnimation()
                    
                    self.branches.removeAll()
                    
                    if self.offerDetails.data?.offer?.branches?.count ?? 0 == 1 {
                        self.SelectBranchBtn.isHidden = true
                        self.SelectedBranchID = "\(self.offerDetails.data?.offer?.branches?[0].id ?? Int())"
                         self.selectBranchHeightBtn.constant = 0
                         self.OfferViewHeight.constant = 300
                    }else {
                        self.offerDetails.data?.offer?.branches?.forEach({ (branch) in
                            self.branches.append(branch.branch_name ?? "")
                        })
                    }
                    
                    
                    self.mainView.isHidden = true
                    self.mainView.isShimmering = false
                    
                    if self.offerDetails.data?.offer?.is_favorite == 1 {
                        self.HeartLogo.image = #imageLiteral(resourceName: "SocialHeart")
                    }else {
                         self.HeartLogo.image = #imageLiteral(resourceName: "heartPinkBorder")
                    }
                    
                    if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                        self.toArabic.ReverseCollectionDirection(collectionView: self.RelatedCollection)
                    }
                    
                    self.OfferDescription.layoutIfNeeded()
                    if self.OfferDescription.isTruncated {
                      
                        self.OfferViewHeight.constant = self.OfferViewHeight.constant +  (self.OfferDescription.TxtActualHeight - self.OfferDescription.bounds.size.height)
                    }
                    
                    self.sharesLbl.text  = "\(self.offerDetails.data?.offer?.share_count ?? "0")"
                    self.favouritesLbl.text = "\(self.offerDetails.data?.offer?.favorites_count ?? "0")"
                    self.commentsLbl.text = self.offerDetails.data?.offer?.comments_count ?? "0"
                   
                    self.SetImage(image: self.latestCommentImage, link: self.offerDetails.data?.offer?.last_comment?.user?.image ?? "")
                   
                    self.LatestCommentName.text = self.offerDetails.data?.offer?.last_comment?.user?.name ?? ""
                    self.latestCommentLbl.text = self.offerDetails.data?.offer?.last_comment?.body ?? ""
                    self.LastCommentTime.text = self.offerDetails.data?.offer?.last_comment?.created_at ?? ""
                    
                    if self.offerDetails.data?.offer?.last_comment?.body ?? "" == "" {
                        self.LastCommentHieght.constant = 0
                        self.ReadAllBtn.setTitle(NSLocalizedString("No Comments", comment: ""), for: .normal)
                        self.ReadAllBtn.isUserInteractionEnabled = false
                        self.CommentsViewHeight.constant = 150
                    }else {
                        self.LastCommentHieght.constant = 100
                        self.ReadAllBtn.setTitle(NSLocalizedString("Read all", comment: ""), for: .normal)
                        self.ReadAllBtn.isUserInteractionEnabled = true
                        self.CommentsViewHeight.constant = 250
                    }
                    
                    self.viewsCountLbl.text = "\(self.offerDetails.data?.offer?.mobile_views ?? "0") \n \(NSLocalizedString("Watching", comment: ""))"
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
               }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                UIApplication.shared.keyWindow?.rootViewController = vc
                
               }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.GetOfferDetails()
                }
                self.present(vc, animated: true, completion: nil)
            }
            
        }
       }
    
    func GetCollectionsData() {
         
             HUD.show(.progress , onView: view)
           ApiManager.shared.ApiRequest(URL: "\(ApiManager.Apis.CollectionList.description)1" , method: .get, Header: ["Authorization": "Bearer \(User.shared.TakeToken())",
               "Accept": "application/json",
               "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
                   if tmp == nil {
                       HUD.hide()
                       do {
                           self.collections = try JSONDecoder().decode(CollectionsModel.self, from: data!)
                            self.collectionsNames.removeAll()
                            self.collections.data?.collections?.forEach({ (coll) in
                               if coll.name != "" {
                                   self.collectionsNames.append(coll.name ?? "")
                               }
                           })
                        self.PickerActionSheet(title: NSLocalizedString("Add the Offer to your collections", comment: ""))
                           
                       }catch {
                           HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                       }
                       
                   }else if tmp == "401" {
                       let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                       UIApplication.shared.keyWindow?.rootViewController = vc
                       
                   }else if tmp == "NoConnect" {
                       guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                       vc.callbackClosure = { [weak self] in
                           self?.GetCollectionsData()
                       }
                       self.present(vc, animated: true, completion: nil)
                   }
           }
       }
    
    
    func AddCollection(params: [String:String] ) {
                 HUD.show(.progress , onView: view)
         ApiManager.shared.ApiRequest(URL: ApiManager.Apis.CreateCollection_addItem.description, method: .post, parameters: params, encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                     ExtraParams: "", view: self.view) { (data, tmp) in
                             if tmp == nil {
                                 HUD.hide()
                             do {
                                 self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                                 HUD.flash(.label(self.success.msg?[0] ?? "Success") , onView: self.view , delay: 1.6 , completion: {
                                     (tmp) in
                                     self.GetOfferDetails()
                                 })
                                       
                             }catch {
                                 HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                             }
     
                             }else if tmp == "401" {
                                 let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                                 UIApplication.shared.keyWindow?.rootViewController = vc
     
                             }
     
                 }
     }
    
    
    
       
       func SetImage(image:UIImageView , link:String) {
           let url = URL(string:link )
           image.sd_setImage(with: url, placeholderImage: UIImage(), options: .highPriority , completed: nil)
       }
    
    
  // MARK: - SetupOfferTimer
     func runTimer() {
         timer = Timer.scheduledTimer(timeInterval: 60, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
         RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
     }
     
     @objc func updateTimer() {
         
         if mins > 0 {
             mins -= 1
         }else {
             if hrs > 0 {
                 hrs -= 1
                 mins = 59
             }else {
                 if days > 0 {
                     days -= 1
                     hrs = 23
                     mins = 59
                 }else {
                     OfferTime.text = "Offer Ends!"
                 }
             }
        }
        
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            OfferTime.text = "Ends After \(days )D: \(hrs )H: \(mins )M"
            
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            OfferTime.text = "ينتهي العرض بعد \(days )يوم: \(hrs )س: \(mins )د"
        }
    }
    
    
    // MARK: - AddToCart_API
    func AddToCart() {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.AddOfferProductToCart.description, method: .post, parameters: ["item_id":OfferID , "item_type":"offer" , "branch_id":SelectedBranchID], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                   ExtraParams: "", view: self.view) { (data, tmp) in
                         if tmp == nil {
                            HUD.hide()
                            do {
                                self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                                self.AddedToCartPopUp(header: self.success.msg?[0] ?? "Add to Cart")
                                
                            }catch {
                                HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                            }
                            
                         }else if tmp == "401" {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                            UIApplication.shared.keyWindow?.rootViewController = vc
                            
                    }
                    
        }
    }
    
// MARK: - AddToFavourite_API
    func AddToFavourite() {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.AddToFavourite.description, method: .post, parameters: ["item_id":OfferID , "item_type":"offer"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                   ExtraParams: "", view: self.view) { (data, tmp) in
                    if tmp == nil {
                        HUD.hide()
                        do {
                            self.GetOfferDetails()
                        }catch {
                            HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                        }
                        
                    }else if tmp == "401" {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                        UIApplication.shared.keyWindow?.rootViewController = vc
                        
                    }
                    
        }
    }
    
    
    // MARK: - RemoveFromCart_API
    func RemoveFromFavourite() {
          HUD.show(.progress , onView: view)
          ApiManager.shared.ApiRequest(URL: ApiManager.Apis.RemoveFromFavourite.description, method: .post, parameters: ["item_id":OfferID , "item_type":"offer"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                     ExtraParams: "", view: self.view) { (data, tmp) in
                           if tmp == nil {
                            HUD.hide()
                            do {
                                self.GetOfferDetails()
                            }catch {
                                HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                            }
                            
                           }else if tmp == "401" {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                            UIApplication.shared.keyWindow?.rootViewController = vc
                               
                           }
                           
                       }
            }

    
    
    // MARK: - AddToCart_API
    func AddedToCartPopUp(header:String) {
        var msg_1 = ""
        var msg_2 = ""
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            msg_1 = "Continue"; msg_2 = "Cart"
        }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar"  {
            msg_1 = "متابعة"; msg_2 = "السلة"
        }
        
        let alert = UIAlertController(title: "", message: header , preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: msg_1, style: .cancel, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: msg_2, style: .default, handler: { (_) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReservationNavController") as! ReservationNavController
            UIApplication.shared.keyWindow?.rootViewController = vc
        }))
        
        self.present(alert, animated: false, completion: nil)
    }
    
    
    func SendComment() {
         HUD.show(.progress , onView: view)
         
         ApiManager.shared.ApiRequest(URL: ApiManager.Apis.AddComment.description, method: .post, parameters: ["commentable_id":OfferID , "commentable_type":"offer" , "body":CommentTxtView.text!],encoding: URLEncoding.default, Header:["Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json" , "locale" : UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier],ExtraParams: "", view: self.view) { (data, tmp) in
             if tmp == nil {
                 HUD.hide()
                 do {
                     self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                     HUD.flash(.label(self.success.msg?[0] ?? "Success") , onView: self.view , delay: 1.6 , completion: nil)
                     self.GetOfferDetails()
                     
                     self.CommentTxtView.text = NSLocalizedString("Type a comment", comment: "")
                     self.CommentTxtView.textColor = UIColor.lightGray
                     
                 }catch {
                     HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                 }
                 
             }else if tmp == "401" {
                 let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                 UIApplication.shared.keyWindow?.rootViewController = vc
                 
             }
             
         }
     }
    
    
    
    func ShareOffer(id:String) {
         HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.ShareItem.description, method: .post, parameters: ["shareable_id":id, "shareable_type":"offer"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json" , "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                                     ExtraParams: "", view: self.view) { (data, tmp) in
                                        if tmp == nil {
                                            //HUD.hide()
                                            self.GetOfferDetails()
                                        }else if tmp == "401" {
                                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                                            UIApplication.shared.keyWindow?.rootViewController = vc
                                            
                }
                                        
        }
    }
    
    
    
    
}




// MARK: - CollectionViewDelegate
extension SalonOfferVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        if collectionView == RelatedCollection {
            
            if isRequested &&  offerDetails.data?.related_offers?.count ?? 0 > 0 {
                RelatedOffersHeight.constant = 21
            }
            
            return offerDetails.data?.related_offers?.count ?? 0
        }
        
        if collectionView == usersCollection {
            return offerDetails.data?.offer?.watching_users?.count ?? 0
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == RelatedCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RelatedOffersCollCell", for: indexPath) as? RelatedOffersCollCell {
                
                        cell.UpdateView(offer: offerDetails.data?.related_offers?[indexPath.row] ?? Offer())
                
                return cell
            }
        }
        
        if collectionView  == usersCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PeopleCollCell", for: indexPath) as? PeopleCollCell {
                cell.UpdateView(image:offerDetails.data?.offer?.watching_users?[indexPath.row].image ?? "")
                return cell
            }
        }
        
        return ForYouCollCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == RelatedCollection {
            let height:CGSize = CGSize(width: self.RelatedCollection.frame.width/1.2 , height: self.RelatedCollection.frame.height)
            
            return height
        }
        
        if collectionView == usersCollection {
             return CGSize(width: 30, height: 30);
        }
      
        
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        
        
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if collectionView == usersCollection {
            return -10
        }
        
        return 0
    }
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == RelatedCollection {
            let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "SalonOfferVC") as! SalonOfferVC
                   let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
                   self.navigationItem.backBarButtonItem = item
                   self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "BackArrow")
                   self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "BackArrow")
                       
                   vc.OfferID = "\(offerDetails.data?.related_offers?[indexPath.row].id ?? Int())"

                   self.navigationController?.pushViewController(vc, animated: true)
                   
        }
        
        
        if collectionView == usersCollection {
            
            if User.shared.isLogedIn() {
                let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "UsersListVC") as! UsersListVC
                vc.watchable_id = "\(offerDetails.data?.offer?.id ?? Int())"
                vc.watchable_type = "offer"
                vc.guestView = (Int(offerDetails.data?.offer?.mobile_views ?? "0") ?? 0) - (offerDetails.data?.offer?.watching_users_count ?? 0)
                self.navigationController?.pushViewController(vc, animated: true)
            }else {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
                vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                self.present(vc, animated: true, completion: nil)
            }
            
        }
        
       
    }
    
    
}


// MARK: - TextViewDelegate
extension SalonOfferVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = NSLocalizedString("Type a comment", comment: "")
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true;
    }
    
}


 //MARK: - PickerDelegate

extension SalonOfferVC : UIPickerViewDataSource , UIPickerViewDelegate {


    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return collectionsNames.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return collectionsNames[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        chossenCollectionIndex =  pickerView.selectedRow(inComponent: 0)
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }

    func PickerActionSheet(title:String) {
        let message = "\n\n\n\n\n\n\n\n\n"
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.isModalInPopover = true

        let height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 400)
        alert.view.addConstraint(height)

        let pickerFrame = UIPickerView(frame: CGRect(x: 0, y: 80, width: 270, height: 180))
        pickerFrame.tag = 555
        //set the pickers datasource and delegate
        pickerFrame.delegate = self
        pickerFrame.dataSource = self
        //Add the picker to the alert controller
        alert.view.addSubview(pickerFrame)
        
        if collectionsNames.count == 0 {
            pickerFrame.isHidden = true
        }
        
        let okAction = UIAlertAction(title:NSLocalizedString("Done", comment: ""), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
        
            self.collectionID = "\(self.collections.data?.collections?[self.chossenCollectionIndex].id ?? Int())"
            
            self.AddCollection(params: ["type": "2", "item_id": "\(self.offerDetails.data?.offer?.id ?? Int())" , "item_type": "offer" , "collection_id" : "\(self.collectionID)"])
            
        })

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: nil)
        
        let NewCollectionAction = UIAlertAction(title:  NSLocalizedString("Create new collection", comment: ""), style: .default, handler: {
             (alert: UIAlertAction!) -> Void in
            
            self.AddNewCollectionView.isHidden = false
            
        })
        
        alert.addAction(okAction)
        alert.addAction(NewCollectionAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }



}
