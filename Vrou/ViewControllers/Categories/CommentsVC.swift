//
//  CommentsVC.swift
//  Vrou
//
//  Created by Mac on 1/8/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import ActiveLabel
import PKHUD
import Alamofire
import SwiftyJSON

class CommentsVC: UIViewController {
   // MARK: - IBOutlet
    @IBOutlet weak var CommentsTable: UITableView!
    @IBOutlet weak var CommentTxtView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var VideoImage: UIImageView!
    @IBOutlet weak var VideoTitle: UILabel!
    @IBOutlet weak var WatchingCountLbl: UILabel!
    @IBOutlet weak var watchingLbl: UILabel!
    @IBOutlet weak var usersCollection: UICollectionView!
    @IBOutlet weak var heartImage: UIImageView!
    @IBOutlet weak var AddNewCollectionView: UIView!

    var socialActions = SocialActions()
    var video:SalonVideo?
    var videoID = ""
    var imageLink = ""
    var is_like = ""
    var salonsVideo_list : [SalonVideo]? = []
    var indexPath =  0
    var guestNum = 0
    var users = [String]()
    var itemName = "" ; var timer = "" ; var itemDescription = ""; var id = ""
    var type = "" // must be [offer or product or service]
    var collections = CollectionsModel()
    var collectionsNames = [String]()

    // MARK: - Variables
    var comments = Comments()
    var success = ErrorMsg()
    var dismissKeyboard = true
    var toArabic = ToArabic()
    var chossenCollectionIndex = 0
    var collectionID = ""
    
    
    
    
    private var items = [Any?]()
 
    var requested = false
    var uiSupport = UISupport()
    
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
    var is_start_scrolling = false
    var randomVar = -1

    
    
    
    
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CommentsTable.delegate = self
        CommentsTable.dataSource = self
        
        CommentTxtView.delegate = self
        CommentTxtView.textColor = UIColor.lightGray
        
        usersCollection.dataSource = self
        usersCollection.delegate = self
        
//        itemNameLbl.text = itemName
       // watchesCountLbl.text = timer
//        itemDescriptionLbl.text = itemDescription
        
        if timer == "" {
//            endsAfterLbl.isHidden = true
        }
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            toArabic.ReverseButton(Button: sendBtn)
            CommentTxtView.text = NSLocalizedString("Type a comment", comment: "")
        }
        
        GetComments()
        
        SetImage(image: VideoImage, link: video?.image ?? "")
       
         
        VideoTitle.text = video?.video_name ?? ""
        
        imageLink = video?.image ?? ""
        is_like = "\(video?.is_liked ?? Int())"
        
        if is_like == "0" {
            heartImage.image = #imageLiteral(resourceName: "unlike")
        }else if is_like == "1" {
            heartImage.image = #imageLiteral(resourceName: "liked")
        }
        
        usersCollection.reloadData()

        //CollectionsCountLbl.text = video.collections_count ?? ""
        WatchingCountLbl.text = "\(video?.mobile_views ?? "0")"
        watchingLbl.text = NSLocalizedString("Watching", comment: "")
        video?.watching_users?.forEach({ (u) in
            users.append(u.image ?? "")
        })
        
    }
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
    
  
    

}

// MARK: - APIs Requests
extension CommentsVC {
    
    
// MARK: - SearchResult_API
func GetComments() {
    dismissKeyboard = false
    HUD.show(.progress , onView: view)
    let finalURL = "\(ApiManager.Apis.CommentsList.description)\(type)&commentable_id=\(id)&user_hash_id=\(User.shared.TakeHashID())"
        
    ApiManager.shared.ApiRequest(URL: finalURL , method: .get, Header: [ "Accept": "application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                HUD.hide()
                do {
                    self.comments = try JSONDecoder().decode(Comments.self, from: data!)
                    self.CommentsTable.reloadData()
                    if self.comments.data?.comments?.count ?? 0 == 0 {
                        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                            HUD.flash(.label("No comments found") , onView: self.view , delay: 1.5 , completion: nil)
                        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                            HUD.flash(.label("لا توجد تعليقات") , onView: self.view , delay: 1.5 , completion: nil)
                        }
                    }
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.GetComments()
                }
                self.present(vc, animated: true, completion: nil)
            }
            
        }
    
        dismissKeyboard = true
    
    }
    
    
    func SendComment() {
        HUD.show(.progress , onView: view)
        
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.AddComment.description, method: .post, parameters: ["commentable_id":id , "commentable_type":type , "body":CommentTxtView.text!],encoding: URLEncoding.default, Header:["Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json" , "locale" : UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier],ExtraParams: "", view: self.view) { (data, tmp) in
            if tmp == nil {
                HUD.hide()
                do {
                    self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                    HUD.flash(.label(self.success.msg?[0] ?? "Success") , onView: self.view , delay: 1.6 , completion: nil)
                    self.GetComments()
                    
                    self.CommentTxtView.text = "Type a comment"
                    self.CommentTxtView.textColor = UIColor.lightGray
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                keyWindow?.rootViewController = vc
                
            }
            
        }
    }
    
    
    func LikeDislikeComment(like:Int, id:String) {

        
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.LikeComment.description, method: .post, parameters: ["comment_id":id , "action_type": "\(like)"],encoding: URLEncoding.default, Header:["Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json" , "locale" : UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier],ExtraParams: "", view: self.view) { (data, tmp) in
            if tmp == nil {
                HUD.hide()
                do {
                    //self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                   // HUD.flash(.label(self.success.msg?[0] ?? "Success") , onView: self.view , delay: 1.6 , completion: nil)
                    self.GetComments()
                    
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

// MARK: - Buttons Actions
extension CommentsVC{
    @IBAction func FavouriteBtn_pressed(_ sender: Any) {
        if User.shared.isLogedIn() {
            LikeDislike(id: videoID, action: self.is_like, indexPath: indexPath)
            is_like = "\(video?.is_liked ?? Int())"
            if self.is_like == "0" {
                is_like = "1"
                self.heartImage.image = #imageLiteral(resourceName: "liked")
            }else if self.is_like == "1" {
                is_like = "0"
                self.heartImage.image = #imageLiteral(resourceName: "unlike")
            }
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
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
                           
                                  self.video?.likes_count = "\(self.socialActions.data?.likes_counts ?? Int())"
                                
                            if action == "0" {
                                self.video?.is_liked = 1
                            }else if action == "1" {
                                self.video?.is_liked = 0
                            }
                            
                              }catch {
                                  HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                              }
                              
                          }else if tmp == "401" {
                              let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                              keyWindow?.rootViewController = vc
                              
                          }
                          
                      }
            }
//
    @IBAction func CommentsBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
        
        vc.itemName = video?.video_name ?? ""
        vc.type = "video"
        vc.id = videoID
        
        self.present(vc, animated: true, completion: nil)
   
    }
    
    @IBAction func ShareBtn_pressed(_ sender: Any) {
        let url = URL(string: imageLink) ?? URL(string:"https://vrou.com")
        if let data = try? Data(contentsOf: url!)
        {
            let image: UIImage = UIImage(data: data) ?? UIImage()
            let activityVC = UIActivityViewController(activityItems: [image, salonsVideo_list?[indexPath].video ?? "", salonsVideo_list?[indexPath].video_name ?? "" ], applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToVimeo]
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
            self.ShareVideo(id: videoID, indexPath: indexPath)
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
                                       
                                    }catch {
                                        HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                                    }
                                    
                                }else if tmp == "401" {
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                                    keyWindow?.rootViewController = vc
                                    
                                }
                                
                            }
           }

    
    @IBAction func AddCollectoinBtn_pressed(_ sender: Any) {
        if User.shared.isLogedIn() {
            GetCollectionsData(videoID: videoID, indexPath: indexPath)
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
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
    
    @IBAction func xBtn_pressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func SendCommentBtn_pressed(_ sender: Any) {
        if CommentTxtView.text != NSLocalizedString("Type a comment", comment: "") && CommentTxtView.text != "" && User.shared.isLogedIn(){
            SendComment()
        }else {
            if !User.shared.isLogedIn(){
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
                vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                self.present(vc, animated: true, completion: nil)
            }
        }
        
    }
}


// MARK: - TableViewDelegate
extension CommentsVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return comments.data?.comments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableCell", for: indexPath) as? CommentTableCell {
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.delegate = self
            cell.UpdateView(comment: comments.data?.comments?[indexPath.row] ?? Comment())
            
            return cell
            
        }
        
        return CommentTableCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
}


// MARK: - LikeComment Delegate

extension CommentsVC:LikeComment {
    
    func Like(commentID : String, like: Bool) {
        if User.shared.isLogedIn(){
            LikeDislikeComment(like: like ? 1 : 0 , id: commentID)
        }
    }
    
}


// MARK: - TextViewDelegate
extension CommentsVC: UITextViewDelegate {
    
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


extension CommentsVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
         func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
             
            return users.count
         }
         
         
         func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
             
             if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PeopleCollCell", for: indexPath) as? PeopleCollCell {
                cell.UpdateView(image: users[indexPath.row])
                return cell
             }
             
             return collectionCollCell()
             
         }
         
         
         
         func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

                 //let height:CGSize = CGSize(width: collectionView.frame.width/2 , height: collectionView.frame.height)

                 return CGSize(width: 30, height: 30);


         }
  
         func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {


             return 0;
         }

         func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

             return -10
         }
         
         
         func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
             OpenUsersList(videoID: videoID, guestNumbers: guestNum)
         }
    
    
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
    
    
    
}

//MARK: - PickerDelegate

extension CommentsVC : UIPickerViewDataSource , UIPickerViewDelegate {
    
    


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

                    
//                    self.WatchTable.reloadData()
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
    
    
    
}





