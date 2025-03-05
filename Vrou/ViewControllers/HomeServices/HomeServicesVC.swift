//
//  HomeServicesVC.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/19/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import ViewAnimator
import SwiftyJSON
import PKHUD
import XLPagerTabStrip

class HomeServicesVC: UIViewController,IndicatorInfoProvider {
  
    @IBOutlet weak var noServiceImage: UIImageView!
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var Logo: UIImageView!
    @IBOutlet weak var ServicesCollection: UICollectionView!
    @IBOutlet weak var NoServicesView: UIView!
   
    var vrouSections = Sections()
    var servicesCategories = ServiceCategories()
    var toArabic = ToArabic()
    var itemInfo = IndicatorInfo(title: NSLocalizedString("Services", comment: ""), image: #imageLiteral(resourceName: "serviceIcon"))
 
    var didLoad = false
    var requested = false
    var RefreshData = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ServicesCollection.SetUpCollectionView(VC: self, cellIdentifier: "ServicesCollCell")
        
        mainView.isHidden = false
        mainView.contentView = Logo
        mainView.isShimmering = true
        mainView.shimmeringSpeed = 550
        mainView.shimmeringOpacity = 1
        create_observer()
        
        let offerImage = UIImage.gifImageWithName("barbershop waiting clients")
        noServiceImage.image = offerImage
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if RefreshData {
            NotificationCenter.default.post(name:  NSNotification.Name("categoryHeader"), object: nil, userInfo: ["title" : self.itemInfo.title ?? ""])
            GetSectionsData()
        }else {
            RefreshData = true
        }
           
      }
    
    
    func create_observer(){
         NotificationCenter.default.addObserver(self, selector: #selector(getData(_:)), name: NSNotification.Name("categoryHeaderSelect"), object: nil)
     }
     @objc func getData(_ notification: NSNotification) {
         guard let getTitle = notification.userInfo?["title"] as? String else { return }
         
        if getTitle == itemInfo.title {
            guard let getID = notification.userInfo?["id"] as? String  else { return }
           
            self.mainView.isHidden = false
            self.mainView.isShimmering = true
            GetServicesCatgeoriesData(id: getID)
        }
         
         
     }
     
     deinit {
         NotificationCenter.default.removeObserver(self,name: NSNotification.Name("categoryHeaderSelect"),object: nil)
     }

    
    
    @IBAction func SalonServicesBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "CategoryServicesVC") as! CategoryServicesVC
        vc.HomeSalon = true
        vc.Home = "0"
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func HomeServiceBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "CategoryServicesVC") as! CategoryServicesVC
        vc.HomeSalon = true
        vc.Home = "1"
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.navigationController?.pushViewController(vc, animated: true)
    }
  
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
}

extension HomeServicesVC {
    
    
    // MARK: - GetVrouSection_API
     func GetSectionsData() {
       
        if didLoad {
             HUD.show(.progress , onView: view)
        }
        
         var FinalURL = ""
         if User.shared.isLogedIn() {
             FinalURL = "\(ApiManager.Apis.Sections.description)?city_id=\(User.shared.data?.user?.city?.id ?? 0)"
         }else {
             FinalURL = "\(ApiManager.Apis.Sections.description)?city_id=\(UserDefaults.standard.integer(forKey: "GuestCityId"))"
         }
         
         
         ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: [ "Accept": "application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
               
             if tmp == nil {
                 HUD.hide()
                 do {
                    self.vrouSections = try JSONDecoder().decode(Sections.self, from: data!)
                    NotificationCenter.default.post(name:  NSNotification.Name("categoryHeader"), object: nil, userInfo: ["data" : self.vrouSections.data ?? []])
                  
                    self.GetServicesCatgeoriesData(id:"0")
                   
                    if !self.didLoad {
                        self.didLoad = true
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
                           self?.GetSectionsData()
                      }
                           self.present(vc, animated: true, completion: nil)
                     }
               
           }
       }
    
    
    // MARK: - GetServicesCategories_API
    func GetServicesCatgeoriesData(id:String) {
        var FinalURL = ""
        
        if User.shared.isLogedIn() {
            FinalURL = "\(ApiManager.Apis.InServicesCategories.description)\(id)&city_id=\(User.shared.data?.user?.city?.id ?? 0)"
        }else {
            FinalURL = "\(ApiManager.Apis.InServicesCategories.description)\(id)&city_id=\(UserDefaults.standard.integer(forKey: "GuestCityId"))"
        }
        
           ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: [ "Accept": "application/json",
           "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
                 
                 if tmp == nil {
                     HUD.hide()
                    do {
                        self.requested = true
                        self.servicesCategories = try JSONDecoder().decode(ServiceCategories.self, from: data!)
                        self.ServicesCollection.reloadData()
                        //self.SetupAnimation()
                        self.mainView.isHidden = true
                        self.mainView.isShimmering = false
                        
                        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                            self.toArabic.ReverseCollectionDirection(collectionView: self.ServicesCollection)
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





// MARK: - CollectionViewDelegate
extension HomeServicesVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
//        if collectionView == SectionCollection || collectionView == SecondSectionCollection  {
//                   return sections.data?.count ?? 0
//            }
        
        
        if collectionView == ServicesCollection {
            if servicesCategories.data?.serviceCategories?.count ?? 0 == 0 && requested{
                NoServicesView.isHidden = false
            }else {
                NoServicesView.isHidden = true
            }
            
            return servicesCategories.data?.serviceCategories?.count ?? 0
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
//        if collectionView == SectionCollection || collectionView == SecondSectionCollection {
//            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BeautySectionCollCell", for: indexPath) as? BeautySectionCollCell {
//
//                cell.UpdateView(category: sections.data?[indexPath.row] ?? Category())
//
//
//                return cell
//            }
//        }
        
        
        if collectionView == ServicesCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServicesCollCell", for: indexPath) as? ServicesCollCell {
                
                cell.UpdateView_home(category: servicesCategories.data?.serviceCategories?[indexPath.row] ?? Category())
                
                return cell
            }
        }
        
        return ForYouCollCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        if collectionView == SectionCollection || collectionView == SecondSectionCollection{
//            let height:CGSize = CGSize(width: self.SectionCollection.frame.width/4.6 , height: self.SectionCollection.frame.height)
//
//            return height
//        }
        
        
        if collectionView == ServicesCollection {
            let height:CGSize = CGSize(width: self.ServicesCollection.frame.width/3 , height: self.ServicesCollection.frame.height/3)
            return height
        }

        
   
        
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == ServicesCollection {
            RefreshData = false
            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "CategoryServicesVC") as! CategoryServicesVC
            vc.CategoryID = "\(servicesCategories.data?.serviceCategories?[indexPath.row].id ?? Int())"
            self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    
    
    
    
    
}
