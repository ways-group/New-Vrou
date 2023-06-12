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
    @IBOutlet weak var itemNameLbl: UILabel!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var itemDescriptionLbl: ActiveLabel!
    @IBOutlet weak var endsAfterLbl: UILabel!
    @IBOutlet weak var CommentTxtView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    
    
    var itemName = "" ; var timer = "" ; var itemDescription = ""; var id = ""
    var type = "" // must be [offer or product or service]
    
    // MARK: - Variables
    var comments = Comments()
    var success = ErrorMsg()
    var dismissKeyboard = true
    var toArabic = ToArabic()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CommentsTable.delegate = self
        CommentsTable.dataSource = self
        
        CommentTxtView.delegate = self
        CommentTxtView.textColor = UIColor.lightGray
        
        itemNameLbl.text = itemName
        timerLbl.text = timer
        itemDescriptionLbl.text = itemDescription
        
        if timer == "" {
            endsAfterLbl.isHidden = true
        }
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            toArabic.ReverseButton(Button: sendBtn)
            CommentTxtView.text = NSLocalizedString("Type a comment", comment: "")
        }
        
        GetComments()
        
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
                UIApplication.shared.keyWindow?.rootViewController = vc
                
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
                UIApplication.shared.keyWindow?.rootViewController = vc
                
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

