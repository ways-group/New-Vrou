//
//  VrouWorldView.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/9/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import PKHUD
import XLPagerTabStrip

class VrouWorldView:  UIViewController, IndicatorInfoProvider {
    
    var itemInfo = IndicatorInfo(title: NSLocalizedString("Vrou World", comment: ""), image: #imageLiteral(resourceName: "vrouIcon"))
    @IBOutlet weak var noVrouWorldView: UIView!
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            self.tableView.rowHeight = 310//UITableView.automaticDimension
        }
    }
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = #colorLiteral(red: 0.6117647059, green: 0.4431372549, blue: 0.6941176471, alpha: 1)
        refreshControl.addTarget(self, action: #selector(reloadPage), for: .valueChanged)
        return refreshControl
    }()
    @objc func reloadPage(){
        getData()
    }
    //data
    var Requested = true
    var schedule_reservation: schedule_reservation?
    var allVrouData: BeautyWorldData?
    var titles: [(id:Int, title:String, viewall:Bool)] = []
    //LIFE CYCLE
    override func viewDidLoad() {
        create_observer()
        super.viewDidLoad()
        if #available(iOS 10.0, *){
            tableView.refreshControl = refresher
        }else{
            tableView.addSubview(refresher)
        }
        mainView.isHidden = false
        noVrouWorldView.isHidden = true
        mainView.contentView = logo
        mainView.isShimmering = true
        mainView.shimmeringSpeed = 550
        mainView.shimmeringOpacity = 1
        
    }
    //IndicatorInfoProvider
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         getData()
        
    }
    func create_observer(){
        NotificationCenter.default.addObserver(self, selector: #selector(getData(_:)), name: NSNotification.Name("categoryHeaderSelect"), object: nil)
    }
    @objc func getData(_ notification: NSNotification) {
        guard let getTitle = notification.userInfo?["title"] as? String else { return }
        if getTitle == itemInfo.title {
             guard let getID = notification.userInfo?["id"] as? String  else { return }
            goToPlaces(id: getID)
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name("categoryHeaderSelect"),object: nil)
    }
    func goToPlaces(id: String){
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name("categoryHeaderSelect"),object: nil)
        globalValues.sideMenu_selected = 1
        let vc = View.centerViewController.identifyViewController(viewControllerType: CenterViewController.self)
        vc.SectionID = id
        vc.OuterViewController = true
        CenterParams.SectionID = id
        CenterParams.OuterViewController = true
        RouterManager(self).push(controller: vc)
    }
}
// MARK: - UITableViewDataSource
extension VrouWorldView: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(titles.count == 0){
            noVrouWorldView.isHidden = false
            tableView.isHidden = true
        }else{
            noVrouWorldView.isHidden = true
            tableView.isHidden = false
        }
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VrouWorldRootTableViewCell.self),
                                                  for: indexPath) as! VrouWorldRootTableViewCell
        
        if(titles.count == 0){
            noVrouWorldView.isHidden = false
        }else{
            noVrouWorldView.isHidden = true
        }
        
        switch titles[indexPath.row].id {
        case 0:
            cell.top_and_bottom_adsList = allVrouData?.top_ads
        case 9:
            cell.top_and_bottom_adsList = allVrouData?.bottom_ads
        case 5:
            cell.main_ads = allVrouData?.main_ads
        case 1:
            cell.tutorials = allVrouData?.tutorials
        case 2:
            cell.allSalonsList = allVrouData?.recently_joined_salons
        case 3:
            cell.allSalonsList = allVrouData?.most_popular_salons
        case 6:
            cell.allSalonsList = allVrouData?.beauty_centers
        case 7:
            cell.allSalonsList = allVrouData?.salons
        case 8:
            cell.allSalonsList = allVrouData?.spa
        case 10:
            cell.allSalonsList = allVrouData?.makeup_artists
        case 11:
            cell.allSalonsList = allVrouData?.specialists
        case 12:
            cell.allSalonsList = allVrouData?.stores
        default:
            break
        }
        cell.parentView = self
        cell.configure(info: titles[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        switch titles[indexPath.row].id {
        case 0 :
            return 230
        case 1:
            let width = self.view.bounds.width/2.75
            return  (width + 110)
        case 3:
            return 280
        default :
            return 250
        }
    }
}


//MARK: Get Data
extension VrouWorldView{
    func getData(){
        Requested = false
        mainView.isHidden = false
        noVrouWorldView.isHidden = true
        mainView.contentView = logo
        mainView.isShimmering = true
        mainView.shimmeringSpeed = 550
        mainView.shimmeringOpacity = 1
        var headerData = [String:String]()
        var finalURL = ""
        if User.shared.isLogedIn() {
            headerData = ["Authorization": "Bearer \(User.shared.TakeToken())",
                "Accept": "application/json",
                "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ]//"en"]
            finalURL = "\(ApiManager.Apis.BeautyWorldAuth.description)\(User.shared.data?.user?.city?.id ?? 0)"
        }
        else {
            headerData = [ "Accept": "application/json",
                           "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ] //"en"]]
            print(UserDefaults.standard.string(forKey: "Language") ?? "en")
            finalURL = "\(ApiManager.Apis.BeautyWorld.description)\(UserDefaults.standard.integer(forKey: "GuestCityId"))"
        }
        
        ApiManager.shared.ApiRequest(URL: finalURL, method: .get, parameters: ["":""],encoding: URLEncoding.default, Header:headerData,ExtraParams: "", view: self.view) { (data, tmp) in
            self.tableView.refreshControl?.endRefreshing()
            self.Requested = true
            self.mainView.isHidden = true
            self.mainView.isShimmering = false
            if tmp == nil {
                do {
                    let decoded_data = try JSONDecoder().decode(BeautyWorld.self, from: data!)
                    self.allVrouData = decoded_data.data
                    self.schedule_reservation = decoded_data.data?.schedule_reservation
                    self.setData()
                    self.checkForReservation()
                    //                    self.SetImage(image: self.MainAdImage, link: self.beautyWorld.data?.main_ads?.image_thumbnail ?? "")
                    //                    if self.beautyWorld.data?.main_ads?.image_thumbnail ?? "" == "" {
                    //                        self.MainAdHeight.constant = 0
                    //                        self.MainAdBtn.isHidden = true
                    //                    }
                    //                    self.mainView.isHidden = true
                    //                    self.mainView.isShimmering = false
                    
                }catch {
                    print("----error----")
                    print(error)
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
            }
        }
    }
    
    func setData(){
        titles =
            [(id: 0, title: "Sponsored ads".ar(), viewall: false), (id: 1, title:"Tutorial".ar(), viewall: true), (id: 2, title:"Recently Joined".ar(), viewall: false),
             (id: 3, title:"Most Popular".ar(), viewall: true),
         (id: 5, title:"", viewall: false),
         (id: 6, title:"Beauty Center".ar(), viewall: true), (id: 7, title:"Salon".ar(), viewall: true), (id: 8, title:"Spa".ar(), viewall:true),
         (id: 9, title:"", viewall: false),
         (id: 10, title: "Makeup Artist".ar(), viewall: true), (id: 11, title:"Specialists".ar(),viewall: true) , (id: 12, title:"Stores".ar(), viewall: true)]
        if (allVrouData?.top_ads?.isEmpty ?? true){
            titles = titles.filter { $0.id != 0 }
        }
        if (allVrouData?.main_ads?.id == nil) {
             titles = titles.filter { $0.id !=  5}
        }
        if (allVrouData?.bottom_ads?.isEmpty ?? true) {
             titles = titles.filter { $0.id != 9 }
        }
        if (allVrouData?.tutorials?.isEmpty ?? true){
             titles = titles.filter { $0.id != 1}
        }
        if (allVrouData?.recently_joined_salons?.isEmpty ?? true){
             titles = titles.filter { $0.id != 2 }
        }
        if (allVrouData?.most_popular_salons?.isEmpty ?? true){
             titles = titles.filter { $0.id != 3 }
        }
        if (allVrouData?.beauty_centers?.isEmpty ?? true) {
             titles = titles.filter { $0.id != 6 }
        }
        if (allVrouData?.salons?.isEmpty ?? true) {
             titles = titles.filter { $0.id != 7 }
        }
        if (allVrouData?.spa?.isEmpty ?? true) {
             titles = titles.filter { $0.id != 8 }
        }
        if (allVrouData?.makeup_artists?.isEmpty ?? true) {
            titles.removeAll { $0.id == 10 }
        }
        if (allVrouData?.specialists?.isEmpty ?? true) {
             titles = titles.filter { $0.id != 11 }
        }
        if (allVrouData?.stores?.isEmpty ?? true) {
             titles = titles.filter { $0.id != 12 }
        }
        print(titles)
        tableView.reloadData()
        //send header data to HomeheaderView
        NotificationCenter.default.post(name:   NSNotification.Name("categoryHeader"), object: nil, userInfo: ["data" : allVrouData?.categories ?? [], "title": itemInfo.title ?? ""])
    }
    
    func checkForReservation()  {
        if schedule_reservation?.id != nil && User.shared.isLogedIn() {
            let vc = UIStoryboard(name: Storyboard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: "RescheduleReservationVC") as! RescheduleReservationVC
            vc.info = ("\(schedule_reservation?.id ?? Int())", schedule_reservation?.msg_two ?? "",
                       schedule_reservation?.msg_three ?? "", schedule_reservation?.msg_one ?? "",
                       schedule_reservation?.from ?? "", schedule_reservation?.to ?? "")
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        }
    }

}
