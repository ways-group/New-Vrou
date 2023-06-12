//
//  ThisDayOnVrouVC.swift
//  Vrou
//
//  Created by Mac on 12/30/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import PKHUD

class ThisDayOnVrouVC: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var BackImage: UIImageView!
    @IBOutlet weak var ItemsTable: UITableView!
    @IBOutlet weak var TitlesView: UIView!
    @IBOutlet weak var BackView: UIView!
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var swipeLbl: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var weekOffers = WeekOffers()
    var uiSupport = UISupport()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let nav = self.navigationController {
            uiSupport.TransparentNavigationController(navController: nav)
        }
        
        AddBlurEffect(view: BackImage)
        ItemsTable.delegate = self
        ItemsTable.dataSource = self
        ItemsTable.separatorStyle = .none
       
        let date = Date()
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        var DateString = ""
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en"{
            dateFormatter.locale =  NSLocale(localeIdentifier: "en") as Locale
            let day = calendar.component(.day, from: date)
            let year = calendar.component(.year, from: date)
            let dayLast = calendar.date(byAdding: .day, value: 7, to: Date())
            DateString = "From week \(dateFormatter.string(from: date)) \(day), \(year)"
            
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
             dateFormatter.locale =  NSLocale(localeIdentifier: "ar") as Locale
            let day = calendar.component(.day, from: date)
            let year = calendar.component(.year, from: date)
            let dayLast = calendar.date(byAdding: .day, value: 7, to: Date())
            DateString = "الاسبوع من  \(day) \(dateFormatter.string(from: date)) , \(year)"
        }
        
        UserDefaults.standard.set(true, forKey: "WeekOffer")
        
        TitleLbl.text = NSLocalizedString("This week \n on VROU", comment: "")
        swipeLbl.text = NSLocalizedString("Swipe up to show", comment: "")
        DateLbl.text = DateString
        cancelBtn.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        // Do any additional setup after loading the view.
        GetOffersData()
    }
    
    
    func AddBlurEffect(view:UIView) {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /* This is the offset at the bottom of the scroll view. */
        let totalScroll = scrollView.contentSize.height - scrollView.bounds.size.height;
          /* This is the current offset. */
        let offset = (scrollView.contentOffset.y) //* -1;
          /* This is the percentage of the current offset / bottom offset. */
        let percentage = offset / totalScroll;
          /* When percentage = 0, the alpha should be 1 so we should flip the percentage. */
        TitlesView.alpha = (1.0 - percentage*totalScroll/TitlesView.bounds.size.height);
        BackView.alpha = ((1.0 - percentage*6) - 0.8) * -1
        let scale = min(max(1.0 - offset / scrollView.bounds.size.height , 0.0), 1.0)
        TitlesView.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    
    @IBAction func CancelBtn_pressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}

// MARK: - API Requests
extension ThisDayOnVrouVC {
    
    func GetOffersData() {
        
        var FinalURL = ""
        
        if User.shared.isLogedIn() {
            FinalURL = "\(ApiManager.Apis.WeekOffers.description)\(User.shared.data?.user?.city?.id ?? 0)"
        }else {
            FinalURL = "\(ApiManager.Apis.WeekOffers.description)0"
        }
        
          ApiManager.shared.ApiRequest(URL: FinalURL , method: .get, Header:
          [ "Accept":"application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
                
                if tmp == nil {
                    HUD.hide()
                    do {
                        self.weekOffers = try JSONDecoder().decode(WeekOffers.self, from: data!)
                        self.ItemsTable.reloadData()
                    }catch {
                        HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                    }
                    
                }else if tmp == "401" {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                       vc.callbackClosure = { [weak self] in
                            self?.GetOffersData()
                       }
                            self.present(vc, animated: true, completion: nil)
                      }
            }
        }
    
    
    
    

    
    
}

// MARK: - TableViewDelegate
extension ThisDayOnVrouVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekOffers.data?.offers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TodayTableCell", for: indexPath) as? TodayTableCell {
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.UpdateView(offer: weekOffers.data?.offers?[indexPath.row] ?? Offer())
            return cell
        }
        
        return TodayTableCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "SalonOfferVC") as! SalonOfferVC
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = item
        self.navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "BackArrow")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "BackArrow")
        vc.OfferID = "\(weekOffers.data?.offers?[indexPath.row].id ?? Int())"
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(300)
    }
    
    
}
