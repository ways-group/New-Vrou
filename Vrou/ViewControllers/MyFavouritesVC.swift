//
//  MyFavouritesVC.swift
//  Vrou
//
//  Created by Islam Elgaafary on 11/10/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import PKHUD
import Alamofire
import SwiftyJSON
import MOLH

class MyFavouritesVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var MyFavouritesTable: UITableView!
    @IBOutlet weak var ProductsBtn: UIButton!
    @IBOutlet weak var OffersBtn: UIButton!
    
    // MARK: - Variables
    var myfavourites = MyFavourites()
    var offers = false
    var param =  "1"
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0

    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        MyFavouritesTable.delegate = self
        MyFavouritesTable.dataSource = self
        MyFavouritesTable.separatorStyle = .none
        MyFavouritesTable.estimatedRowHeight = 400
        MyFavouritesTable.rowHeight = UITableView.automaticDimension
        GetMyFavourites()
    }
    
    // MARK: - ProductBtn
    @IBAction func ProductsBtn_pressed(_ sender: Any) {
        offers = false
        ProductsBtn.setTitleColor(#colorLiteral(red: 0.6897211671, green: 0.1131197438, blue: 0.460976243, alpha: 1), for: .normal)
        OffersBtn.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        current_page = 0
        param =  "1"
        myfavourites.data?.list?.removeAll()
        MyFavouritesTable.reloadData()
    //    jjhsjakh
        GetMyFavourites()
    }
    
    // MARK: - OffersBtn
    @IBAction func OffersBtn_pressed(_ sender: Any) {
        offers = true
        OffersBtn.setTitleColor(#colorLiteral(red: 0.6897211671, green: 0.1131197438, blue: 0.460976243, alpha: 1), for: .normal)
        ProductsBtn.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        current_page = 0
        param = "2"
        myfavourites.data?.list?.removeAll()
        MyFavouritesTable.reloadData()

       // kdkdsj
        GetMyFavourites()
    }
    
    
}


// MARK: - TableViewDelegate
extension MyFavouritesVC:  UITableViewDelegate , UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let pager = (myfavourites.data?.list?.count ?? 0 >= 1) ? (has_more_pages ? 1 : 0): 0
               print("pager items num ==> \(pager)")
        
        return (myfavourites.data?.list?.count ??  0) + pager
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if (indexPath.row >= myfavourites.data?.list?.count ?? 0){
            let cell = Bundle.main.loadNibNamed("LoadingTableViewCell", owner: self, options: nil)?.first as! LoadingTableViewCell

                cell.loader.startAnimating()
                return cell
        }

        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MyWorldTableCell", for: indexPath) as? MyWorldTableCell {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            if offers {
                cell.UpdateView(offer: myfavourites.data?.list?[indexPath.row] ?? MyFavourite())
            }else {
                cell.UpdateView(product: myfavourites.data?.list?[indexPath.row] ?? MyFavourite())
            }
            
            return cell
        }
        
        return MyWorldTableCell()
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //for videos pagination
                    if (indexPath.row >= (myfavourites.data?.list?.count ?? 0)) {
                       
                    if has_more_pages && !is_loading {
                        //&& (is_start_scrolling || (current_page == 1)) {
                           print("start loading")
                        GetMyFavourites()


                        }
               }
    }

}



// MARK: - GetFavourites_API

extension MyFavouritesVC {
    
    
    func GetMyFavourites() {
                
        current_page += 1
        is_loading = true
        
        if current_page == 1 { HUD.show(.progress , onView: view) }


        ApiManager.shared.ApiRequest(URL: "\(ApiManager.Apis.MyFavourites.description)\(param)&page=\(current_page)", method: .get, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            self.is_loading = false
            if tmp == nil {
                HUD.hide()
                do {
                    
                    let decoded_data  = try JSONDecoder().decode(MyFavourites.self, from: data!)
                    
                    if (self.current_page == 1){
                        self.myfavourites = decoded_data
                    }else{
                        self.myfavourites.data?.list?.append(contentsOf: (decoded_data.data?.list)!)
                    }
                    
                    //get pagination data
                    let paginationModel = decoded_data.pagination
                    self.has_more_pages = paginationModel?.has_more_pages ?? false
                    
                    print("has_more_pages ==>\(self.has_more_pages)")
                    
                    self.MyFavouritesTable.reloadData()
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                UIApplication.shared.keyWindow?.rootViewController = vc
                
            }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.GetMyFavourites()
                }
                self.present(vc, animated: true, completion: nil)
            }
            
        }
    }
    
    
}
