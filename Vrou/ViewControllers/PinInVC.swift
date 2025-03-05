//
//  PinInVC.swift
//  Vrou
//
//  Created by Mac on 1/28/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import PKHUD

class PinInVC: UIViewController {
    
    // MARK: - IBoutlets
    @IBOutlet weak var noSalonImage: UIImageView!
    @IBOutlet weak var CentersCollection: UICollectionView!
    @IBOutlet weak var NoCentersView: UIView!
    @IBOutlet weak var noCentersLbl: UILabel!
    
    // MARK: - Variables
    var centersList = CentersList()
    var toArabic = ToArabic()
    var requested = false
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
    
    var FriendPins = false
    var friendUserID = ""
    
     // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        CentersCollection.delegate = self
        CentersCollection.dataSource = self
        noCentersLbl.text = NSLocalizedString("No Centers", comment: "")
        CentersCollection.register(UINib(nibName: "LoadingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LoadingCollectionViewCell")
        GetCentersData()
        // Do any additional setup after loading the view.
        let offerImage = UIImage.gifImageWithName("barbershop waiting clients")
        noSalonImage.image = offerImage
    }
 

}

// MARK: - API Requetss
extension PinInVC {
    
    func GetCentersData() {
        var FinalURL = ""
        current_page += 1
        is_loading = true
        HUD.show(.progress , onView: view)
        
        if FriendPins {
            FinalURL = "\(ApiManager.Apis.VisitedSalon.description)\(current_page)&user_id=\(friendUserID)"
        }else {
            FinalURL = "\(ApiManager.Apis.VisitedSalon.description)\(current_page)"
        }
        
            
           ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())", "Accept": "application/json",
           "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
                 
        
            self.is_loading = false

                 if tmp == nil {
                     HUD.hide()
                     do {
                        self.requested = true
                        let decoded_data = try JSONDecoder().decode(CentersList.self, from: data!)
                        
                        if (self.current_page == 1 )  {
                            self.centersList = decoded_data                        }
                        else {
                             self.centersList.data?.salons?.append(contentsOf: (decoded_data.data?.salons)!)
                        }
                        
                        //get pagination data
                        let paginationModel = decoded_data.pagination
                        self.has_more_pages = paginationModel?.has_more_pages ?? false
                        
                        print("has_more_pages ==>\(self.has_more_pages)")

                        self.CentersCollection.reloadData()
                       // self.SetupAnimation()

                        
                        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                            self.toArabic.ReverseCollectionDirection(collectionView: self.CentersCollection)
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
    
}


 // MARK: - CollectionView Delegate
extension PinInVC:UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
       
            if centersList.data?.popular_center?.count ?? 0 == 0 && centersList.data?.salons?.count ?? 0 == 0 && requested {
                NoCentersView.isHidden = false
            }else {
                NoCentersView.isHidden = true
            }

            let pager = requested ? (has_more_pages ? 1 : 0): 0
            return (centersList.data?.salons?.count ?? 0) + pager

        return 0
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (indexPath.row >= centersList.data?.salons?.count ?? 0) {

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCollectionViewCell", for: indexPath) as! LoadingCollectionViewCell

            cell.loader.startAnimating()

            return cell
        }
        else if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CenterCollCell", for: indexPath) as? CenterCollCell {

            cell.UpdateView(salon: centersList.data?.salons?[indexPath.row] ?? Salon())

            return cell
        }
    return CenterCollCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
       // for center pagination
        if (indexPath.row >= centersList.data?.salons?.count ?? 0) {

            if has_more_pages && !is_loading {
                print("start loading")
                self.GetCentersData()
            }
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height:CGSize = CGSize(width: self.CentersCollection.frame.width , height: CGFloat(90))
        
        return height
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
           
           
           return 0;
       }
       
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
           
           return 0
       }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var salon_id = 0
        salon_id = centersList.data?.salons?[indexPath.row].id ?? 0
        NavigationUtils.goToSalonProfile(from: self, salon_id: salon_id)
    
    }
    
    
    
}
