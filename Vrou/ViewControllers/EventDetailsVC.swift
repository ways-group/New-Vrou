//
//  EventDetailsVC.swift
//  Vrou
//
//  Created by Mac on 1/20/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import PKHUD
import Alamofire
import SwiftyJSON

class EventDetailsVC: UIViewController {

    @IBOutlet weak var offersTable: UITableView!
    var eventOffers = EventsOffers()

    var EventID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        offersTable.delegate = self
        offersTable.dataSource = self
        offersTable.separatorStyle = .none
        
        GetEventsListData(id: EventID)
        
    }
 
    

}


 // MARK: - API requests
extension EventDetailsVC {
    
    func GetEventsListData(id:String) {
        HUD.show(.progress , onView: view)
        let FinalURL = "\(ApiManager.Apis.EventDetails.description)\(id)"
          
          ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())", "Accept": "application/json",
                 "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
              
              if tmp == nil {
                  HUD.hide()
                  do {
                    self.eventOffers = try JSONDecoder().decode(EventsOffers.self, from: data!)
                    self.offersTable.reloadData()
                  }catch {
                      HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                  }
                  
              }else if tmp == "401" {
                  let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                  keyWindow?.rootViewController = vc
                  
              }
              
          }
      }
    
    func AcceptRejectEventOffer(id:String, action:String) // 0 : reject , 1:accept
    {
           ApiManager.shared.ApiRequest(URL: ApiManager.Apis.AcceptRejectEvent.description, method: .post, parameters: ["offer_id":id, "action":action],encoding: URLEncoding.default, Header:["Authorization": "Bearer \(User.shared.TakeToken())", "Accept": "application/json" , "locale" : UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier],ExtraParams: "", view: self.view) { (data, tmp) in
               if tmp == nil {
                   HUD.hide()
                   do {
                    self.GetEventsListData(id: self.EventID)
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
extension EventDetailsVC: UITableViewDelegate , UITableViewDataSource, EventOfferDelegate {
   
    func Accept_Reject(OfferID: String, action: String) {
       AcceptRejectEventOffer(id: OfferID, action: action)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventOffers.data?.salons_offers?.count ?? 0
     }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "EventOfferTableCell", for: indexPath) as? EventOfferTableCell {

            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.delegate = self
            cell.UpdateView(offer: eventOffers.data?.salons_offers?[indexPath.row] ?? EventOffer(), available_status: eventOffers.data?.available_status ?? "0")
            return cell
        }
        
        return CenterServicesTableCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }


    
}
