//
//  ScheduledReservationsVC.swift
//  Vrou
//
//  Created by Mac on 11/7/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import PKHUD
import Alamofire
import SwiftyJSON
import MOLH

class ScheduledReservationsVC: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var ReservationsTable: UITableView!
    @IBOutlet weak var EmptyCartView: UIView!
    @IBOutlet weak var scheduledBtn: UIButton!
    @IBOutlet weak var historyBtn: UIButton!
    
    // MARK: - Variables
    var myReservations = MyReservations()
    var request = false
    var hisotry = false
    var param =  "1"

    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0

    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        ReservationsTable.delegate = self
        ReservationsTable.dataSource = self
        ReservationsTable.separatorStyle = .none
        ReservationsTable.estimatedRowHeight = 400
        ReservationsTable.rowHeight = UITableView.automaticDimension
        GetMyReservations()
    }
    
    // MARK: - HistoryBtn
    @IBAction func HistoryBtn_pressed(_ sender: Any) {
        hisotry = true
        historyBtn.setTitleColor(#colorLiteral(red: 0.6897211671, green: 0.1131197438, blue: 0.460976243, alpha: 1), for: .normal)
        scheduledBtn.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        
        param =  "0"
        current_page = 0
        myReservations.data?.reservations?.removeAll()
        ReservationsTable.reloadData()

        GetMyReservations()
    }
    
    // MARK: - ScheduledBtn
    @IBAction func scheduledBtn_pressed(_ sender: Any) {
        hisotry = false
        historyBtn.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        scheduledBtn.setTitleColor(#colorLiteral(red: 0.6897211671, green: 0.1131197438, blue: 0.460976243, alpha: 1), for: .normal)
        param =  "1"
        current_page = 0
        myReservations.data?.reservations?.removeAll()
        ReservationsTable.reloadData()
        
        GetMyReservations()
    }
    
}

// MARK: - TableViewDelegate
extension ScheduledReservationsVC:  UITableViewDelegate , UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if myReservations.data?.reservations?.count ?? 0 == 0 && request {
            EmptyCartView.isHidden = false
        }else {
            EmptyCartView.isHidden = true
        }
        let pager = (myReservations.data?.reservations?.count ?? 0 >= 1) ? (has_more_pages ? 1 : 0): 0
               print("pager items num ==> \(pager)")
        
        return (myReservations.data?.reservations?.count ?? 0) + pager
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row >= myReservations.data?.reservations?.count ?? 0){
            let cell = Bundle.main.loadNibNamed("LoadingTableViewCell", owner: self, options: nil)?.first as! LoadingTableViewCell

                cell.loader.startAnimating()
                return cell
        }

        if let cell = tableView.dequeueReusableCell(withIdentifier: "ReservationCartTableCell", for: indexPath) as? ReservationCartTableCell {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.UpdateView(reservation: myReservations.data?.reservations?[indexPath.row] ?? Reservation() , histoty: hisotry)
            
            return cell
        }
        
        return ReservationCartTableCell()
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //for videos pagination
        if (indexPath.row >= (myReservations.data?.reservations?.count ?? 0)) {
                       
                    if has_more_pages && !is_loading {
                        //&& (is_start_scrolling || (current_page == 1)) {
                           print("start loading")
                           GetMyReservations()
                       }
               }
    }

}


extension ScheduledReservationsVC {
    
    // MARK: - GetReservations_API
    func GetMyReservations() {
        
        
        current_page += 1
        is_loading = true
        
        if current_page == 1 {HUD.show(.progress , onView: view)}

        ApiManager.shared.ApiRequest(URL: "\(ApiManager.Apis.MyReservations.description)\(param)&page=\(current_page)", method: .get, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            
            self.is_loading = false
            if tmp == nil {
                HUD.hide()
                do {
                    
                    let decoded_data = try JSONDecoder().decode(MyReservations.self, from: data!)
                    self.request = true
                    
                    if (self.current_page == 1){
                        self.myReservations = decoded_data
                    }else{
                        self.myReservations.data?.reservations?.append(contentsOf: (decoded_data.data?.reservations)!)
                    }
                    
                    //get pagination data
                    let paginationModel = decoded_data.pagination
                    self.has_more_pages = paginationModel?.has_more_pages ?? false
                    
                    print("has_more_pages ==>\(self.has_more_pages)")
                    
                    self.ReservationsTable.reloadData()
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                UIApplication.shared.keyWindow?.rootViewController = vc
                
            }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.GetMyReservations()
                }
                self.present(vc, animated: true, completion: nil)
            }
            
        }
    }
    
    
}
