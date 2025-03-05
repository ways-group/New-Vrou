//
//  WatchVC.swift
//  Vrou
//
//  Created by Mac on 11/20/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import ViewAnimator
import Alamofire
import SwiftyJSON
import PKHUD
import SideMenu

class WatchVC: BaseVC<BasePresenter, BaseItem> {
   
    // MARK: - IBOutlet
    @IBOutlet weak var noSaloneView: UIView!
    @IBOutlet weak var noSaloneImage: UIImageView!
    @IBOutlet weak var WatchTable: UITableView!
    @IBOutlet weak var AddNewCollectionView: UIView!
    @IBOutlet weak var CollectionNameTxtInput: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var helloUser : Hi!

    // MARK: - Variables
    private var items = [Any?]()
    private let animations = [AnimationType.from(direction: .left, offset: 60.0)]
    var requested = false
    var uiSupport = UISupport()
    var salonsVideo_list : [SalonVideo]? = []
    var socialActions = SocialActions()
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
    var is_start_scrolling = false
    var randomVar = -1
    ////
    var success = ErrorMsg()
    var collections = CollectionsModel()
    var collectionsNames = [String]()
    var chossenCollectionIndex = 0
    var collectionID = ""
    var videoID = ""
    var indexPath = 0
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavagationBar()
        helloUser.vc = self
        
        WatchTable.delegate = self
        WatchTable.dataSource = self
        WatchTable.separatorStyle = .none
        saveBtn.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        cancelBtn.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        CollectionNameTxtInput.placeholder = NSLocalizedString("Collection Name", comment: "")
        let offerImage = UIImage.gifImageWithName("barbershop waiting clients")
        noSaloneImage.image = offerImage
        GetSalonsVideo()
    }
    
    // MARK: - SetUpAnimations
    func SetupAnimation() {
        items = Array(repeating: nil, count: 1)
        WatchTable?.performBatchUpdates({
            UIView.animate(views: WatchTable.visibleCells,
                           animations: animations,
                           duration: 0.5)
        }, completion: nil)
    }
    
    // MARK: - SetUpSideMenu
     @IBAction func openSideMenu(_ button: UIButton){
               Vrou.openSideMenu(vc: self)
        }
    @IBAction func SaveBtn_pressed(_ sender: Any) {
        if CollectionNameTxtInput.text != "" {
            self.view.endEditing(true)
            AddCollectionRequest(params: ["type": "1" , "collection_name": CollectionNameTxtInput.text! , "item_id": videoID , "item_type": "video"], indexPath:indexPath)
            CollectionNameTxtInput.text = ""
            AddNewCollectionView.isHidden = true
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
    
    
    @IBAction func SearchBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "CentersSearchNavController") as! CentersSearchNavController
        keyWindow?.rootViewController = vc
    }
    
    
}

// MARK: - GetSalonsVideos_API

extension WatchVC {
    
    func GetSalonsVideo() {

        var FinalURL = ""
        current_page += 1
        is_loading = true
        is_start_scrolling = false
        
        var random_order = -1
        
        if (self.current_page == 1 )  {
            random_order = -1
        }
        else {
            random_order = randomVar
        }
        

        if current_page == 1 { HUD.show(.progress , onView: view) }
     
        if User.shared.isLogedIn() {
            FinalURL = "\(ApiManager.Apis.salonsVideo.description)\(User.shared.data?.user?.city?.id ?? 0)&page=\(current_page)&random_order_key=\(random_order)"
        }else {
            FinalURL = "\(ApiManager.Apis.salonsVideo.description)\(UserDefaults.standard.integer(forKey: "GuestCityId"))&page=\(current_page)&random_order_key=\(random_order)"
        }
        
        ApiManager.shared.ApiRequest(URL: FinalURL , method: .get, Header: [ "Accept": "application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            self.is_loading = false

            if tmp == nil {
                HUD.hide()
                do {
                    self.requested = true
                    let decoded_data = try JSONDecoder().decode(SalonsVideo.self, from: data!)
                    self.randomVar = decoded_data.data?.random_order_key ?? -1
                  
                    if self.current_page == 1 {
                        self.salonsVideo_list = decoded_data.data?.videos
                    }
                    else{
                        self.salonsVideo_list?.append(contentsOf: (decoded_data.data?.videos)!)
                    }
                
                    //get pagination data
                    let paginationModel = decoded_data.pagination
                    self.has_more_pages = paginationModel?.has_more_pages ?? false
                    
                    print("has_more_pages ==>\(self.has_more_pages)")

                    self.WatchTable.isHidden = false
                    self.noSaloneView.isHidden = true
                    self.WatchTable.reloadData()
                    if(self.salonsVideo_list?.count == 0){
                        self.WatchTable.isHidden = true
                        self.noSaloneView.isHidden = false
                    }
                 //   self.SetupAnimation()
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.GetSalonsVideo()
                }
                self.present(vc, animated: true, completion: nil)
            }

            
        }
    }
    
    
    
    func LikeDislike(id:String, action:String, indexPath:Int) // 0 for like 1 for dislike
    {
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.Like_Dislike.description, method: .post, parameters: ["likeable_id":id , "likeable_type":"video" , "action_type": action], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                    ExtraParams: "", view: self.view) { (data, tmp) in
                          if tmp == nil {
                              HUD.hide()
                              do {
                                  
                            self.socialActions = try JSONDecoder().decode(SocialActions.self, from: data!)
                           
                            self.salonsVideo_list?[indexPath].likes_count = "\(self.socialActions.data?.likes_counts ?? Int())"
                                
                            if action == "0" {
                                self.salonsVideo_list?[indexPath].is_liked = 1
                            }else if action == "1" {
                                self.salonsVideo_list?[indexPath].is_liked = 0
                            }
                                
                            self.WatchTable.reloadData()
                            
                              }catch {
                                  HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                              }
                              
                          }else if tmp == "401" {
                              let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                              keyWindow?.rootViewController = vc
                              
                          }
                          
                      }
            }
    
    
     func ShareVideo(id:String, indexPath:Int) {
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.ShareItem.description, method: .post, parameters: ["shareable_id":id, "shareable_type":"video"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json" , "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                           ExtraParams: "", view: self.view) { (data, tmp) in
                                 if tmp == nil {
                                     HUD.hide()
                                     do {
                                         
                                       self.socialActions = try JSONDecoder().decode(SocialActions.self, from: data!)
                                        
                                         self.salonsVideo_list?[indexPath].share_count = "\(self.socialActions.data?.share_count ?? Int())"
                                        
                                          self.WatchTable.reloadData()
                                        
                                     }catch {
                                         HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                                     }
                                     
                                 }else if tmp == "401" {
                                     let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                                     keyWindow?.rootViewController = vc
                                     
                                 }
                                 
                             }
            }
    
    
    func GetCollectionsData(videoID:String, indexPath:Int) {
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
                        self.PickerActionSheet(title: NSLocalizedString("Add the video to your collections", comment: ""), videoID: videoID, indexPath: indexPath)
                         
                     }catch {
                         HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                     }
                     
                 }else if tmp == "401" {
                     let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                     keyWindow?.rootViewController = vc
                     
                 }else if tmp == "NoConnect" {
                     guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                     vc.callbackClosure = { [weak self] in
                        self?.GetCollectionsData(videoID: videoID, indexPath: indexPath)
                     }
                     self.present(vc, animated: true, completion: nil)
                 }
         }
     }
    
    
    func AddCollectionRequest(params: [String:String],  indexPath:Int) {
        HUD.show(.progress , onView: view)
           ApiManager.shared.ApiRequest(URL: ApiManager.Apis.CreateCollection_addItem.description, method: .post, parameters: params, encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                       ExtraParams: "", view: self.view) { (data, tmp) in
                               if tmp == nil {
                                   HUD.hide()
                               do {
                                   self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                                   HUD.flash(.label(self.success.msg?[0] ?? "Success") , onView: self.view , delay: 1.6 , completion: {
                                       (tmp) in
                                    self.GetSalonsVideo()
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
    
    
}



// MARK: - TableViewDelegate

extension WatchVC: UITableViewDelegate , UITableViewDataSource, WatchDelegate {
    
    func OpenUsersList(videoID: String, guestNumbers: Int) {
        
        if User.shared.isLogedIn() {
            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "UsersListVC") as! UsersListVC
            vc.watchable_id = videoID
            vc.watchable_type = "video"
            vc.guestView = guestNumbers
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
   
    func Like(videoID: String, isLike: String, indexPath: Int) {
        if User.shared.isLogedIn() {
            LikeDislike(id: videoID, action: isLike, indexPath: indexPath)
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    func Comment(videoID: String, videoName: String, indexPath: Int , video : SalonVideo) {
        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
        
        vc.itemName = videoName
        vc.type = "video"
        vc.id = videoID
        vc.video = video
        vc.salonsVideo_list = self.salonsVideo_list
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func Share(videoID: String, imageLink: String, indexPath: Int) {
        let url = URL(string: imageLink) ?? URL(string:"https://vrou.com")
        if let data = try? Data(contentsOf: url!)
        {
            let image: UIImage = UIImage(data: data) ?? UIImage()
            let activityVC = UIActivityViewController(activityItems: [image, salonsVideo_list?[indexPath].video ?? "",salonsVideo_list?[indexPath].video_name ?? "" ], applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToVimeo]
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
            self.ShareVideo(id: videoID, indexPath: indexPath)
        }
    }
    
    func AddCollection(videoID: String, indexPath: Int) {
        if User.shared.isLogedIn() {
            GetCollectionsData(videoID: videoID, indexPath: indexPath)
            self.videoID = videoID
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let pager = requested ? (has_more_pages ? 1 : 0): 0
        print("-- \(pager) ==== \(requested) ===\(has_more_pages)")

        return (salonsVideo_list?.count ?? 0) + pager
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if (indexPath.row >= salonsVideo_list?.count ?? 0){
            let cell = Bundle.main.loadNibNamed("LoadingTableViewCell", owner: self, options: nil)?.first as! LoadingTableViewCell
            
                cell.loader.startAnimating()
                
                return cell


        }
        else if let cell = tableView.dequeueReusableCell(withIdentifier: "WatchTableCell", for: indexPath) as? WatchTableCell {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.delegate = self
            cell.UpdateView(video: salonsVideo_list?[indexPath.row] ?? SalonVideo(), indexpath: indexPath.row)
            return cell
        }
        
        return CenterServicesTableCell()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "VideoPlayerVC") as! VideoPlayerVC
        vc.link =  salonsVideo_list?[indexPath.row].video ?? ""
        vc.id = "\(salonsVideo_list?[indexPath.row].salon?.id ?? Int())"
        vc.salon_name = salonsVideo_list?[indexPath.row].salon?.salon_name ?? ""
        vc.salon_category = salonsVideo_list?[indexPath.row].salon?.category?.category_name ?? ""
        vc.salon_description = salonsVideo_list?[indexPath.row].video_name ?? ""
        
        print(salonsVideo_list)
        vc.salon_Image = salonsVideo_list?[indexPath.row].salon?.salon_logo ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //for videos pagination
               print("\(indexPath.row) ***** \(salonsVideo_list?.count ?? 0)")
                   if (indexPath.row == (salonsVideo_list?.count ?? 0)) {
                       
                       print("\(indexPath.row) ***done** \(salonsVideo_list?.count ?? 0)")

                       if has_more_pages && !is_loading && (is_start_scrolling || (current_page == 1)) {
                           print("start loading")
                           GetSalonsVideo()
                       }
               }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        is_start_scrolling = true
        print("start scrolling")
    }
     
    @available(iOS 13.0, *)
     func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
         
         return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
             
             // Create an action for sharing
             let image = #imageLiteral(resourceName: "places")
             let profile = UIAction(title: "Salon profile", image: image.withTintColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)) ) { action in
                 
                NavigationUtils.goToSalonProfile(from: self, salon_id: self.salonsVideo_list?[indexPath.row].salon?.id ?? Int())
                
             }
             
             return UIMenu(title: "", children: [profile])
         }
         
     }
    
    
}



 //MARK: - PickerDelegate

extension WatchVC : UIPickerViewDataSource , UIPickerViewDelegate {


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

    func PickerActionSheet(title:String, videoID:String, indexPath:Int) {
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
            
            if self.collections.data?.collections?.count ?? 0 > 0 {
                self.collectionID = "\(self.collections.data?.collections?[self.chossenCollectionIndex].id ?? Int())"
                
                self.AddCollectionRequest(params: ["type": "2", "item_id": videoID , "item_type": "video" , "collection_id" : "\(self.collectionID)"], indexPath:indexPath)
            }
            
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

