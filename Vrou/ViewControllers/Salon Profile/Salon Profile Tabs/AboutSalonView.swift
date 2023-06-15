//
//  AboutSalonView.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/20/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//


import UIKit
import Alamofire
import PKHUD
import HCSStarRatingView
import SDWebImage
import ImageSlideshow
import GoogleMaps
import XLPagerTabStrip

class AboutSalonView:  UIViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var aboutLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            self.tableView.register(UINib(nibName: "MapMainBranchTableViewCell", bundle: nil), forCellReuseIdentifier: "mainBranch")
            self.tableView.register(UINib(nibName: String(describing: MapBranchesTableViewCell.self), bundle: nil), forCellReuseIdentifier: "branch")
            self.tableView.rowHeight = 210//UITableView.automaticDimension
        }
    }
    
    var itemInfo = IndicatorInfo(title: NSLocalizedString( "About", comment: "") , image:  #imageLiteral(resourceName: "offer_icon"))
    var rootView:SalonProfileRootView!
    var height : CGFloat = 0.0
    var half : CGFloat = 2.0
    var newPosition: CGFloat = 0.0
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = #colorLiteral(red: 0.6117647059, green: 0.4431372549, blue: 0.6941176471, alpha: 1)
        refreshControl.addTarget(self, action: #selector(reloadPage), for: .valueChanged)
        return refreshControl
    }()
    @objc func reloadPage(){
     }
    //data
    var Requested = true
    var salonAbout: SalonAboutData? = SalonAboutData()
    var gallery_list: [SalonAlbum]? = []
    var videos_list: [SalonAlbum]? = []
    var specialist: [Employee]? = []
    var features_list: [SalonFeatures]? = []
    var branches: [SalonBranch]? = []
    
    var titles: [(id:Int, title:String)] = []

    private var items = [Any?]()
       var SalonID = 58
       var success = ErrorMsg()
       var tabs = [String]()
       var imageSource = [InputSource]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if #available(iOS 10.0, *){
//            tableView.refreshControl = refresher
//        }else{
//            tableView.addSubview(refresher)
//        }
    
        height = 400//(self.view.bounds.height / half) - 150
        getData()
     }
    
     
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        newPosition = ( -1 * rootView.collapseTabsPositionConstant.constant)
        tableView.contentOffset.y = 0
    }
}
 
extension AboutSalonView{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let position = scrollView.contentOffset.y
        let newPos = (position) + newPosition
        if (newPos > 0) && (newPos < height) {
        rootView.collapseTabsPositionConstant.constant = (-1 * newPos)
           // newPosition = 0.0
        }
       // print("position ==>\(position)  *** \(rootView.collapseTabsPositionConstant.constant)")
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (rootView.collapseTabsPositionConstant.constant != 0) && (scrollView.contentOffset.y <= 0) {
            animateHeader()
            newPosition = 0.0
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if  (rootView.collapseTabsPositionConstant.constant != 0) && (scrollView.contentOffset.y <= 0) {
            animateHeader()
            newPosition = 0.0
        }
    }
    func animateHeader() {
        view.layoutIfNeeded() // force any pending operations to finish
        rootView.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.rootView.collapseTabsPositionConstant.constant = 0
            self.view.layoutIfNeeded()
            self.rootView.view.layoutIfNeeded()
        })
    }
}

// MARK: - UITableViewDataSource
extension AboutSalonView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch titles[indexPath.row].id {
        case 0, 1, 2, 3:
            let  cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AboutSalonCell.self),
                                                      for: indexPath) as! AboutSalonCell
            cell.parentView = self
            cell.configure(info: titles[indexPath.row])
            return cell
            
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainBranch", for: indexPath) as! MapBranchesTableViewCell
            cell.UpdateView(branch: salonAbout?.main_branch ?? SalonBranch(), mainBranchIcon:  #imageLiteral(resourceName: "LogoPlaceholder"))
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "branch", for: indexPath) as! MapBranchesTableViewCell
            let index = Int(titles[indexPath.row].title) ?? 0
            cell.UpdateView(branch: salonAbout?.branches?[index] ?? SalonBranch(), mainBranchIcon: #imageLiteral(resourceName: "LogoPlaceholder"))
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (titles[indexPath.row].id == 4) ? 300 : (titles[indexPath.row].id >= 3) ? 100 : 210
    }
}

    //MARK: Get Data
    extension AboutSalonView {
        func getData() {
                let FinalURL = "\(ApiManager.Apis.SalonAbout.description)"
                var params = [String():String()]
            params = User.shared.isLogedIn() ?
                ["salon_id":"\(SalonID)", "user_hash_id": User.shared.TakeHashID()] :
                ["salon_id":"\(SalonID)" , "user_hash_id": "0"]
                
                ApiManager.shared.ApiRequest(URL: FinalURL, method: .post, parameters: params ,encoding: URLEncoding.default, Header:["Accept": "application/json" , "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],ExtraParams: "", view: self.view)  { (data, tmp) in
                    
                    if tmp == nil {
                        HUD.hide()
                        do {
                            let decoded_data = try JSONDecoder().decode(SalonAbout.self, from: data!)
                            self.salonAbout = decoded_data.data
                            let taps = self.salonAbout?.package_roles
                            self.setData()
//                            //TODO: - Send notification to SalonProfileRoot with (show tabs)
//                            NotificationCenter.default.post(name: .visible_tabs, object: nil, userInfo: ["data":taps])
                            ////
                            self.setData()
//                            self.mainView.isHidden = true
//                            self.mainView.isShimmering = false
                            
                        }catch {
                            HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                        }
                        
                    }
                }
            }
        
        func setData(){
            titles =
                [(id: 0, title: "Gallery".ar()), (id: 1, title:"Tutorial ".ar()),
                 (id: 2, title:"Specialists".ar()),
                 (id: 3, title:"Features".ar()),
             (id: 4, title:"main branch"),
             ]
        
            gallery_list = salonAbout?.about?.albums_images
            videos_list = salonAbout?.about?.albums_videos
            specialist  = salonAbout?.about?.employees
            features_list = salonAbout?.about?.features
            branches = salonAbout?.branches
            
            if (gallery_list?.isEmpty ?? true){
                titles = titles.filter { $0.id != 0 }
            }
             
            if (videos_list?.isEmpty ?? true){
                 titles = titles.filter { $0.id != 1}
            }
            if (specialist?.isEmpty ?? true){
                 titles = titles.filter { $0.id != 2 }
            }
            if (features_list?.isEmpty ?? true){
                 titles = titles.filter { $0.id != 3 }
            }
            if (salonAbout?.main_branch == nil) {
                 titles = titles.filter { $0.id != 4 }
            }
           
            let branchesCount = (branches?.count ?? 0) - 1
            if branchesCount > 0 {
                for i in 0...branchesCount {
                    titles.append((id: 5, title: "\(i)"))
                }
            }
            else if branchesCount == 0{
                titles.append((id: 5, title: "\(0)"))
            }
            print(titles)
            tableView.reloadData()
            //send header data to salon profile root
            NotificationCenter.default.post(name:   NSNotification.Name("salonHeaderData"), object: nil, userInfo: ["data" : salonAbout!])
            let follows_list = salonAbout?.about?.followers_list
            if !(follows_list?.isEmpty ?? true) { NotificationCenter.default.post(name:   NSNotification.Name("followersHeader"), object: nil, userInfo: ["data" : follows_list ?? []])
            }
            aboutLbl.text = salonAbout?.about?.salon_description ?? ""
            tableView.updateHeaderViewHeight()
        }
        
}

extension UITableView {
    func updateHeaderViewHeight() {
        if let header = self.tableHeaderView {
            let newSize = header.systemLayoutSizeFitting(CGSize(width: self.bounds.width, height: 0))
            header.frame.size.height = newSize.height
        }
    }
}
 

