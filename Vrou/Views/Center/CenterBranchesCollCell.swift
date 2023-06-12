//
//  CenterBranchesCollCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/15/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import GoogleMaps

class CenterBranchesCollCell: UICollectionViewCell {
    
    @IBOutlet weak var BranchImage: UIImageView!
    @IBOutlet weak var BranchName: UILabel!
    @IBOutlet weak var BranchAddress: UILabel!
    @IBOutlet weak var BranchCity: UILabel!
    @IBOutlet weak var workTimelbl: UILabel!
    @IBOutlet weak var openLbl: UILabel!
    @IBOutlet weak var BranchMap: GMSMapView!
    
    var branchPhone = ""
    var lati = ""
    var long = ""
    
    func UpdateView(branch:SalonBranch , mainBranchIcon:UIImage) {
        //   SetImage(image: BranchImage, link: branch.)
        BranchName.text = branch.branch_name ?? ""
        BranchAddress.text = branch.address ?? ""
        BranchCity.text = branch.city?.city_name ?? ""
        
        if branch.work_times?.count ?? 0 > 0 {
            if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                workTimelbl.text = "Working Hours: \(branch.work_times?[0].open_from ?? "") to  \(branch.work_times?[0].open_to ?? "")"
                
                if branch.work_times?[0].is_open_now == 0 {
                    openLbl.isHidden = false
                    openLbl.text = "Closed"
                }else if branch.work_times?[0].is_open_now == 1 {
                    openLbl.isHidden = false
                    openLbl.text = "Open"
                }else {
                    openLbl.isHidden = true
                }
            }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                
                workTimelbl.text = "ساعات العمل: \(branch.work_times?[0].open_from ?? "") إلى  \(branch.work_times?[0].open_to ?? "")"
                if branch.work_times?[0].is_open_now == 0 {
                    openLbl.isHidden = false
                    openLbl.text = "مغلق"
                }else if branch.work_times?[0].is_open_now == 1 {
                    openLbl.isHidden = false
                    openLbl.text = "مفتوح"
                }else {
                    openLbl.isHidden = true
                }
            }
            
        }
        
        branchPhone = branch.phone ?? ""
        lati = branch.lat ?? ""
        long = branch.long ?? ""
        
        let camera = GMSCameraPosition.camera(withLatitude: Double (branch.lat ?? "")!, longitude: Double (branch.long ?? "")!, zoom: 16.0)
        let mapView = GMSMapView.map(withFrame: self.BranchMap.bounds, camera: camera)
        self.BranchMap.addSubview(mapView)


        let marker = GMSMarker()

        // I have taken a pin image which is a custom image
        let markerImage = mainBranchIcon.withRenderingMode(.automatic)

        //creating a marker view
        let markerView = UIImageView(image: markerImage)


        markerView.contentMode = .scaleAspectFit
        markerView.clipsToBounds = true
        markerView.frame = CGRect(x: markerView.frame.origin.x , y: markerView.frame.origin.x, width: 30, height: 30)
        markerView.cornerRadius = 15
        marker.position = CLLocationCoordinate2D(latitude: Double(branch.lat ?? "")!, longitude: Double(branch.long ?? "")!)

        marker.iconView = markerView
        marker.title = branch.branch_name ?? ""
        marker.snippet = branch.city?.city_name ?? ""
        marker.map = mapView

        //comment this line if you don't wish to put a callout bubble
        mapView.selectedMarker = marker
        
        
        
    }
    
    
    
    
    @IBAction func PhoneBtn_pressed(_ sender: Any) {
        let url: NSURL = URL(string: "TEL://\(branchPhone)")! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    
    
    @IBAction func MapBtn_pressed(_ sender: Any) {
        let lat = round(1000*Double(lati)!)/1000
        let lon =  round(1000*Double(long)!)/1000 //Double (self.salonBranches.data?.main_branch?.long ?? "")
        if (UIApplication.shared.canOpenURL(NSURL(string:"https://maps.google.com")! as URL))
        {
            UIApplication.shared.openURL(NSURL(string:
                "https://maps.google.com/?q=\(lat ?? Double()),\(lon ?? Double())")! as URL)
        }
        
    }
    
    
}
