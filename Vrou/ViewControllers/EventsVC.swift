//
//  EventsVC.swift
//  Vrou
//
//  Created by Mac on 1/19/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import PKHUD

class EventsVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var EventsTable: UITableView!
    @IBOutlet weak var newEventBtn: UIBarButtonItem!

    
    // MARK: - Variables
    var events = Events()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        newEventBtn.title = NSLocalizedString("New Event", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        EventsTable.delegate = self
        EventsTable.dataSource = self
        EventsTable.separatorStyle = .none
        GetEventsListData()
    }
    
    
     // MARK: - NewEvent Btn
    @IBAction func NewEventsBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateEventVC") as! CreateEventVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}


 // MARK: - API requests
extension EventsVC {
    
    func GetEventsListData() {
        HUD.show(.progress , onView: view)
        let FinalURL = "\(ApiManager.Apis.EventsList.description)"
          
          ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())", "Accept": "application/json",
                 "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
              
              if tmp == nil {
                  HUD.hide()
                  do {
                    self.events = try JSONDecoder().decode(Events.self, from: data!)
                    self.EventsTable.reloadData()
                    
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
extension EventsVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return events.data?.events?.count ?? 0
        
     }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        if let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableCell", for: indexPath) as? EventTableCell {

            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.UpdateView(event: events.data?.events?[indexPath.row] ?? EventModel())
            
            return cell
        }
        
        return CenterServicesTableCell()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (events.data?.events?[indexPath.row].salons_offers_count ?? 0 > 0) {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EventDetailsVC") as! EventDetailsVC
            vc.EventID = "\(events.data?.events?[indexPath.row].id ?? Int())"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }


    
}
