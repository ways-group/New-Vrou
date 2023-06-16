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

class MapVC: BaseVC<BasePresenter, BaseItem>, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet weak var GoogleMapsView: GMSMapView!
    
    @IBOutlet weak var SalonImage: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var SalonCategory: UILabel!
    @IBOutlet weak var SalonCity: UILabel!
    @IBOutlet weak var SalonStars: HCSStarRatingView!
    
    @IBOutlet weak var SalonView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var directionView: UIView!
    @IBOutlet weak var areasTable: UITableView!
    @IBOutlet weak var areaBtn: UIButton!
    
    
    let toArabic = ToArabic()
    var long = ""
    var lat = ""
    var salonID = ""
    var areaID = ""
    let locationManager = CLLocationManager()
    var nearBranches = NearBranches()
    var selectedBranch: SalonMapBranch? = SalonMapBranch()
    var areas = Areas()
    var requested = false
    
    var locationArray = [""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //   GoogleMapsView.delegate = self

        setTransparentNavagtionBar()
        areasTable.delegate = self
        areasTable.dataSource = self
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            //toArabic.ReverseImage(Image: ArrowImage)
        }
        
        if User.shared.isLogedIn() {
            GetAreas()
        }
        
        GetMapData(url: "\(ApiManager.Apis.NearBranchesMAP.description)lat=\(lat)&long=\(long)")
    }
    
    
    override func willMove(toParent parent: UIViewController?) {
        setCustomNavagationBar()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.global().async {
            let manager = CLLocationManager()
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.startUpdatingLocation()
                
            default:
                self.showSimpleActionSheet()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        long = "\(locValue.longitude)"
        lat = "\(locValue.latitude)"
        
        if !requested {
            requested = true
            GetMapData(url: "\(ApiManager.Apis.NearBranchesMAP.description)lat=\(lat)&long=\(long)")
        }
    }
    @IBAction func openSideMenu(_ button: UIButton){
           Vrou.openSideMenu(vc: self)
    }
    @IBAction func SalonBtn_pressed(_ sender: Any) {
         NavigationUtils.goToSalonProfile(from: self, salon_id: Int(salonID) ?? 0)
    }
    
   @IBAction func MapDirectionBtn_pressed(_ sender: Any) {
    
      if selectedBranch?.lat ?? "" != "" && selectedBranch?.long ?? "" != "" {
            let lat = round(1000*Double(selectedBranch?.lat ?? "")!)/1000
            let lon =  round(1000*Double(selectedBranch?.long ?? "")!)/1000
            if (UIApplication.shared.canOpenURL(NSURL(string:"https://maps.google.com")! as URL)){
                UIApplication.shared.openURL(NSURL(string:
                    "https://maps.google.com/?q=\(lat),\(lon)")! as URL)
            }
        }
    }
    
    @IBAction func BackBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "CenterNavController") as! CenterNavController
        keyWindow?.rootViewController = vc
    }
    
    @IBAction func SearchBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "CentersSearchNavController") as! CentersSearchNavController
        keyWindow?.rootViewController = vc
    }
    
    
    @IBAction func FilterBtnPressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FilterPopUpVC") as! FilterPopUpVC
        self.present(vc, animated: false, completion: nil)
    }
    
    
    @IBAction func AreaBtnPressed(_ sender: Any) {
        if User.shared.isLogedIn() {
            if areasTable.isHidden {
                self.GoogleMapsView.AddViewBlurEffect(blueEffectStrength: 0.4, tag: 200)
            }else {
                self.GoogleMapsView.RemoveViewBlurEffect(tag: 200)
            }
            areasTable.isHidden = !areasTable.isHidden
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
    }
    
  
    
}

// MARK: - GetMapData API
extension MapVC {
    
    func GetMapData(url:String) {
            //lat = "31.2240349"
           // long = "29.814796"
ApiManager.shared.ApiRequest(URL:url, method: .get, Header:[ "Accept": "application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en"], ExtraParams: nil, view: self.view) { (data, tmp) in
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
                        self?.GetMapData(url: "\(ApiManager.Apis.NearBranchesMAP.description)lat=\(self?.lat ?? "0")&long=\(self?.long ?? "0")")
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
            //let markerImage = salonIcon.withRenderingMode(.automatic)
            let salonIcon2 = resizeImage(image: salonIcon, targetSize: CGSize(width: 60, height: 60))
            let salonIcon3 = salonIcon2.withRoundedCorners(radius: 30)
           
        marker.position = CLLocationCoordinate2D(latitude: Double(lat) ?? Double(), longitude: Double(long) ?? Double())
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
        selectedBranch = marker.branch
        self.SetImage(image: self.SalonImage, link: marker.branch.salon_logo ?? "")
        self.SalonName.text = marker.branch.salon_name ?? ""
        self.SalonCategory.text = marker.branch.salon_category_name ?? "" // To be updated
        self.SalonCity.text = marker.branch.city_name ?? ""
        self.salonID = "\(marker.branch.salon_id ?? "")"
        SalonView.isHidden = false
        directionView.isHidden = false
        SalonStars.value =  CGFloat(truncating: NumberFormatter().number(from: marker.branch.salon_rate ?? "0.0") ?? 0)
        backgroundView.applyGradient(colors: [UIColor(named: "lightGray")!.cgColor, UIColor(named: "whiteColor")!.cgColor],
                                            locations: [0.0, 1.0],
              direction: .leftToRight)
        directionView.layer.cornerRadius = 5
        directionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]

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


// MARK: - GetArea API
extension MapVC {
    
    func GetAreas() {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: "\(ApiManager.Apis.AreasList.description)\(User.shared.data?.user?.city_id ?? "0")", method: .get, Header: [
               "Accept": "application/json",
               "locale": UserDefaults.standard.string(forKey: "Language") ?? "en",
               "timezone": TimeZoneValue.localTimeZoneIdentifier
           ], ExtraParams: "", view: self.view) { (data, tmp) in
               
               if tmp == nil {
                   HUD.hide()
                   do {
                       self.areas = try JSONDecoder().decode(Areas.self, from: data!)
                        self.areasTable.reloadData()
                       
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

// MARK: - TableViewDelegate
extension MapVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areas.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MapListTableCell", for: indexPath) as? MapListTableCell {
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.UpdateView(name: areas.data?[indexPath.row].area_name ?? "")
            return cell
        }
        
        return PopUpTableCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        areaBtn.setTitle(areas.data?[indexPath.row].area_name ?? "", for: .normal)
        areasTable.isHidden = true
        GoogleMapsView.RemoveViewBlurEffect(tag: 200)
        GetMapData(url: "\(ApiManager.Apis.NearBranchesMAP.description)lat=\(lat)&long=\(long)&area_id=\(areas.data?[indexPath.row].id ?? Int())")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(50)
    }
    
    
    
}
