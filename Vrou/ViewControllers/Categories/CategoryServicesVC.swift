//
//  CategoryServicesVC.swift
//  BeautySalon
//
//  Created by Islam Elgaafary on 10/2/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import ViewAnimator
import Alamofire
import SwiftyJSON
import PKHUD
import SideMenu

class CategoryServicesVC: UIViewController {

    @IBOutlet weak var ServicesTable: UITableView!
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var NoServicesView: UIView!
  
    private var items = [Any?]()
    private let animations = [AnimationType.from(direction: .left, offset: 60.0)]
    
    var services = ServicesList()
    var CategoryID  = ""
    var HomeSalon = false
    var Home = "0"
    var requested = false
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
       ServicesTable.delegate = self
       ServicesTable.dataSource = self
       ServicesTable.separatorStyle = .none
        // Do any additional setup after loading the view.
       mainView.contentView = logo
       mainView.isShimmering = true
       mainView.shimmeringSpeed = 550
       mainView.shimmeringOpacity = 1
      // setupSideMenu()
       GetServicesData()
    }
    

   func SetupAnimation() {
        items = Array(repeating: nil, count: 1)
        ServicesTable?.performBatchUpdates({
            UIView.animate(views: ServicesTable.visibleCells,
                           animations: animations,
                           duration: 0.5)
        }, completion: nil)

        
    }
    
    private func setupSideMenu() {
             SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
          // SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view)
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


}

extension CategoryServicesVC {
    
    func GetServicesData() {
           var FinalURL = ""
        current_page += 1
        is_loading = true

        if HomeSalon {
            if User.shared.isLogedIn() {
                 FinalURL = "\(ApiManager.Apis.ServicesListHomeSalon.description)\(Home)&city_id=\(User.shared.data?.user?.city?.id ?? 0)&page=\(current_page)"
            }else {
                 FinalURL = "\(ApiManager.Apis.ServicesListHomeSalon.description)\(Home)&city_id=\(UserDefaults.standard.integer(forKey: "GuestCityId"))&page=\(current_page)"
            }
           
        }else {
            if User.shared.isLogedIn() {
                 FinalURL = "\(ApiManager.Apis.ServicesList.description)\(CategoryID)&city_id=\(User.shared.data?.user?.city?.id ?? 0)&page=\(current_page)"
            }else {
                 FinalURL = "\(ApiManager.Apis.ServicesList.description)\(CategoryID)&city_id=\(UserDefaults.standard.integer(forKey: "GuestCityId"))&page=\(current_page)"
            }
         
        }
            ApiManager.shared.ApiRequest(URL: FinalURL , method: .get, Header: [ "Accept": "application/json",
            "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
               
                self.is_loading = false
                if tmp == nil {
                    HUD.hide()
                    do {
                        self.requested = true
                       let decoded_data =  try JSONDecoder().decode(ServicesList.self, from: data!)
                        
                        if (self.current_page == 1){
                            self.services  = decoded_data
                        }else{
                            self.services.data?.services?.append(contentsOf: (decoded_data.data?.services)!)
                         }
                        //get pagination data
                        let paginationModel = decoded_data.pagination
                        self.has_more_pages = paginationModel?.has_more_pages ?? false
                        
                        print("has_more_pages ==>\(self.has_more_pages)")

                        
                        
                        self.ServicesTable.reloadData()
                       // self.SetupAnimation()
                        self.mainView.isHidden = true
                        self.mainView.isShimmering = false
                        
                    }catch {
                        HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                    }
                    
                }else if tmp == "401" {
                   let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                   keyWindow?.rootViewController = vc
                   
               }else if tmp == "NoConnect" {
                   guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                          vc.callbackClosure = { [weak self] in
                               self?.GetServicesData()
                          }
                               self.present(vc, animated: true, completion: nil)
                         }
                   
               }
               
           }
       }

// MARK:- TableDelegate
extension CategoryServicesVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if services.data?.services?.count ?? 0 == 0 && requested{
            NoServicesView.isHidden = false
        }else {
             NoServicesView.isHidden = true
        }
        let pager = (services.data?.services?.count ?? 0 >= 1) ? (has_more_pages ? 1 : 0): 0
        print("pager items num ==> \(pager)")
        return (services.data?.services?.count ?? 0) + pager
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row >= services.data?.services?.count ?? 0){
            let cell = Bundle.main.loadNibNamed("LoadingTableViewCell", owner: self, options: nil)?.first as! LoadingTableViewCell
            
            cell.loader.startAnimating()
            return cell
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryServiceTableCell", for: indexPath) as? CategoryServiceTableCell {
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            cell.UpdateView(service: services.data?.services?[indexPath.row] ?? Service(), home: Home)
            return cell
        }
        
        return CenterServicesTableCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "SalonProfile", bundle: nil).instantiateViewController(withIdentifier: "ReservationViewController") as! ReservationViewController
        vc.ServiceID = "\(services.data?.services?[indexPath.row].id ?? Int())"
        vc.salonID = "\(services.data?.services?[indexPath.row].Salon_id ?? "")"
        
        if Home == "1" {
            vc.FromHome = true
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
 
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //for videos pagination
        //  print("\(indexPath.row) ***** \(serviceSearch?.count ?? 0)")
        if (indexPath.row >= (services.data?.services?.count ?? 0)) {
            
            //print("\(indexPath.row) ***done** \(serviceSearch?.count ?? 0)")
            
            if has_more_pages && !is_loading {
                //&& (is_start_scrolling || (current_page == 1)) {
                print("start loading")
                GetServicesData()
                
            }
        }
    }
    
//    @available(iOS 13.0, *)
//    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
//
//        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
//
//            // Create an action for sharing
//            let image = #imageLiteral(resourceName: "places")
//            let profile = UIAction(title: "Salon profile", image: image.withTintColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)) ) { action in
//
//                if self.services.data?.services?[indexPath.row].branches?.count ?? 0 > 0 {
//
//                    NavigationUtils.goToSalonProfile(from: self, salon_id: Int(self.services.data?.services?[indexPath.row].Salon_id ?? "") ?? Int())
//                }
//            }
//
//            return UIMenu(title: "", children: [profile])
//        }
//
//    }
        
    
    
    
}
