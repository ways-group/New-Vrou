//
//  SalonProfileSettings.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/23/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

//user this pop up for salon profile & user profile
class SalonProfileSettingsPopUp: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var popUpViewHeight: NSLayoutConstraint!

    var salonId = 0
    var salonAbout: SalonAboutData? = SalonAboutData()
    var user:ProfileDataUser?
    var success = ErrorMsg()
    var isUserProfilePopUp = false
    var friendProfile = false
    var parentView: UIViewController!

    let userProfileItems = [(4, NSLocalizedString("Edit profile", comment: ""), #imageLiteral(resourceName: "Pencil")), (5, NSLocalizedString("QrCode", comment: ""), #imageLiteral(resourceName: "qrCodeWgite")), (6, "Delete Account".localized, UIImage(named: "Delete")!)]
    var items = [(0, NSLocalizedString("Check in", comment: ""), #imageLiteral(resourceName: "checkin_icon")), (1, NSLocalizedString("Share", comment: ""), #imageLiteral(resourceName: "share_icon")), (2, NSLocalizedString("Direction", comment: ""), #imageLiteral(resourceName: "pin_icon")), (3, NSLocalizedString("Reservation policy", comment: ""), #imageLiteral(resourceName: "policy_icon"))]
   
    override func viewDidLoad() {
        super.viewDidLoad()
        items = (user != nil) ? userProfileItems : items
        if friendProfile {items.remove(at: 0)}
        tableView.reloadData()
    }
    
     func QrCodeBtn_pressed() {
        let vc = View.QR_codeVC.identifyViewController(viewControllerType: QR_codeVC.self)
        vc.salonLogo = salonAbout?.about?.salon_logo ?? ""
        vc.salonName  = salonAbout?.about?.salon_name ?? ""
        vc.salonCategory = salonAbout?.about?.category?.category_name ?? ""
        vc.QrCodeLink = salonAbout?.about?.qr_code ?? ""
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func PinBtn_pressed() {
        if User.shared.isLogedIn() {
            HUD.show(.progress , onView: view)
            PinSalon()
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController")
            vc.modalPresentationStyle = .fullScreen
            self.dismiss(animated: false)
            RouterManager(parentView).present(controller: vc)
        }
    }

    func MapBtn_pressed() {
        
        if self.salonAbout?.main_branch?.lat ?? "" != "" && self.salonAbout?.main_branch?.long ?? "" != "" {
            
            let lat = round(1000*Double(self.salonAbout?.main_branch?.lat ?? "")!)/1000
            let lon =  round(1000*Double(self.salonAbout?.main_branch?.long ?? "")!)/1000
            if (UIApplication.shared.canOpenURL(NSURL(string:"https://maps.google.com")! as URL))
            {
                UIApplication.shared.openURL(NSURL(string:
                    "https://maps.google.com/?q=\(lat),\(lon)")! as URL)
            }
        }
        
    }
    
    func deleteAccountAPI() {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.DeleteAccount.description, method: .post, Header:["Authorization": "Bearer \(User.shared.TakeToken())"], ExtraParams: "", view: view) { [weak self] data, error in
            HUD.hide()
            if error == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.deleteAccountPressed()
                }
                self?.present(vc, animated: true, completion: nil)
            } else {
                User.shared.remove()
                let vc = UIStoryboard(name: "Master", bundle: nil).instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
                let vcc = UINavigationController(rootViewController: vc)
                keyWindow?.rootViewController = vcc
            }
        }
    }
    
    func deleteAccountPressed() {
        let alert = UIAlertController(title: "Delete Account".localized, message: "Are you sure you want to delete your account. Please note that this step can't redo.".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete".localized, style: .destructive, handler: { [weak self] action in
            self?.deleteAccountAPI()
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
    
    func reservationPolicy_pressed() {
        let vc = View.ServicePolicyVC.identifyViewController(viewControllerType: ServicePolicyVC.self)
        vc.policy = salonAbout?.about?.reservation_policy ?? ""
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
///////
    func goToQrCode() {
        let vc =  View.ProfileQrVC.identifyViewController(viewControllerType: ProfileQrVC.self)
        vc.QrCodeLink = user?.qr_code ?? ""
        vc.QrCodeString = user?.user_number ?? ""
        vc.ProfileImage = user?.image ?? ""
        vc.ProfileName = user?.name ?? ""
        vc.City = user?.city?.city_name ?? ""
        vc.credit = "\(user?.credit ?? "") \(user?.currency ?? "")"
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    func goToEditProfile() {
        let vc =  View.EditAccountVC.identifyViewController(viewControllerType: EditAccountVC.self)
        self.dismiss(animated: false)
        RouterManager(parentView).push(controller: vc)
    }

    @IBAction func dismissAction(_ button: UIButton){
        self.dismiss(animated: false)
    }
}

extension SalonProfileSettingsPopUp: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let itemscount = items.count
        popUpViewHeight.constant = CGFloat(itemscount * 40)
        return itemscount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "Settingscell",for: indexPath) as! Settingscell
        cell.setCell(info: items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      //  self.dismiss(animated: false)
        switch items[indexPath.row].0 {
        case 0: PinBtn_pressed()
        case 1: QrCodeBtn_pressed()
        case 2: MapBtn_pressed()
        case 3: reservationPolicy_pressed()
        case 4: goToEditProfile()
        case 5: goToQrCode()
        case 6: deleteAccountPressed()
        default: break
        }
    }
}

extension SalonProfileSettingsPopUp {
    func PinSalon() {
           let FinalURL =  ApiManager.Apis.AddDeleteVisitSalon.description
           let params  = ["salon_id": salonId , "action_type" : salonAbout?.is_visited ?? 0]
           if User.shared.isLogedIn() {
               ApiManager.shared.ApiRequest(URL: FinalURL, method: .post, parameters: params, encoding: URLEncoding.default, Header: ["Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ] , ExtraParams: "", view: self.view) { (data, tmp) in
                   
                   if tmp == nil {
                       HUD.hide()
                       do {
                           self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                           HUD.flash(.label("\(self.success.msg?[0] ?? "Success")") , onView: self.view , delay: 1.6 , completion: {
                               (tmp) in
                            let visited = (self.salonAbout?.is_visited ?? 0) == 0 ? 1 : 0
                            let salonProfileRootView =  self.parentView as! SalonProfileRootView
                            salonProfileRootView.salonAbout?.is_visited = visited
                            self.dismiss(animated: false)
                           })
                           
                       }catch {
                           HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                       }
                   }
               }
           }
       }
}


class Settingscell: UITableViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var txt: UILabel!
    
    func setCell(info: (Int, String, UIImage)){
        imageView?.image = info.2
        txt.text = info.1
    }
}
