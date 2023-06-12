//
//  CommentTableCell.swift
//  Vrou
//
//  Created by Mac on 1/8/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

protocol LikeComment {
    func Like(commentID:String, like:Bool)
}


class CommentTableCell: UITableViewCell {

    @IBOutlet weak var MainView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var timeAgoLbl: UILabel!
    @IBOutlet weak var LikeBtn: UIButton!
    @IBOutlet weak var likesCountLbl: UILabel!
    
    var delegate : LikeComment!
    var commentID = ""
    var liked = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func UpdateView(comment:Comment) {
        SetImage(image: userImage, link: comment.user?.image ?? "")
        userName.text = comment.user?.name ?? ""
        commentLbl.text = comment.body ?? ""
        timeAgoLbl.text = comment.created_time ?? ""
        
        if comment.is_liked == 0 {
            LikeBtn.setImage(#imageLiteral(resourceName: "HeartPink"), for: .normal)
            liked = false
        }else {
            LikeBtn.setImage(#imageLiteral(resourceName: "HeartPink-1"), for: .normal)
            liked = true
        }
        
        likesCountLbl.text = comment.likes_count ?? "0"
        commentID = "\(comment.id ?? Int())"
    }
    
    
    @IBAction func LikeBtn_pressed(_ sender: Any) {
        
        if let delegate = self.delegate {
            delegate.Like(commentID: commentID, like: liked)
        }
        
    }
    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
    
    
    

}
