//
//  ServicesSearchVC.swift
//  Vrou
//
//  Created by Mac on 11/18/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import ViewAnimator
import SwiftyJSON
import PKHUD
import SideMenu

class ServicesSearchVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var NoSearchResultImage: UIImageView!
    @IBOutlet weak var noSearchResultView: UIView!
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var ServicesTable: UITableView!
    
    // MARK: - Variables
    var dismissKeyboard = true
   // var serviceSearch = ServiceSearch()
    var serviceSearch : [ServiceSearchData]? = []
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
    var timerTyping : Timer?


    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        SearchBar.delegate = self
        ServicesTable.delegate = self
        ServicesTable.dataSource = self
        ServicesTable.separatorStyle = .none
        SearchBar.becomeFirstResponder()
        SearchBar.text = SearchWord.word
        if SearchBar.text != "" {
             HUD.show(.progress , onView: view)
            GetSearchResult()
        }
        let offerImage = UIImage.gifImageWithName("No Search Result Found")
        NoSearchResultImage.image = offerImage
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.SearchBar.endEditing(true)
    }
    
    // MARK: - setupSideMenu
  @IBAction func openSideMenu(_ button: UIButton){
         Vrou.openSideMenu(vc: self)
  }
     // MARK: - CenterBtn
    @IBAction func CentersBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CentersSearchNavController") as! CentersSearchNavController
        keyWindow?.rootViewController = vc
    }
    
    // MARK: - OffersBtn
    @IBAction func OffersBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OffersSearchNavController") as! OffersSearchNavController
        keyWindow?.rootViewController = vc
    }
    
     // MARK: - ProductsBtn
    @IBAction func ProductsBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProductsSearchNavController") as! ProductsSearchNavController
        keyWindow?.rootViewController = vc
    }
    
    
}


extension ServicesSearchVC {
    
     // MARK: - Search_API
    func GetSearchResult() {
        dismissKeyboard = false
        var FinalURL = ""
        current_page += 1
        is_loading = true
        
        if User.shared.isLogedIn() {
            FinalURL = "\(ApiManager.Apis.Search.description)key=\(SearchBar.text ?? "")&type=service&city_id=\(User.shared.data?.user?.city?.id ?? 0)&page=\(current_page)"
        }else {
            FinalURL = "\(ApiManager.Apis.Search.description)key=\(SearchBar.text ?? "")&type=service&city_id=\(UserDefaults.standard.integer(forKey: "GuestCityId"))&page=\(current_page)"
            
        }
        let safeURL = FinalURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        ApiManager.shared.ApiRequest(URL: safeURL , method: .get, Header: [ "Accept": "application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier], ExtraParams: "", view: self.view) { (data, tmp) in
            
            self.is_loading = false

            if tmp == nil {
                HUD.hide()
                do {
                    let decoded_data = try JSONDecoder().decode(ServiceSearch.self, from: data!)
                    
                    
                    if (self.current_page == 1){
                        self.serviceSearch = decoded_data.data
                    }else{
                        self.serviceSearch?.append(contentsOf: decoded_data.data!)
                    }
                    
                    //get pagination data
                    let paginationModel = decoded_data.pagination
                    self.has_more_pages = paginationModel?.has_more_pages ?? false
                    
                    print("has_more_pages ==>\(self.has_more_pages)")
                    
                    self.noSearchResultView.isHidden = true
                    self.ServicesTable.isHidden = false
                    self.ServicesTable.reloadData()
                    if self.serviceSearch?.count ?? 0 == 0 {
                        self.noSearchResultView.isHidden = false
                        self.ServicesTable.isHidden = true
                        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                            HUD.flash(.label("No results found") , onView: self.view , delay: 1.5 , completion: nil)
                        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                            HUD.flash(.label("لا توجد نتائج") , onView: self.view , delay: 1.5 , completion: nil)
                        }
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
                    self?.GetSearchResult()
                }
                self.present(vc, animated: true, completion: nil)
            }
            
        }
        dismissKeyboard = true
    }
    
    
    
}


 // MARK: - SearchBarDelgate
extension ServicesSearchVC:UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        
        return dismissKeyboard ;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        current_page = 0
        has_more_pages = false
        SearchWord.word = searchBar.text ?? ""
        serviceSearch?.removeAll()
        ServicesTable.reloadData()
        
        timerTyping?.invalidate()
            timerTyping =  Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(textFieldStopEditing(sender:)), userInfo: nil, repeats: false)
        }
        
        @objc func textFieldStopEditing(sender: Timer) {

           print("Stop typing")
            if ((SearchBar.text ?? "") != "") && !is_loading{
                GetSearchResult()
            }

        }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

// MARK: - TableViewDelegate
extension ServicesSearchVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let pager = (serviceSearch?.count ?? 0 >= 1) ? (has_more_pages ? 1 : 0): 0
        print("pager items num ==> \(pager)")
        return (serviceSearch?.count ?? 0) + pager
        
     }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if (indexPath.row >= serviceSearch?.count ?? 0){
            let cell = Bundle.main.loadNibNamed("LoadingTableViewCell", owner: self, options: nil)?.first as! LoadingTableViewCell

                cell.loader.startAnimating()
                return cell
        }

        if let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryServiceTableCell", for: indexPath) as? CategoryServiceTableCell {
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            cell.UpdateView(service: serviceSearch?[indexPath.row] ?? ServiceSearchData())
            return cell
        }
        
        return CenterServicesTableCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "SalonProfile", bundle: nil).instantiateViewController(withIdentifier: "ReservationViewController") as! ReservationViewController
        vc.ServiceID = "\(serviceSearch?[indexPath.row].id ?? Int())"
        vc.salonID = "\(serviceSearch?[indexPath.row].salon_id ?? Int())"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //for videos pagination
               print("\(indexPath.row) ***** \(serviceSearch?.count ?? 0)")
                   if (indexPath.row >= (serviceSearch?.count ?? 0)) {
                       
                       print("\(indexPath.row) ***done** \(serviceSearch?.count ?? 0)")

                    if has_more_pages && !is_loading {
                        //&& (is_start_scrolling || (current_page == 1)) {
                           print("start loading")
                           GetSearchResult()
                       }
               }
    }

    
}
