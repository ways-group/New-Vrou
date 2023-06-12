//
//  YourWorldOfferCollCell.swift
//  Vrou
//
//  Created by Islam Elgaafary on 2/5/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage


protocol MyWorldOfferDelegate {
    func Like(offerID:String,isLike:String,index:Int)
    func Comment(OfferID:String ,offerName:String ,offerDescription:String)
    func Share(offerID:String,imageLink:String,index:Int)
    func OpenUsersList(offerID:String, guestNumbers:Int)
}


class YourWorldOfferCollCell: UICollectionViewCell {
    
    @IBOutlet weak var SalonImage: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var SalonCategory: UILabel!
    
    @IBOutlet weak var OfferImage: UIImageView!
    @IBOutlet weak var OfferName: UILabel!
    @IBOutlet weak var OfferDescription: UILabel!
    @IBOutlet weak var PriceLbl: UILabel!
    @IBOutlet weak var TimerLbl: UILabel!
    
    @IBOutlet weak var favouritesCountLbl: UILabel!
    @IBOutlet weak var CommentsCountsLbl: UILabel!
    @IBOutlet weak var ShareCountsLbl: UILabel!
    
    @IBOutlet weak var viewsCountLbl: UILabel!
    @IBOutlet weak var HeartLogo: UIImageView!
    @IBOutlet weak var watchingLbl: UILabel!
    @IBOutlet weak var usersCollection: UICollectionView!
    
    
    
    var delegate: MyWorldOfferDelegate!
    
    var mins = 0
    var hrs = 0
    var days = 0
    var sec = 0
    
    var timer = Timer()
    var isTimerRunning = false //This will be used to make sure only one timer is created at a time.
    var offerID = ""
    var imageLink = ""
    var is_like = ""
    var index = 0
    
    var guestNum = 0
    var users = [String]()
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        
    }
    
    
    override func prepareForReuse() {
        timer.invalidate()
    }
    
    
    @objc func updateTimer() {
        
        if sec > 0 {
            sec -= 1
        }else{
            if mins > 0 {
                mins -= 1
                sec = 59
                //  return
            }else {
                if hrs > 0 {
                    hrs -= 1
                    mins = 59
                    // return
                }else {
                    if days > 0 {
                        days -= 1
                        hrs = 23
                        mins = 59
                        //  return
                    }else {
                        TimerLbl.text = "Offer Ends!"
                    }
                }
            }
        }
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            TimerLbl.text = "Ends After \n \(days )D: \(hrs )H: \(mins )M: \(sec )sec"
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            TimerLbl.text = "ينتهي العرض بعد \n \(days )يوم: \(hrs )س: \(mins )د: \(sec )ث"
        }
        
    }
    
    
    func UpdateView(offer:Offer, index:Int) {
        
        usersCollection.dataSource = self
        usersCollection.delegate = self
        
        SetImage(image: SalonImage, link: offer.salon_logo ?? "")
        SalonName.text = offer.salon_name ?? ""
        SalonCategory.text = offer.salon_category_name ?? ""
        SetImage(image: OfferImage, link: offer.image ?? "")
        OfferName.text = offer.offer_name ?? ""
        OfferDescription.text = offer.offer_description ?? ""
        offerID = "\(offer.id ?? Int())"
        imageLink = offer.image ?? ""
        favouritesCountLbl.text = offer.favorites_count ?? ""
        CommentsCountsLbl.text = offer.comments_count ?? ""
        ShareCountsLbl.text = offer.share_count ?? ""
        viewsCountLbl.text = "\(offer.mobile_views ?? "0")"
        
        watchingLbl.text =  NSLocalizedString("Watching", comment: "")
        
        users.removeAll()
        offer.watching_users?.forEach({ (u) in
            users.append(u.image ?? "")
        })
        
        usersCollection.reloadData()
        
        guestNum  = (Int(offer.mobile_views ?? "0") ?? 0) - (offer.watching_users_count ?? 0)
        
        
        if offer.is_favorite ?? 0 == 0 {
            is_like = "0"
            HeartLogo.image = #imageLiteral(resourceName: "heartPinkBorder")
        }else {
            is_like = "1"
            HeartLogo.image = #imageLiteral(resourceName: "SocialHeart")
        }
        
        let currency = " \(offer.currency ?? "")"
        let finalString = (offer.new_price ?? "0") + currency
        let amountText = NSMutableAttributedString.init(string: finalString)
        amountText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .semibold),NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)], range: NSMakeRange(finalString.count-currency.count,currency.count))
        // set the attributed string to the UILabel object
        //
        PriceLbl.text = finalString
        
        mins = Int(offer.minutes ?? "0") ?? 0
        hrs = Int(offer.hours ?? "0") ?? 0
        days = Int(offer.days ?? "0") ?? 0
        sec = Int(offer.seconds ?? "0") ?? 0
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
        
            TimerLbl.text = "Ends After \n \(days )D: \(hrs )H: \(mins )M: \(sec )sec"
            
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            
            TimerLbl.text = "ينتهي العرض بعد \n \(days )يوم: \(hrs )س: \(mins )د: \(sec )ث"
        }
        
        self.index = index
        
        runTimer()
    }
    
    
    @IBAction func AddToFavouriteBtn_pressed(_ sender: Any) {
        
        if let delegate = self.delegate {
            delegate.Like(offerID: offerID, isLike: is_like, index: index)
        }
        
    }
    
    
    @IBAction func ShowCommentsBtn_pressed(_ sender: Any) {
        
        if let delegate = self.delegate {
            delegate.Comment(OfferID: offerID, offerName: OfferName.text!, offerDescription: OfferDescription.text!)
        }
        
    }
    
    
    @IBAction func ShareBtn_pressed(_ sender: Any) {
        
        if let delegate = self.delegate {
            delegate.Share(offerID: offerID, imageLink: imageLink, index: index )
        }
        
    }

    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
    }
    
    
    
    
}



extension YourWorldOfferCollCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
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
                delegate.OpenUsersList(offerID: offerID, guestNumbers: guestNum)
            }
            
         }
    
    
    
}
