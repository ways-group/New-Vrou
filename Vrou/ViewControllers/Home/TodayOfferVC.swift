//
//  TodayOfferVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/16/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import ImageSlideshow
import HCSStarRatingView
import Alamofire
import SwiftyJSON
import PKHUD
import SDWebImage
import RSSelectionMenu
import MOLH

class TodayOfferVC: UIViewController {

    @IBOutlet weak var slideshow: ImageSlideshow!
    var imageSource = [InputSource]()

    @IBOutlet weak var SalonLogo: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var OfferName: UILabel!
    @IBOutlet weak var OfferDescription: UILabel!
    @IBOutlet weak var OfferCategory: UILabel!
    @IBOutlet weak var SalonRate: HCSStarRatingView!
    @IBOutlet weak var NewPrice: UILabel!
    @IBOutlet weak var OldPrice: UILabel!
    @IBOutlet weak var SelectBranchBtn: UIButton!
    
    @IBOutlet weak var favouritesLbl: UILabel!
    @IBOutlet weak var commentsLbl: UILabel!
    @IBOutlet weak var collectionsLbl: UILabel!
    @IBOutlet weak var watchingsLbl: UILabel!
    @IBOutlet weak var sharesLbl: UILabel!
    
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var AddNewCollectionView: UIView!
    @IBOutlet weak var collectionNameTxtInput: UITextField!
    
    @IBOutlet weak var HeartLogo: UIImageView!
    @IBOutlet weak var watchingLbl: UILabel!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var usersCollection: UICollectionView!
    
    @IBOutlet weak var SelectBranchBtnHeight: NSLayoutConstraint!
    var offerDetails = OfferDetails()
    var SelectedBranchID = ""
    var branches = [String]()
    var OfferID = "66"
    var success = ErrorMsg()
    var collections = CollectionsModel()
    var collectionsNames = [String]()
    var chossenCollectionIndex = 0
    var collectionID = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
       mainView.contentView = logo
       mainView.isShimmering = true
       mainView.shimmeringSpeed = 550
       mainView.shimmeringOpacity = 1
    
       SetUpCollectionView(collection: usersCollection)
       GetOfferDetails()
        
       watchingLbl.text = NSLocalizedString("Watching", comment: "")
       collectionNameTxtInput.placeholder = NSLocalizedString("Collection Name", comment: "")
       saveBtn.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
       cancelBtn.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        
        // Do any additional setup after loading the view.
    }
    
    func SetUpCollectionView(collection:UICollectionView){
        collection.delegate = self
        collection.dataSource = self
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
                      self.SelectBranchBtn.setTitleColor(#colorLiteral(red: 0.6897211671, green: 0.1131197438, blue: 0.460976243, alpha: 1), for: .normal)
                      self.SelectedBranchID = "\(self.offerDetails.data?.offer?.branches?[index].id ?? Int())"
                  }
           
            selectionMenu.show(style: .popover(sourceView: SelectBranchBtn, size: CGSize(width: 220, height: 100)) , from: self)
    
    }
    
    
    @IBAction func SalonLogoBtn_pressed(_ sender: Any) {
       if offerDetails.data?.offer?.branches?.count ?? 0 > 0 {
            NavigationUtils.goToSalonProfile(from: self, salon_id: Int (offerDetails.data?.offer?.branches?[0].salon_id ?? "0") ?? 0)

        }
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
    
    
    @IBAction func AddCommentBtn_pressed(_ sender: Any) {
        
        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
        
        vc.itemName = offerDetails.data?.offer?.offer_name ?? ""
        vc.itemDescription = offerDetails.data?.offer?.offer_description ?? ""
        vc.type = "offer"
        vc.id = "\(offerDetails.data?.offer?.id ?? Int())"
        
        self.present(vc, animated: true, completion: nil)
        
    }
    
    
    @IBAction func ShareBtn_pressed(_ sender: Any) {
        
        
        ShareOffer(id: "\(offerDetails.data?.offer?.id ?? Int())")
        
        let url = URL(string: offerDetails.data?.offer?.image ?? "") ?? URL(string:"https://vrou.com")
        if let data = try? Data(contentsOf: url!)
        {
            let image: UIImage = UIImage(data: data) ?? UIImage()
            let activityVC = UIActivityViewController(activityItems: [image,self.offerDetails.data?.offer?.offer_description ?? ""], applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToVimeo]
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func SaveBtn_pressed(_ sender: Any) {
        
        if collectionNameTxtInput.text != "" {
            
            AddCollection(params: ["type": "1" , "collection_name": collectionNameTxtInput.text! , "item_id": "\(offerDetails.data?.offer?.id ?? Int())" , "item_type": "offer"])
            AddNewCollectionView.isHidden = true
            collectionNameTxtInput.text = ""
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
    
    
    
    @IBAction func AddToCollectionBtn_pressed(_ sender: Any) {
        if User.shared.isLogedIn() {
            GetCollectionsData()
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    func SetUpSlideShow() {
        
        slideshow.slideshowInterval = 5.0
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .bottom)
        slideshow.contentScaleMode = UIView.ContentMode.scaleAspectFill
        imageSource.removeAll()
        
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)
        pageControl.pageIndicatorTintColor =  UIColor.lightGray
        slideshow.pageIndicator = pageControl
        
        slideshow.activityIndicator = DefaultActivityIndicator()
        
        if  offerDetails.data?.offer?.images?.count ?? 0 > 0 {
            offerDetails.data?.offer?.images?.forEach({ (image) in
                imageSource.append(AlamofireSource(urlString: image.image_name ?? "") ?? ImageSource(image: UIImage(named: "AppLogo") ?? UIImage()))
            })
            
        }else {
            imageSource.append(AlamofireSource(urlString:  offerDetails.data?.offer?.image ?? "") ?? ImageSource(image: UIImage(named: "AppLogo") ?? UIImage()))
        }
        
        
        
        self.slideshow.setImageInputs(self.imageSource)
        self.slideshow.reloadInputViews()
    }
}

// MARK: - API Requests

extension TodayOfferVC {
    
    
    func GetOfferDetails() {
           let FinalURL = "\(ApiManager.Apis.OfferDetails.description)"
            var params = [String():String()]

            if User.shared.isLogedIn() {
                params = ["offer_id": OfferID , "related": "0" , "user_hash_id": User.shared.TakeHashID() ]
            }else {
                 params = ["offer_id": OfferID , "related": "0" , "user_hash_id": "0" ]
            }
        ApiManager.shared.ApiRequest(URL: FinalURL, method: .post, parameters: params ,encoding: URLEncoding.default, Header:["Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view)  { (data, tmp) in
               
               if tmp == nil {
                   HUD.hide()
                   do {
                       //self.Requested = true
                    self.offerDetails = try JSONDecoder().decode(OfferDetails.self, from: data!)
                    self.usersCollection.reloadData()
                    self.SetImage(image: self.SalonLogo, link: self.offerDetails.data?.offer?.salon_logo ?? "")
                    self.SalonName.text = self.offerDetails.data?.offer?.salon_name ?? ""
                    self.OfferCategory.text = self.offerDetails.data?.offer?.branches?[0].city?.city_name ?? ""
                   
                    self.SalonRate.value = CGFloat(truncating: NumberFormatter().number(from: self.offerDetails.data?.offer?.salon_rate ?? "") ?? 0)
                    self.OfferName.text = self.offerDetails.data?.offer?.offer_name ?? ""
                    self.OfferDescription.text = self.offerDetails.data?.offer?.offer_description ?? ""
                    
                    self.branches.removeAll()
                    if self.offerDetails.data?.offer?.branches?.count ?? 0 == 1 {
                        self.SelectedBranchID = "\(self.offerDetails.data?.offer?.branches?[0].id ?? Int())"
                        self.SelectBranchBtn.isHidden = true
                        self.SelectBranchBtnHeight.constant = 0
                    }else {
                        self.offerDetails.data?.offer?.branches?.forEach({ (branch) in
                            self.branches.append(branch.branch_name ?? "")
                        })
                    }
                    
                    self.SetUpSlideShow()
                    self.mainView.isHidden = true
                    self.mainView.isShimmering = false
                    if self.offerDetails.data?.offer?.is_favorite == 1 {
                        self.HeartLogo.image = #imageLiteral(resourceName: "SocialHeart")
                    }else {
                        self.HeartLogo.image = #imageLiteral(resourceName: "HeartPink")
                    }
                    
                    self.NewPrice.text = "\(self.offerDetails.data?.offer?.new_price ?? "") \(self.offerDetails.data?.offer?.currency ?? "")"
                    
                    self.OldPrice.text = "\(self.offerDetails.data?.offer?.old_price ?? "") \(self.offerDetails.data?.offer?.currency ?? "")"
                    
                    self.watchingsLbl.text = "\(self.offerDetails.data?.offer?.mobile_views ?? "0")"
                    
                    self.sharesLbl.text  = "\(self.offerDetails.data?.offer?.share_count ?? "0")"
                    self.favouritesLbl.text = "\(self.offerDetails.data?.offer?.wish_lists_count ?? "0")"
                    self.commentsLbl.text = self.offerDetails.data?.offer?.comments_count ?? "0"
                    self.collectionsLbl.text = self.offerDetails.data?.offer?.collections_count ?? "0"
                    
                    
                   }catch {
                       HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                   }
                   
               }else if tmp == "401" {
                   let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                   keyWindow?.rootViewController = vc
                   
               }else if tmp == "NoConnect" {
               guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                      vc.callbackClosure = { [weak self] in
                           self?.GetOfferDetails()
                      }
                           self.present(vc, animated: true, completion: nil)
                     }
               
           }
       }
    
    
    func AddToCart() {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.AddOfferProductToCart.description, method: .post, parameters: ["item_id":OfferID , "item_type":"offer" , "branch_id": SelectedBranchID], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
            ExtraParams: "", view: self.view) { (data, tmp) in
                  if tmp == nil {
                      HUD.hide()
                      do {
                          //self.Requested = true
                         self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                         self.AddedToCartPopUp(header: self.success.msg?[0] ?? "Added to Cart")
                          
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
                             keyWindow?.rootViewController = vc
                             
                         }
                         
                     }
                 }
    
    
    
    func RemoveFromFavourite() {
          HUD.show(.progress , onView: view)
          ApiManager.shared.ApiRequest(URL: ApiManager.Apis.RemoveFromFavourite.description, method: .post, parameters: ["item_id":OfferID , "item_type":"offer"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json" , "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
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
                               keyWindow?.rootViewController = vc
                               
                           }
                           
                       }
                   }
    
    
    
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
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CartNavController") as! CartNavController
            keyWindow?.rootViewController = vc
        }))
        
        self.present(alert, animated: false, completion: nil)
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
                    keyWindow?.rootViewController = vc
                    
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
                                keyWindow?.rootViewController = vc
    
                            }
    
                }
    }
    
    
    
     func ShareOffer(id:String) {

        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.ShareItem.description, method: .post, parameters: ["shareable_id":id, "shareable_type":"offer"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json" , "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                           ExtraParams: "", view: self.view) { (data, tmp) in
                                 if tmp == nil {
                               // HUD.hide()
                                self.GetOfferDetails()
                                     
                                 }else if tmp == "401" {
                                     let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                                     keyWindow?.rootViewController = vc
                                     
                                 }
                                 
                    }
            }
    
    
    
    
}

// MARK: - CollectionViewDelegate
extension TodayOfferVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        if collectionView == usersCollection {
            return offerDetails.data?.offer?.watching_users?.count ?? 0
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        
        if collectionView  == usersCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PeopleCollCell", for: indexPath) as? PeopleCollCell {
                cell.UpdateView(image:offerDetails.data?.offer?.watching_users?[indexPath.row].image ?? "")
                return cell
            }
        }
        
        return ForYouCollCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        

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




 //MARK: - PickerDelegate

extension TodayOfferVC : UIPickerViewDataSource , UIPickerViewDelegate {


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
        
        let okAction = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
        
            self.collectionID = "\(self.collections.data?.collections?[self.chossenCollectionIndex].id ?? Int())"
            
            self.AddCollection(params: ["type": "2", "item_id": "\(self.offerDetails.data?.offer?.id ?? Int())" , "item_type": "offer" , "collection_id" : "\(self.collectionID)"])
            
        })

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: nil)
        
        let NewCollectionAction = UIAlertAction(title: NSLocalizedString("Create new collection", comment: ""), style: .default, handler: {
             (alert: UIAlertAction!) -> Void in
            
            self.AddNewCollectionView.isHidden = false
            
        })
        
        alert.addAction(okAction)
        alert.addAction(NewCollectionAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }



}
