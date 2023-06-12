//
//  ChooseMultiServicesVC.swift
//  Vrou
//
//  Created by Mac on 1/20/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import PKHUD

class ChooseMultiServicesVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var ServicesTable: UITableView!
    
    // MARK: - variables
    var servicesCategories = ServiceCategories()
    var cityID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        ServicesTable.delegate = self
        ServicesTable.dataSource = self
       // ServicesTable.separatorStyle = .none
        ServicesTable.allowsMultipleSelection = true
        ServicesTable.allowsMultipleSelectionDuringEditing = true
        
        GetServicesCatgeoriesData(id: cityID)
    }
    
  

}

// MARK: - API Request
extension ChooseMultiServicesVC {
    
    // MARK: - GetServicesCategories_API
    func GetServicesCatgeoriesData(id:String) {
         HUD.show(.progress , onView: view)
        var FinalURL = ""
        
        if User.shared.isLogedIn() {
            FinalURL = "\(ApiManager.Apis.InServicesCategories.description)0&city_id=\(id)"
        }else {
            FinalURL = "\(ApiManager.Apis.InServicesCategories.description)0&city_id=\(id)"
        }
        
           ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: [ "Accept": "application/json",
           "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
                 
                 if tmp == nil {
                     HUD.hide()
                    do {
                       
                        self.servicesCategories = try JSONDecoder().decode(ServiceCategories.self, from: data!)
                        self.ServicesTable.reloadData()
                        
                     }catch {
                         HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                     }
                     
                 }else if tmp == "401" {
                     let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                     UIApplication.shared.keyWindow?.rootViewController = vc
                     
                 }
             }
         }
    
}





// MARK: - TableViewDelegate
extension ChooseMultiServicesVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return servicesCategories.data?.serviceCategories?.count ?? 0
        
     }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        if let cell = tableView.dequeueReusableCell(withIdentifier: "MultiChooseTableCell", for: indexPath) as? MultiChooseTableCell {

            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.UpdateView(cat: servicesCategories.data?.serviceCategories?[indexPath.row] ?? Category())
            
            return cell
        }
        
        return CenterServicesTableCell()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }


    
}
