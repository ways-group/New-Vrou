//
//  MapVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/26/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import GoogleMaps
import SideMenu
import Alamofire
import SwiftyJSON
import CoreLocation
import PKHUD
import SDWebImage
import HCSStarRatingView

class MapVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet weak var GoogleMapsView: GMSMapView!
    
    @IBOutlet weak var SalonImage: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var SalonCategory: UILabel!
    @IBOutlet weak var SalonCity: UILabel!
    @IBOutlet weak var SalonIs_open: UILabel!
    @IBOutlet weak var SalonStars: HCSStarRatingView!
    var salonID = ""
    
    @IBOutlet weak var SalonView: UIView!
    @IBOutlet weak var ArrowImage: UIImageView!
    
    var uiSupport = UISupport()
     let toArabic = ToArabic()
       var long = ""
       var lat = ""
       let locationManager = CLLocationManager()
       var nearBranches = NearBranches()
       var requested = false
    
    var locationArray = [""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
     //   GoogleMapsView.delegate = self
        setupSideMenu()
        if let nav = self.navigationController {
            uiSupport.TransparentNavigationController(navController: nav)
        }
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            toArabic.ReverseImage(Image: ArrowImage)
            
        }
        
        
        
        
        }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.locationManager.requestWhenInUseAuthorization()
        
               let authorizationStatus = CLLocationManager.authorizationStatus()
                if (authorizationStatus == CLAuthorizationStatus.denied ) {
                  
                   showSimpleActionSheet()
                }
                   if CLLocationManager.locationServicesEnabled() {
                          locationManager.delegate = self
                          locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                          locationManager.startUpdatingLocation()
                      }
               

    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        long = "\(locValue.longitude)"
        lat = "\(locValue.latitude)"
        
        if !requested {
            requested = true
          
                 // Do any additional setup after loading the view.
                 
                 GetMapData()
        }
    }
    
    private func setupSideMenu() {
             SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
           //SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view)
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
    
    
    @IBAction func SalonBtn_pressed(_ sender: Any) {
         NavigationUtils.goToSalonProfile(from: self, salon_id: Int(salonID) ?? 0)
    }
    
    
    @IBAction func BackBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "CenterNavController") as! CenterNavController
        UIApplication.shared.keyWindow?.rootViewController = vc

    }
    
    
    @IBAction func SearchBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "CentersSearchNavController") as! CentersSearchNavController
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
}

extension MapVC {
    
    
func GetMapData() {
           
ApiManager.shared.ApiRequest(URL:"\(ApiManager.Apis.NearBranchesMAP.description)lat=\(lat)&long=\(long)", method: .get, Header:[ "Accept": "application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en"], ExtraParams: nil, view: self.view) { (data, tmp) in
               if tmp == nil {
                   do {
                    let camera = GMSCameraPosition.camera(withLatitude: Double (self.lat) as! CLLocationDegrees, longitude: Double (self.long) as! CLLocationDegrees, zoom: 13.0)
                        let mapView = GMSMapView.map(withFrame: self.GoogleMapsView.bounds, camera: camera)
                        self.GoogleMapsView.addSubview(mapView)
                       self.nearBranches = try JSONDecoder().decode(NearBranches.self, from: data!)
                    let imageview = UIImageView()
                    self.nearBranches.data?.branches?.forEach({ (branch) in

                        self.SetImage(image: imageview, link: branch.salon_logo ?? "")
                        self.AddMarker(branchName: branch.branch_name ?? "", salonName: branch.salon_name ?? "", salonIcon: imageview.image ?? UIImage(), lat: branch.lat ?? "", long: branch.long ?? "", mapView:mapView, branch: branch, markerView: imageview)
                 
                       })
                    
                    
                   }catch {
                        HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                   }
                   
               }else if tmp == "NoConnect" {
               guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                      vc.callbackClosure = { [weak self] in
                           self?.GetMapData()
                      }
                           self.present(vc, animated: true, completion: nil)
                     }
           }
       }
    
    func SetImage(image:UIImageView , link:String){
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
    }
    
    func AddMarker(branchName:String, salonName:String, salonIcon:UIImage , lat:String , long:String , mapView:GMSMapView, branch:SalonMapBranch, markerView:UIImageView ) {
            let marker = GMSMarker()
            
            // I have taken a pin image which is a custom image
            let markerImage = salonIcon.withRenderingMode(.automatic)

            //creating a marker view
           // let markerView = UIImageView(image: markerImage)
//            markerView.image = markerImage
//            markerView.contentMode = .scaleAspectFit
//            markerView.clipsToBounds = true
//            markerView.frame = CGRect(x: markerView.frame.origin.x , y: markerView.frame.origin.x, width: 60, height: 60)
//            markerView.cornerRadius = 30
            
            let salonIcon2 = resizeImage(image: salonIcon, targetSize: CGSize(width: 60, height: 60))
            let salonIcon3 = salonIcon2.withRoundedCorners(radius: 30)
           
            marker.position = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!)
            marker.icon = salonIcon3
            marker.title = branchName
            marker.snippet = salonName
            marker.map = mapView
            marker.branch = branch
            mapView.selectedMarker = marker
            mapView.delegate = self
        
            var bounds = GMSCoordinateBounds()

            bounds = bounds.includingCoordinate(marker.position)

    }
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
          mapView.selectedMarker = marker
//        let data = marker.value(forKey: "\(marker.position.latitude)\(marker.position.longitude)") as! SalonMapBranch
        
        self.SetImage(image: self.SalonImage, link: marker.branch.salon_logo ?? "")
        self.SalonName.text = marker.branch.salon_name ?? ""
        self.SalonCategory.text = marker.branch.salon_category_name ?? "" // To be updated
        self.SalonCity.text = marker.branch.branch_name ?? ""
        
        
        if marker.branch.work_times?.count ?? 0 > 0 {
            if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                
                if marker.branch.work_times?[0].is_open_now == 1 {
                      SalonIs_open.text = "Open"
                }else {
                      SalonIs_open.text = "Close"
                }
                
            }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar"  {
                
                if marker.branch.work_times?[0].is_open_now == 1 {
                      SalonIs_open.text = "مفتوح"
                }else {
                      SalonIs_open.text = "مغلق"
                }
                
            }
            
        }else {
            if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                
                SalonIs_open.text = "Close"
                
            }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar"  {
                
                SalonIs_open.text = "مغلق"
            }
        }
        
        
        
        
        self.salonID = "\(marker.branch.salon_id ?? "")"
        SalonView.isHidden = false
        SalonStars.value =  CGFloat(truncating: NumberFormatter().number(from: marker.branch.salon_rate ?? "0.0") ?? 0)
        
        return true
    }
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    
    // MARK: - ShowActionSheet
    func showSimpleActionSheet() {
        let alert = UIAlertController(title: "", message: "Enable location Services ?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                     return
                }
                 if UIApplication.shared.canOpenURL(settingsUrl) {
                     UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                  }
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: false, completion: nil)
    }
    
    
    
}

extension GMSMarker {
    var branch: SalonMapBranch {
        set(branch) {
            self.userData = branch
        }

        get {
           return self.userData as! SalonMapBranch
       }
   }
}
