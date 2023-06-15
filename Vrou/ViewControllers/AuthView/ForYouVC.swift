//
//  ForYouVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/5/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PKHUD
import ViewAnimator
import MOLH

class ForYouVC: UIViewController , UIScrollViewDelegate{
    
    // MARK: - IBOutlet
    @IBOutlet weak var SalonsCollection: UICollectionView!
    @IBOutlet weak var PageControl: UIPageControl!
    @IBOutlet weak var StartImage: UIImageView!
    @IBOutlet weak var ArrowImage: UIImageView!
    
    
    // MARK: - Varibles
    var recommendSalons = RecommendSalons()
    var salons = [Salon]()
    let toArabic = ToArabic()
    
    // Ainmations
    private var items = [Any?]()
    private let animations = [AnimationType.from(direction: .left, offset: 60.0)]
    
    // Flags
    var cellHeight = CGSize()
    var SalonID = ""
    

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            toArabic.ReverseImage(Image: StartImage)
            toArabic.ReverseImage(Image: ArrowImage)
        }
        SalonsCollection.delegate = self
        SalonsCollection.dataSource = self
        GetForYouData()
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - StartBtn
    @IBAction func StartBtn_pressed(_ sender: Any) {
         goToHome()
    }
    
    
    // MARK: - X_btn
    @IBAction func X_btn_pressed(_ sender: Any) {
        goToHome()
    }
    
   
    // MARK: - ScrollDelgate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == SalonsCollection {
            //            PageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
            let tt = ceil(scrollView.contentOffset.x) / (scrollView.frame.width)
            var t = Int(ceil(scrollView.contentOffset.x) / (scrollView.frame.width))
            
            if (tt - floor(tt) > 0.000001) {
                t = t+1
            }
            
            PageControl.currentPage = t
            
        }
    }
    
    
    // MARK: - SetupAnimations
    func SetupAnimation() {
        items = Array(repeating: nil, count: 1)
        SalonsCollection?.performBatchUpdates({
            UIView.animate(views: SalonsCollection.visibleCells,
                           animations: animations,
                           duration: 0.5)
        }, completion: nil)
        
    }
    
    
}



extension ForYouVC {
    
    // MARK: - ForYouAPI
    func GetForYouData() {
        if User.shared.isLogedIn() {
            ApiManager.shared.ApiRequest(URL: "\(ApiManager.Apis.RecommendSalons.description)\(User.shared.data?.user?.city?.id ?? 0)", method: .get, Header: [
                "Authorization":"Bearer \(User.shared.TakeToken())",
                "Accept": "application/json",
                "locale": UserDefaults.standard.string(forKey: "Language") ?? "en",
                "timezone": TimeZoneValue.localTimeZoneIdentifier
            ], ExtraParams: "", view: self.view) { (data, tmp) in
                
                if tmp == nil {
                    HUD.hide()
                    do {
                        self.recommendSalons = try JSONDecoder().decode(RecommendSalons.self, from: data!)
                        self.SalonsCollection.reloadData()
                        self.recommendSalons.data?.categories?.forEach({ (category) in
                            category.salons?.forEach({ (salon) in
                                self.salons.append(salon)
                            })
                        })
                        self.SetupAnimation()
                    }catch {
                        HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                    }
                    
                }else if tmp == "401" {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    keyWindow?.rootViewController = vc
                }else if tmp == "NoConnect" {
                    guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                    vc.callbackClosure = { [weak self] in
                        self?.GetForYouData()
                    }
                    self.present(vc, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    
    
    // MARK: - FollowSalonAPI
    func FollowSalon(follow:Bool , id:String) {
        var FinalURL = ""
        if follow {
            FinalURL = ApiManager.Apis.FollowSalon.description
        }else {
            FinalURL = ApiManager.Apis.unfollowSalon.description
        }
        if User.shared.isLogedIn() {
            ApiManager.shared.ApiRequest(URL: FinalURL, method: .post, parameters: ["salon_id": id], encoding: URLEncoding.default, Header: [
                "Authorization":"Bearer \(User.shared.TakeToken())",
                "Accept": "application/json",
                "locale": UserDefaults.standard.string(forKey: "Language") ?? "en",
                "timezone": TimeZoneValue.localTimeZoneIdentifier
            ], ExtraParams: "", view: self.view) { (data, tmp) in
                
                if tmp == nil {
                    HUD.hide()
                }else if tmp == "401" {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
        }
    }
    
    
}




// MARK: - CollecitonViewDelegate
extension ForYouVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout , FollowProtocol {
    func Follow(id: String) {
        FollowSalon(follow: true, id: id)
    }
    
    func UnFollow(id: String) {
        FollowSalon(follow: false, id: id)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == SalonsCollection {
            return salons.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForYouCollCell", for: indexPath) as? ForYouCollCell {
            
            cell.UpdateView(height: cellHeight, salon: salons[indexPath.row])
            let c = Float(Float(salons.count)/Float(5))
            let pages = ceil(c);
            PageControl.numberOfPages = Int(pages)
            cell.delegate = self
            return cell
        }
        
        return ForYouCollCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height:CGSize = CGSize(width: self.SalonsCollection.frame.width , height: self.SalonsCollection.frame.height/4)
       
        cellHeight = height
        
        return height
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    
}



