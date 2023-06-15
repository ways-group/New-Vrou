//
//  SelectServiceVC.swift
//  Vrou
//
//  Created by Islam Elgaafary on 5/3/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PKHUD

struct SelectedServices {
    static var services = [String]()
}


class SelectServiceVC: UIViewController {

    @IBOutlet weak var SalonBackground: UIImageView!
    @IBOutlet weak var SalonLogo: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var SalonCategory_lbl: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var salonHeaderView: UIView!
    @IBOutlet weak var servicesTable: UITableView!
    @IBOutlet weak var DoneBtn: UIButton!
    
    var salon : Salon?
    var allSelectedServicesList : [Service] = []
    var allServicesList: [Service]? = []
    var random_order_key = -1
    var selected_id: [Int] = []
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
    var salonID = 45
    var delegate: UpdateSelectedServiceIDs? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TransparentNavigationController()
        SetupHeaderView()
                
        servicesTable.register(UINib(nibName: "SelectServiceTableCell", bundle: nil), forCellReuseIdentifier: "SelectServiceTableCell")
        servicesTable.allowsMultipleSelection = true
        
        HUD.show(.progress , onView: self.view)
        GetSalonServicesData()
    }
    
    func SetupHeaderView()  {
           servicesTable.parallaxHeader.view = headerView
           servicesTable.parallaxHeader.height = 380
           servicesTable.parallaxHeader.minimumHeight = 200
           servicesTable.parallaxHeader.mode = .fill
           headerView.widthAnchor.constraint(equalTo: servicesTable.widthAnchor).isActive = true
           salonHeaderView.layer.cornerRadius = 20
           salonHeaderView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
       }

    func setData(){
        SetImage(image: SalonLogo, link: salon?.salon_logo ?? "")
        SetImage(image: SalonBackground, link: salon?.salon_background ?? "")
        SalonName.text = salon?.salon_name ?? ""
        SalonCategory_lbl.text = salon?.category?.category_name ?? ""
    }
    @IBAction func DoneBtnPressed(_ sender: Any) {
        if self.has_more_pages {
            
        }
        let selectedRows = servicesTable.indexPathsForSelectedRows
        if selectedRows != nil {
            for i in  selectedRows!{
                selected_id.append(allServicesList?[i.row].id ?? 0)
            }
        }
        for (item) in allSelectedServicesList {
            let isSelected =  self.allServicesList?.contains{ ($0.id == item.id) }
            (isSelected ?? false) ?   print("already add to IDs list") : selected_id.append(item.id ?? 0)
        }
        delegate?.sendServicesIDs(list: selected_id)
       // print(servicesTable.indexPathsForSelectedRows)
        
        self.navigationController?.popViewController(animated: false)
    }
    
    
    @IBAction func X_BtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func SideMenuBtnPressed(_ sender: Any) {
         Vrou.openSideMenu(vc: self)
    }
    
}

// MARK: - SalonServices_API
extension SelectServiceVC {
    
    func GetSalonServicesData() {
        
        current_page += 1
        is_loading = true
        
        let FinalURL = "\(ApiManager.Apis.SalonServices.description)salon_id=\(salon?.id ?? Int())&category_id=0&page=\(current_page)&random_order_key=\(random_order_key)"
        
        ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: [ "Accept": "application/json",
               "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
             HUD.hide()
            self.is_loading = false
            if tmp == nil {
                do {
                    let decoded_data = try JSONDecoder().decode(SalonServices.self, from: data!)
                    self.random_order_key = decoded_data.data?.random_order_key ?? -1
                    if (self.current_page == 1){
                        self.allServicesList = decoded_data.data?.services
                        self.setData()
                    }else{
                        self.allServicesList?.append(contentsOf: (decoded_data.data?.services)!)
                    }
                   
                    //get pagination data
                    let paginationModel = decoded_data.pagination
                    self.has_more_pages = paginationModel?.has_more_pages ?? false
                    self.servicesTable.reloadData()
                    self.selectOldSelectedService(list: (decoded_data.data?.services)!)
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {}
        }
    }
    
    func selectOldSelectedService(list: [Service]){
        
        for (index, item) in (allServicesList?.enumerated())!{
          let isSelected =  self.allSelectedServicesList.contains{ ($0.id == item.id) }
            isSelected ?    self.servicesTable.selectRow(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .none) : print(index)
        }
    }
}


// MARK: - UITableViewDataSource
extension SelectServiceVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let pager = (allServicesList?.count ?? 0 >= 1) ? (has_more_pages ? 1 : 0): 0
        return (allServicesList?.count ?? 0) + pager
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row >= allServicesList?.count ?? 0){
            let cell = Bundle.main.loadNibNamed("LoadingTableViewCell", owner: self, options: nil)?.first as! LoadingTableViewCell
                cell.loader.startAnimating()
                return cell
        }
        
        let  cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SelectServiceTableCell.self),for: indexPath) as! SelectServiceTableCell
        cell.selectionStyle = .none
        
        let service =  allServicesList?[indexPath.row] ?? Service()
        cell.SetData(service: service)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row >= (allServicesList?.count ?? 0)) {
            if has_more_pages && !is_loading {
                self.GetSalonServicesData()
            }
        }
    }
    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
    }

}
