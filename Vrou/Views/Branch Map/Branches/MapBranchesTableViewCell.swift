//
//  MapBranchesTableViewCell.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/23/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//


import UIKit
import GoogleMaps

class MapBranchesTableViewCell: UITableViewCell {
 
       // @IBOutlet weak var BranchImage: UIImageView!
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
            
            let camera = GMSCameraPosition.camera(withLatitude: Double (branch.lat ?? "") ?? 0.0, longitude: Double (branch.long ?? "") ?? 0.0, zoom: 16.0)
            let marker = GMSMarker()
            BranchMap.camera = camera
            let markerImage = mainBranchIcon.withRenderingMode(.automatic)
            marker.position = CLLocationCoordinate2D(latitude: Double(branch.lat ?? "") ?? 0.0, longitude: Double(branch.long ?? "") ?? 0.0)
           // marker.icon = markerImage
            marker.title = branch.branch_name ?? ""
            marker.snippet = branch.city?.city_name ?? ""
            marker.map = BranchMap
            BranchMap.selectedMarker = marker
        }
        
        @IBAction func PhoneBtn_pressed(_ sender: Any) {
            let url: NSURL = URL(string: "TEL://\(branchPhone)")! as NSURL
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
        
        @IBAction func MapBtn_pressed(_ sender: Any) {
            let lat = round(1000*(Double(lati) ?? 0.0))/1000
            let lon =  round(1000*(Double(long) ?? 0.0))/1000 //Double (self.salonBranches.data?.main_branch?.long ?? "")
            if (UIApplication.shared.canOpenURL(NSURL(string:"https://maps.google.com")! as URL))
            {
                UIApplication.shared.openURL(NSURL(string:
                    "https://maps.google.com/?q=\(lat ?? Double()),\(lon ?? Double())")! as URL)
            }
            
        }
        
        
    }

