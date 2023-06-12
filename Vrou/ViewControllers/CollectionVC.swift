//
//  CollectionVC.swift
//  Vrou
//
//  Created by Mac on 1/9/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import PKHUD
import Alamofire
import SwiftyJSON

class CollectionVC: UIViewController {

    // MARK: - IBoutlets
    @IBOutlet weak var CollectionTable: UITableView!
    @IBOutlet weak var CreateCollectionView: UIView!
    @IBOutlet weak var collectionNameField: UITextField!
    @IBOutlet weak var newBtn: UIButton!
    @IBOutlet weak var SaveBtn: UIButton!
    @IBOutlet weak var CancelBtn: UIButton!
    @IBOutlet weak var collectionNameTxtField: UITextField!
    
    var collectionName = ""
    var success = ErrorMsg()
    
    
    // MARK: - variables
    var collections = CollectionsModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CollectionTable.delegate = self
        CollectionTable.dataSource = self
        CollectionTable.separatorStyle = .none
        CreateCollectionView.isHidden = true
        newBtn.setTitle(NSLocalizedString("New", comment: ""), for: .normal)
        collectionNameTxtField.placeholder = NSLocalizedString("Collection Name", comment: "")
        SaveBtn.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        CancelBtn.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        HUD.show(.progress , onView: view)
        GetCollectionsData()
        
    }
    
    @IBAction func NewBtn_pressed(_ sender: Any) {
        CreateCollectionView.isHidden = false
        
    }
    
    
    @IBAction func CancelBtn_pressed(_ sender: Any) {
         CreateCollectionView.isHidden = true
    }
    
    
    @IBAction func SaveBtn_pressed(_ sender: Any) {
        HUD.show(.progress , onView: view)
        if collectionNameField.text != "" {
            collectionName = collectionNameField.text ?? ""
            AddCollection()
            CreateCollectionView.isHidden = true
            collectionNameField.text = ""
        }else {
           if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
               HUD.flash(.label("Please Enter collection name") , onView: self.view , delay: 1.6 , completion: nil)
           }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar"  {
               HUD.flash(.label("الرجاء ادخال اسم المجموعة") , onView: self.view , delay: 1.6 , completion: nil)
           }
        }
       
    }
    
}


// MARK: - API Requests
extension CollectionVC {
    
    func GetCollectionsData() {
        ApiManager.shared.ApiRequest(URL: "\(ApiManager.Apis.CollectionList.description)1" , method: .get, Header: ["Authorization": "Bearer \(User.shared.TakeToken())",
            "Accept": "application/json",
            "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
                if tmp == nil {
                    HUD.hide()
                    do {
                        self.collections = try JSONDecoder().decode(CollectionsModel.self, from: data!)
                        self.CollectionTable.reloadData()
                        
                    }catch {
                        HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                    }
                    
                }else if tmp == "401" {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    keyWindow?.rootViewController = vc
                    
                }else if tmp == "NoConnect" {
                    guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                    vc.callbackClosure = { [weak self] in
                        self?.GetCollectionsData()
                    }
                    self.present(vc, animated: true, completion: nil)
                }
        }
    }
    
    
    func AddCollection() {
         HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.CreateCollection_addItem.description, method: .post, parameters: ["type": "0" , "collection_name": collectionName], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
                    ExtraParams: "", view: self.view) { (data, tmp) in
                        if tmp == nil {
                             HUD.hide()
                            do {
                                 self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                                self.GetCollectionsData()
                                 
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
extension CollectionVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return collections.data?.collections?.count ?? 0
    }
    

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if collections.data?.collections?[indexPath.row].items?.count ?? 0 == 0 {
            return 50
        }else {
            return 200
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionTableCell", for: indexPath) as? CollectionTableCell {
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.items = collections.data?.collections?[indexPath.row].items ?? [CollectionsItems]()
            cell.UpdateView(collection: collections.data?.collections?[indexPath.row] ?? CollectionModel())
            
            return cell
        }
        
        return CollectionTableCell()
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    
    
}



