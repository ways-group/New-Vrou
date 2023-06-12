//
//  MyWorldVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/5/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import ViewAnimator
import Alamofire
import SwiftyJSON
import PKHUD
import SideMenu
import MOLH

class MyWorldVC: UIViewController , UIScrollViewDelegate{

    @IBOutlet weak var ServicesTable: UITableView!
    @IBOutlet weak var AdsCollection: UICollectionView!
    @IBOutlet weak var ServicesTable2: UITableView!
    @IBOutlet weak var MostPopularCollection: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ServicesTable3: UITableView!
    @IBOutlet weak var Table1_Height: NSLayoutConstraint!
    @IBOutlet weak var AdsHeight: NSLayoutConstraint!
    @IBOutlet weak var Table2_Height: NSLayoutConstraint!
    @IBOutlet weak var PopularCentersHeight: NSLayoutConstraint!
    @IBOutlet weak var Table3_Height: NSLayoutConstraint!
    @IBOutlet weak var SignInRequiredView: UIView!
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var VrouWorldBtn: UIButton!
    
    
    private var items = [Any?]()
    private let animations = [AnimationType.from(direction: .left, offset: 60.0)]
    var uiSUpport = UISupport()
    var toArabic = ToArabic()
    var yourWorld = YourWorld()
    var Requested = false
    var success = ErrorMsg()
    
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0


    override func viewDidLoad() {
        super.viewDidLoad()
       SetUpTableView(table: ServicesTable)
       SetUpTableView(table: ServicesTable2)
       SetUpTableView(table: ServicesTable3)
       SetUpCollectionView(collection: AdsCollection)
       SetUpCollectionView(collection: MostPopularCollection)
        
        if let nav = self.navigationController {
            uiSUpport.TransparentNavigationController(navController: nav)
        }
        
        scrollView.delegate = self
        setupSideMenu()
        SetUpRefresh()
        GetYourWorld()
        // Do any additional setup after loading the view.
    }
    
    private func setupSideMenu() {
             SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
         //  SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view)
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
    
    
    func SetUpRefresh() {
        
        if User.shared.isLogedIn() {
            scrollView.refreshControl =  UIRefreshControl()
            scrollView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
            scrollView.refreshControl?.tintColor = #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)
        }
        
    }
    
    @objc func refreshData() {
        //        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
        //                    self.GetYourWorld()
        //
        //        }
        DispatchQueue.main.async {
            self.current_page = 0
            self.GetYourWorld()
        }
        
    }
    
    
    
    
    func SetupAnimation() {
        items = Array(repeating: nil, count: 1)
        ServicesTable?.performBatchUpdates({
            UIView.animate(views: ServicesTable.visibleCells,
                           animations: animations,
                           duration: 0.5)
        }, completion: nil)
        
    }
    
    func SetUpTableView(table:UITableView){
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.estimatedRowHeight = 400
        table.rowHeight = UITableView.automaticDimension
    }
    
    func SetUpCollectionView(collection:UICollectionView){
        collection.delegate = self
        collection.dataSource = self
    }
    
    
    @IBAction func YourWorldBtn_pressed(_ sender: Any) {
        //To be Refersh the page
    }
    
    @IBAction func DiscoverBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeDiscoverNavController") as! HomeDiscoverNavController
        keyWindow?.rootViewController = vc
    }
    
    @IBAction func BeautyWorldBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BeautyWorldNavController") as! BeautyWorldNavController
        keyWindow?.rootViewController = vc
    }
    
    
    
    @IBAction func SideMenuBtn_pressed(_ sender: Any) {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UISideMenuNavigationController") as! UINavigationController
        
        vc.modalPresentationStyle = .none
       
        self.present(vc,animated: true , completion: nil)
    }
    
    
    @IBAction func SearchBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "CentersSearchNavController") as! CentersSearchNavController
        keyWindow?.rootViewController = vc
    }
    
    @IBAction func SignInBtn_pressed(_ sender: Any) {
          let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginNavController") as! LoginNavController
        keyWindow?.rootViewController = vc
    }
    
}



extension MyWorldVC { //HTTPS requests functions
    
    func GetYourWorld() {
        
        let tmp = "TOKEN:  \(User.shared.TakeToken())"
         
        if User.shared.isLogedIn() {
            
            current_page += 1
            is_loading = true
            
            if current_page == 1 {
                mainView.isHidden = false
                mainView.contentView = logo
                mainView.isShimmering = true
                mainView.shimmeringSpeed = 550
                mainView.shimmeringOpacity = 1
                SignInRequiredView.isHidden = true
                
            }

            ApiManager.shared.ApiRequest(URL: "\(ApiManager.Apis.YourWorld.description)", method: .get, parameters: ["city_id":"\(User.shared.data?.user?.city?.id ?? 0)", "page" : "\(current_page)" , "user_hash_id" : User.shared.TakeHashID()],encoding: URLEncoding.default, Header:["Authorization": "Bearer \(User.shared.TakeToken())",
                  "Accept": "application/json",
                  "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view) { (data, tmp) in
                self.scrollView.refreshControl?.endRefreshing()
                    
                    self.is_loading = false
                if tmp == nil {
                    HUD.hide()
                    do {
                        self.Requested = true
                        let decoded_data = try JSONDecoder().decode(YourWorld.self, from: data!)
                       
                        if (self.current_page == 1){
                            self.yourWorld = decoded_data
                            self.ServicesTable.reloadData()
                            self.ServicesTable2.reloadData()
                            self.ServicesTable3.reloadData()
                            self.AdsCollection.reloadData()
                            self.MostPopularCollection.reloadData()
                            self.SetupAnimation()
                        }else{
                            self.yourWorld.data?.offers?.append(contentsOf: (decoded_data.data?.offers)!)
                        }
                        
                        //get pagination data
                        let paginationModel = decoded_data.pagination
                        self.has_more_pages = paginationModel?.has_more_pages ?? false
                        
                        print("has_more_pages ==>\(self.has_more_pages)")
                        
                        self.ServicesTable3.reloadData()
                        
                        self.mainView.isHidden = true
                        self.mainView.isShimmering = false
                        
                        
                        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                            self.toArabic.ReverseCollectionDirection(collectionView: self.AdsCollection)
                            self.toArabic.ReverseCollectionDirection(collectionView: self.MostPopularCollection)
                        }
                        
                    }catch {
                        HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                    }
                    
                }else if tmp == "401" {
                    let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    keyWindow?.rootViewController = vc
                }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                       vc.callbackClosure = { [weak self] in
                            self?.GetYourWorld()
                       }
                            self.present(vc, animated: true, completion: nil)
                      }
                
            }
        }else {
            SignInRequiredView.isHidden = false
        }
      
    }
    
    
    
    
    func AddToFavourite(id:String) -> Bool {
       // HUD.show(.progress , onView: view)
        var returnValue = false
        
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.AddToFavourite.description, method: .post, parameters: ["item_id":id , "item_type":"offer"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                   ExtraParams: "", view: self.view) { (data, tmp) in
                         if tmp == nil {
                             HUD.hide()
                             do {
                                 
                                self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                              // HUD.flash(.label(self.success.msg?[0] ?? "Added to Favourite") , onView: self.view , delay: 1.6 , completion: nil )
                              
                               returnValue = true
                             }catch {
                                 HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                              
                             }
                             
                         }else if tmp == "401" {
                             let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                             keyWindow?.rootViewController = vc
                             
                         }
                         
                     }
                 return returnValue
                }
    
    
    
    func RemoveFromFavourite(id:String) {
         // HUD.show(.progress , onView: view)
          ApiManager.shared.ApiRequest(URL: ApiManager.Apis.RemoveFromFavourite.description, method: .post, parameters: ["user_hash_id": User.shared.TakeHashID(),"item_id":id , "item_type":"offer"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json" , "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                     ExtraParams: "", view: self.view) { (data, tmp) in
                           if tmp == nil {
                               HUD.hide()
                               do {
                                   
                                  self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                               //  HUD.flash(.label(self.success.msg?[0] ?? "Remove from favourites") , onView: self.view , delay: 1.6 , completion: {
                                  //  (tmp) in
                                  //  self.GetYourWorld()
                               //  })
                                   
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
           // HUD.show(.progress , onView: view)
            ApiManager.shared.ApiRequest(URL: ApiManager.Apis.ShareItem.description, method: .post, parameters: ["shareable_id":id, "shareable_type":"offer"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json" , "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                       ExtraParams: "", view: self.view) { (data, tmp) in
                             if tmp == nil {
                                 HUD.hide()
                                 do {
                                     
                                    self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
//                                   HUD.flash(.label(self.success.msg?[0] ?? "Share success") , onView: self.view , delay: 1.6 , completion: {
//                                      (tmp) in
//                                      self.GetYourWorld()
//                                   })
                                     
                                 }catch {
                                     HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                                 }
                                 
                             }else if tmp == "401" {
                                 let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                                 keyWindow?.rootViewController = vc
                                 
                             }
                             
                         }
        }
    
    
}



extension MyWorldVC: UITableViewDelegate , UITableViewDataSource,  MyWorldDelegate {
   
    func OpenUsersList(offerID: String, guestNumbers: Int) {
        
        if User.shared.isLogedIn() {
            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "UsersListVC") as! UsersListVC
            vc.watchable_id = offerID
            vc.watchable_type = "offer"
            vc.guestView = guestNumbers
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    
    func Share(offerID: String, imageLink: String, index:Int) {
         let url = URL(string: imageLink) ?? URL(string:"https://vrou.com")
               if let data = try? Data(contentsOf: url!)
               {
                   let image: UIImage = UIImage(data: data) ?? UIImage()
                let activityVC = UIActivityViewController(activityItems: [image, yourWorld.data?.offers?[index].offer_description ?? ""], applicationActivities: nil)
                activityVC.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToVimeo]
                activityVC.popoverPresentationController?.sourceView = self.view
                   self.present(activityVC, animated: true, completion: nil)
                   self.ShareOffer(id: offerID)
               }
    }
    
    
    func Like(offerID: String, isLike: String, index:Int) {
        if isLike == "0" {
            AddToFavourite(id: offerID)
            let newCount = Int(yourWorld.data?.offers?[index].favorites_count ?? "0")! + 1
            yourWorld.data?.offers?[index].favorites_count = "\(newCount)"
            yourWorld.data?.offers?[index].is_favorite = 1
            self.ServicesTable.reloadData()
            self.ServicesTable2.reloadData()
            self.ServicesTable3.reloadData()
            
        }else if isLike == "1" {
            
            let newCount = Int(yourWorld.data?.offers?[index].favorites_count ?? "0")! - 1
            yourWorld.data?.offers?[index].favorites_count = "\(newCount)"
            yourWorld.data?.offers?[index].is_favorite = 0
            RemoveFromFavourite(id: offerID)
            self.ServicesTable.reloadData()
            self.ServicesTable2.reloadData()
            self.ServicesTable3.reloadData()
        }
    }
    
    
    
    func Comment(OfferID: String, offerName: String, offerDescription: String) {
        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
                     
            vc.itemName = offerName
            vc.itemDescription = offerDescription
            vc.type = "offer"
            vc.id = OfferID
                     
            self.present(vc, animated: true, completion: nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if tableView == ServicesTable {
            let counter = yourWorld.data?.offers?.count ?? 0
            
            if counter == 0 {
                if Requested {
                    Table1_Height.constant = 0
                }
                return yourWorld.data?.offers?.count ?? 0
            }else if counter < 3 {
                Table1_Height.constant = CGFloat((yourWorld.data?.offers?.count ?? 0) * 270)
                  return yourWorld.data?.offers?.count ?? 0
            }else if counter >= 3 {
                Table1_Height.constant = CGFloat(3 * 270)
                return 3
            }
            return 3
        }
//
        if tableView == ServicesTable2 {
            let counter = yourWorld.data?.offers?.count ?? 0
            if counter <= 3 {
                if Requested {
                    Table2_Height.constant = 0
                }
                return 0
            }else if counter > 5{
                 Table2_Height.constant = CGFloat( 2 * 260)
                return 2
            }else if counter > 3 {
                 Table2_Height.constant = CGFloat(((yourWorld.data?.offers?.count ?? 0)-3) * 260)
                return counter - 3
            }
            return 3
        }
        
        if tableView == ServicesTable3 {
            let pager = (yourWorld.data?.offers?.count ?? 0 >= 1) ? (has_more_pages ? 1 : 0): 0
            print("pager items num ==> \(pager)")

            let counter = (yourWorld.data?.offers?.count ?? 0)
            if counter <= 5 {
                if Requested {
                    Table3_Height.constant = 0
                }
                return 0
            }else if counter > 5 {
                 Table3_Height.constant = CGFloat(((yourWorld.data?.offers?.count ?? 0)-5) * 269)
                return (counter - 5 + pager)
            }
            return 5
        }
        
        
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if  tableView == ServicesTable {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MyWorldTableCell", for: indexPath) as? MyWorldTableCell {
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.delegate = self
                cell.UpdateView(offer: yourWorld.data?.offers?[indexPath.row] ?? Offer(), index: indexPath.row)
                return cell
            }
        }
        
        if  tableView == ServicesTable2 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MyWorldTableCell", for: indexPath) as? MyWorldTableCell {
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.delegate = self
                cell.UpdateView(offer: yourWorld.data?.offers?[indexPath.row+3] ?? Offer(), index: indexPath.row+3)
                return cell
            }
        }
        
        if  tableView == ServicesTable3 {
            
            if ((indexPath.row + 5 ) > ((yourWorld.data?.offers?.count ?? 0) - 1)){
                let cell = Bundle.main.loadNibNamed("LoadingTableViewCell", owner: self, options: nil)?.first as! LoadingTableViewCell

                    cell.loader.startAnimating()
                    return cell
            }

            if let cell = tableView.dequeueReusableCell(withIdentifier: "MyWorldTableCell", for: indexPath) as? MyWorldTableCell {
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.delegate = self
                cell.UpdateView(offer: yourWorld.data?.offers?[indexPath.row+5] ?? Offer(), index: indexPath.row+5)
                return cell
            }
        }
        
        
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == ServicesTable || tableView == ServicesTable2 || tableView == ServicesTable3 {
            let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "SalonOfferVC") as! SalonOfferVC
            let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = item
            self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "BackArrow")
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "BackArrow")
                
            if tableView == ServicesTable {
                vc.OfferID = "\(yourWorld.data?.offers?[indexPath.row].id ?? Int())"
            }else if tableView == ServicesTable2 {
                vc.OfferID = "\(yourWorld.data?.offers?[indexPath.row+3].id ?? Int())"
            }else if tableView == ServicesTable3 {
                vc.OfferID = "\(yourWorld.data?.offers?[indexPath.row+5].id ?? Int())"
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //for pagination
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //for videos pagination
        if tableView == ServicesTable3{
            
            if ((indexPath.row + 5) >= (self.yourWorld.data?.offers?.count ?? 0)) {
                
                if self.has_more_pages && !self.is_loading {
                    print("start loading")
                    self.GetYourWorld()
                }
            }
        }
           
     }
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let c = ServicesTable3.indexPathsForVisibleRows
        print("****************")
        print(c)
        
    }
}

extension MyWorldVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == AdsCollection {
            
            if yourWorld.data?.ads?.count ?? 0 == 0 && Requested {
                AdsHeight.constant = 0
            }
            return yourWorld.data?.ads?.count ?? 0
        }
        
        if collectionView == MostPopularCollection {
            
            if yourWorld.data?.slider_popular_centers?.count == 0 && Requested {
                PopularCentersHeight.constant = 0
            }
            
            return yourWorld.data?.slider_popular_centers?.count ?? 0
        }
 
        
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == AdsCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyWorldAdsCollCell", for: indexPath) as? MyWorldAdsCollCell {
                cell.UpdateView(ad: yourWorld.data?.ads?[indexPath.row] ?? Ad() )
                cell.id = "\(yourWorld.data?.ads?[indexPath.row].id ?? Int())"
                cell.link = yourWorld.data?.ads?[indexPath.row].link ?? ""
                return cell
            }
            
        }
        
        if collectionView == MostPopularCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MostPopularCollCell", for: indexPath) as? MostPopularCollCell {
                
                cell.updateView(center: yourWorld.data?.slider_popular_centers?[indexPath.row] ?? SliderPopularSalon())
                
                return cell
            }
        }
        
        return ForYouCollCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == AdsCollection {
            let height:CGSize = CGSize(width: self.AdsCollection.frame.width/1.6 , height: self.AdsCollection.frame.height)
            
            return height
        }
    
        if collectionView == MostPopularCollection {
            let height:CGSize = CGSize(width: self.MostPopularCollection.frame.width/3.6 , height: self.MostPopularCollection.frame.height)
            
            return height
        }

        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == AdsCollection {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WebVC") as! WebVC
            vc.link = yourWorld.data?.ads?[indexPath.row].link ?? ""
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if collectionView == MostPopularCollection {
              let salon_id = (yourWorld.data?.slider_popular_centers?[indexPath.row].id ?? 0)
             NavigationUtils.goToSalonProfile(from: self, salon_id: salon_id)
            
        }
        
       
        
    }
    
    
}

