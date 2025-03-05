//
//  ProductsSearchVC.swift
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

class ProductsSearchVC: UIViewController {
    
     // MARK: - IBOutlet
    @IBOutlet weak var NoSearchResultImage: UIImageView!
    @IBOutlet weak var noSearchResultView: UIView!
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var ProductsCollection: UICollectionView!
    
    // MARK: - Variables
    var productSearch : [ProductSearchData]? = []
    var dismissKeyboard = true
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
    var timerTyping : Timer?


    
     // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        SearchBar.delegate = self
        SetUpCollectionView(collection: ProductsCollection)
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
    
    func SetUpCollectionView(collection:UICollectionView){
        collection.delegate = self
        collection.dataSource = self
        collection.register(UINib(nibName: "LoadingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LoadingCollectionViewCell")

    }
    
     // MARK: - SetupSideMenu
    @IBAction func openSideMenu(_ button: UIButton){
           Vrou.openSideMenu(vc: self)
    }
     // MARK: - CentersBtn
    @IBAction func CentersBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CentersSearchNavController") as! CentersSearchNavController
        keyWindow?.rootViewController = vc
    }
    
     // MARK: - OffersBtn
    @IBAction func OffersBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OffersSearchNavController") as! OffersSearchNavController
        keyWindow?.rootViewController = vc
    }
    
     // MARK: - ServicesBtn
    @IBAction func ServicesBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ServicesSearchNavController") as! ServicesSearchNavController
        keyWindow?.rootViewController = vc
    }
    
    
}

extension ProductsSearchVC {
     // MARK: - Search_API
    func GetSearchResult() {
        dismissKeyboard = false
        var FinalURL = ""
        current_page += 1
        is_loading = true
        
        if User.shared.isLogedIn() {
            FinalURL = "\(ApiManager.Apis.Search.description)key=\(SearchBar.text ?? "")&type=center&city_id=\(User.shared.data?.user?.city?.id ?? 0)&page=\(current_page)"
        }else {
            FinalURL = "\(ApiManager.Apis.Search.description)key=\(SearchBar.text ?? "")&type=product&city_id=\(UserDefaults.standard.integer(forKey: "GuestCityId"))&page=\(current_page)"
        }
        let safeURL = FinalURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        ApiManager.shared.ApiRequest(URL: safeURL , method: .get, Header: [ "Accept": "application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier], ExtraParams: "", view: self.view) { (data, tmp) in
            
            self.is_loading = false
            if tmp == nil {
                HUD.hide()
                do {
                    let decoded_data = try JSONDecoder().decode(ProductSearch.self, from: data!)
                    
                     if (self.current_page == 1){
                        self.productSearch = decoded_data.data
                    }else{
                        self.productSearch?.append(contentsOf: decoded_data.data!)
                    }
                    
                    //get pagination data
                    let paginationModel = decoded_data.pagination
                    self.has_more_pages = paginationModel?.has_more_pages ?? false
                    
                    print("has_more_pages ==>\(self.has_more_pages)")
                    self.noSearchResultView.isHidden = true
                    self.ProductsCollection.isHidden = false
                    self.ProductsCollection.reloadData()
                    
                    if self.productSearch?.count ?? 0 == 0 {
                        self.noSearchResultView.isHidden = false
                        self.ProductsCollection.isHidden = true
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
extension ProductsSearchVC:UISearchBarDelegate {
    
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
        productSearch?.removeAll()
        ProductsCollection.reloadData()
        
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
extension ProductsSearchVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout  {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == ProductsCollection {
            
            let pager = (productSearch?.count ?? 0 >= 1) ? (has_more_pages ? 1 : 0): 0
            print("pager items num ==> \(pager)")
            return (productSearch?.count ?? 0) + pager
        }
        
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (indexPath.row >= (productSearch?.count ?? 0)) {
           
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCollectionViewCell", for: indexPath) as! LoadingCollectionViewCell
            
            cell.loader.startAnimating()
            
            return cell
        }
                
        if collectionView == ProductsCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCategoryProductCollCell", for: indexPath) as? SubCategoryProductCollCell {
                
                cell.UpdateView(product: productSearch?[indexPath.row] ?? ProductSearchData())
                
                return cell
            }
        }
        
        return ForYouCollCell()
        
        
        
    }
    
    //check for pagination
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //for center pagination
             if (indexPath.row >= (productSearch?.count ?? 0) ){
                
                if has_more_pages && !is_loading {
                    print("start loading")
                    GetSearchResult()

                }
             }
 
    }

    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == ProductsCollection {
            let height:CGSize = CGSize(width: self.ProductsCollection.frame.width/2 , height: self.ProductsCollection.frame.height/2)
            
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
        
        if collectionView == ProductsCollection {
            
            let vc = UIStoryboard(name: "Categories", bundle: nil).instantiateViewController(withIdentifier: "OfferVC") as! OfferVC
            let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = item
            self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "BackArrow")
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "BackArrow")
            vc.productID = "\(productSearch?[indexPath.row].id ?? Int())"
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    
}
