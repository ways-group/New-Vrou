//
//  CenterSearchVC.swift
//  Vrou
//
//  Created by Mac on 11/18/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import MXParallaxHeader
import ViewAnimator
import SwiftyJSON
import PKHUD
import SideMenu

class CentersSearchVC: UIViewController,MXParallaxHeaderDelegate {
    // MARK: - IBOutlet
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var CentersCollection: UICollectionView!
    
    // MARK: - Variables
    var centerSearch : [CenterSearchData]? = []
    var ParalexHeight = CGFloat(150)
    var dismissKeyboard = true
    var uiSUpport = UISupport()
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
    var timerTyping : Timer?

    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nav = self.navigationController {
            uiSUpport.TransparentNavigationController(navController: nav)
        }
        
        SearchBar.delegate = self
        SetUpCollectionView(collection: CentersCollection)
        SearchBar.becomeFirstResponder()
        SearchBar.text = SearchWord.word
        if SearchBar.text != "" {
             HUD.show(.progress , onView: view)
            GetSearchResult()
        }
        setupSideMenu()
    }
    
    
    func SetUpCollectionView(collection:UICollectionView){
        collection.delegate = self
        collection.dataSource = self
        CentersCollection.register(UINib(nibName: "LoadingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LoadingCollectionViewCell")

    }
    
    // MARK: - SetupSideMenu
    private func setupSideMenu() {
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sideMenuNavigationController = segue.destination as? SideMenuNavigationController else { return }
        sideMenuNavigationController.settings = makeSettings()
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            sideMenuNavigationController.leftSide = false
        }
    }
    
    private func makeSettings() -> SideMenuSettings {
        let presentationStyle = selectedPresentationStyle()
        presentationStyle.menuStartAlpha = 1.0
        presentationStyle.onTopShadowOpacity = 0.0
        presentationStyle.presentingEndAlpha = 1.0
        
        var settings = SideMenuSettings()
        settings.presentationStyle = presentationStyle
        settings.menuWidth = min(view.frame.width, view.frame.height)  * 0.9
        settings.statusBarEndAlpha = 0
        
        return settings
    }
    
    private func selectedPresentationStyle() -> SideMenuPresentationStyle {
        return .viewSlideOutMenuIn
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
    
    // MARK: - ServicesBtn
    @IBAction func ServicesBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ServicesSearchNavController") as! ServicesSearchNavController
        keyWindow?.rootViewController = vc
    }
    
}


extension CentersSearchVC {
    
    // MARK: - SearchResult_API
    func GetSearchResult() {
    
        if ((SearchBar.text ?? "") == "")  {
                 print("%%%%%%%%%%%%%%%%%")
                 centerSearch?.removeAll()
                 CentersCollection.reloadData()
            
            return
        }
        dismissKeyboard = false
        var FinalURL = ""
        current_page += 1
        is_loading = true
        
        if User.shared.isLogedIn() {
            
            FinalURL = "\(ApiManager.Apis.Search.description)key=\(SearchBar.text ?? "")&type=center&city_id=\(User.shared.data?.user?.city?.id ?? 0)&page=\(current_page)"
        }else {
            FinalURL = "\(ApiManager.Apis.Search.description)key=\(SearchBar.text ?? "")&type=center&city_id=\(UserDefaults.standard.integer(forKey: "GuestCityId"))&page=\(current_page)"

        }
        let safeURL = FinalURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        
        ApiManager.shared.ApiRequest(URL: safeURL , method: .get, Header: [ "Accept": "application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier], ExtraParams: "", view: self.view) { (data, tmp) in
            
            self.is_loading = false
            if tmp == nil {
                HUD.hide()
                do {
                    let decoded_data = try JSONDecoder().decode(CenterSearch.self, from: data!)
                    
                    if (self.current_page == 1){
                        self.centerSearch = decoded_data.data
                    }else{
                        self.centerSearch?.append(contentsOf: decoded_data.data!)
                    }
                    
                    //get pagination data
                    let paginationModel = decoded_data.pagination
                    self.has_more_pages = paginationModel?.has_more_pages ?? false
                    
                    print("has_more_pages ==>\(self.has_more_pages)")
                    
                    
                    self.CentersCollection.reloadData()
                    if self.centerSearch?.count ?? 0 == 0 {
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

// MARK: - SearchBarDelegate
extension CentersSearchVC:UISearchBarDelegate {
    
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
        centerSearch?.removeAll()
        CentersCollection.reloadData()
        
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


// MARK: - CollectionViewDelegate
extension CentersSearchVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout  {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == CentersCollection {
            let pager = (centerSearch?.count ?? 0 >= 1) ? (has_more_pages ? 1 : 0): 0
            print("pager items num ==> \(pager)")

            return (centerSearch?.count ?? 0) + pager
        }
        
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == CentersCollection {
            
            if (indexPath.row >= (centerSearch?.count ?? 0)) {
               
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCollectionViewCell", for: indexPath) as! LoadingCollectionViewCell
                
                cell.loader.startAnimating()
                
                return cell
            }

            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CenterCollCell", for: indexPath) as? CenterCollCell {
                
                cell.UpdateView(salon: centerSearch?[indexPath.row] ?? CenterSearchData())
                
                return cell
            }
        }
        return ForYouCollCell()
    }
    
    //check for pagination
      func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
          
          //for center pagination
          if collectionView == CentersCollection {
              if (indexPath.row >= (centerSearch?.count ?? 0) ){
                  
                  if has_more_pages && !is_loading {
                      print("start loading")
                      GetSearchResult()
 
                  }
               }
          }
          
      }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == CentersCollection {
            
            let height:CGSize = CGSize(width: self.CentersCollection.frame.width , height: CGFloat(90))
            
            return height
        }
        
        return CGSize()
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == CentersCollection {
            let salon_id = centerSearch?[indexPath.row].id ?? 0
            NavigationUtils.goToSalonProfile(from: self, salon_id: salon_id)

        }
        
    }
    
    
}
