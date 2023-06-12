//
//  WatchTableCell.swift
//  Vrou
//
//  Created by Mac on 11/20/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

protocol WatchDelegate {
    func Like(videoID:String,isLike:String, indexPath:Int)
    func Comment(videoID:String ,videoName:String, indexPath:Int)
    func Share(videoID:String,imageLink:String, indexPath:Int)
    func AddCollection(videoID:String, indexPath:Int)
    func OpenUsersList(videoID:String, guestNumbers:Int)
}


class WatchTableCell: UITableViewCell {
    
    @IBOutlet weak var VideoImage: UIImageView!
    @IBOutlet weak var SalonImage: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var SalonCategory: UILabel!
    @IBOutlet weak var VideoTitle: UILabel!
    
    @IBOutlet weak var FavouriteCountLbl: UILabel!
    @IBOutlet weak var CommentsCountLbl: UILabel!
    @IBOutlet weak var ShareCountLbl: UILabel!
    @IBOutlet weak var CollectionsCountLbl: UILabel!
    @IBOutlet weak var timeAgo: UILabel!
    @IBOutlet weak var heartImage: UIImageView!
    @IBOutlet weak var WatchingCountLbl: UILabel!
    @IBOutlet weak var watchingLbl: UILabel!
    @IBOutlet weak var usersCollection: UICollectionView!
    
    
    var delegate: WatchDelegate!
    
    var videoID = ""
    var imageLink = ""
    var is_like = ""
    var indexPath =  0
    var guestNum = 0
    var users = [String]()
    
    override func awakeFromNib() {
        usersCollection.dataSource = self
        usersCollection.delegate = self
    }
    
    
    func UpdateView(video:SalonVideo, indexpath:Int) {
        SetImage(image: VideoImage, link: video.image ?? "")
        SetImage(image: SalonImage, link: video.salon?.salon_logo ?? "")
        SalonName.text = video.salon?.salon_name ?? ""
        SalonCategory.text = video.salon?.category?.category_name ?? ""
        VideoTitle.text = video.video_name ?? ""
        
        videoID = "\(video.id ?? Int())"
        imageLink = video.image ?? ""
        is_like = "\(video.is_liked ?? Int())"
        
        if is_like == "0" {
            heartImage.image = #imageLiteral(resourceName: "HeartPink")
        }else if is_like == "1" {
            heartImage.image = #imageLiteral(resourceName: "SocialHeart")
        }
        
        FavouriteCountLbl.text = video.likes_count ?? ""
        CommentsCountLbl.text = video.comments_count ?? ""
        ShareCountLbl.text = video.share_count ?? ""
        CollectionsCountLbl.text = video.collections_count ?? ""
        timeAgo.text = video.created_time ?? ""
        WatchingCountLbl.text = "\(video.mobile_views ?? "0")"
        watchingLbl.text = NSLocalizedString("Watching", comment: "")
        self.indexPath = indexpath
        
        users.removeAll()
        video.watching_users?.forEach({ (u) in
            users.append(u.image ?? "")
        })
        
        usersCollection.reloadData()
        
        guestNum  = (Int(video.mobile_views ?? "0") ?? 0) - (video.watching_users_count ?? 0)
    }
    
    
    func UpdateView_center(album:SalonAlbum) {
        SetImage(image: SalonImage, link: album.image ?? "")
        SalonName.text = album.name ?? ""
    }
    
    
    @IBAction func FavouriteBtn_pressed(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.Like(videoID: videoID, isLike: is_like, indexPath: indexPath)
        }
    }
    
    @IBAction func CommentsBtn_pressed(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.Comment(videoID: videoID, videoName: VideoTitle.text!, indexPath: indexPath)
        }
    }
    
    @IBAction func ShareBtn_pressed(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.Share(videoID: videoID, imageLink: imageLink, indexPath: indexPath)
        }
    }
    
    @IBAction func AddCollectoinBtn_pressed(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.AddCollection(videoID: videoID, indexPath: indexPath)
        }
    }
    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
}

extension WatchTableCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
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
            
            if let delegate = self.delegate {
                delegate.OpenUsersList(videoID: videoID, guestNumbers: guestNum)
            }
            
         }
    
    
    
}
