//
//  CreateEventVC.swift
//  Vrou
//
//  Created by Mac on 1/20/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import PKHUD
import Alamofire
import SwiftyJSON

class CreateEventVC: UIViewController {

    @IBOutlet weak var EventNameTxtField: UITextField!
    @IBOutlet weak var EventDetailsTxtField: UITextField!
    @IBOutlet weak var placesBtn: UIButton!
    @IBOutlet weak var placeOfServicesBtn: UIButton!
    @IBOutlet weak var TimeBtn: UIButton!
    @IBOutlet weak var ServiceBtn: UIButton!
    @IBOutlet weak var publishBtnImage: UIImageView!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var publishLbl: UILabel!
    
    
    
    var places = Cities()
    var PlacesNames = [String]()
    var placeOfservice = AreaList()
    var placeOfserviceNames = [String]()
    var success = ErrorMsg()
    var toArabic = ToArabic()
    
    var choosenPlaceOfServiceID = ""
    var choosenPlaceID = ""
    var choosenPlaceOfServiceIndex = 0
    var choosenPlaceIndex = 0
    var choosenDateTime = ""
    
    var services = [String]()
    var PickerMode = 0  // 0: places , 1:placesOfService
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetLocalizations()
        GetCities()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if  SelectedServiceCategoriesEvent.choosenNames.count > 0 {
            var title = ""
            var f_loop = false
            
            SelectedServiceCategoriesEvent.choosenNames.forEach { (name) in
                if f_loop {
                     title += " , " + name
                }else {
                     title += name
                     f_loop = true
                }
               
            }
            
            ServiceBtn.setTitle(title, for: .normal)
            ServiceBtn.setTitleColor(#colorLiteral(red: 0.6897211671, green: 0.1131197438, blue: 0.460976243, alpha: 1), for: .normal)
        }else {
            ServiceBtn.setTitle(NSLocalizedString("Select Service", comment: ""), for: .normal)
            ServiceBtn.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
        }
        
    }
    
    
    func SetLocalizations() {
         EventNameTxtField.placeholder = NSLocalizedString("Event Name", comment: "")
         EventDetailsTxtField.placeholder = NSLocalizedString("Event Details", comment: "")
         placesBtn.setTitle(NSLocalizedString("Place", comment: ""), for: .normal)
         placeOfServicesBtn.setTitle(NSLocalizedString("Place of Service", comment: ""), for: .normal)
         TimeBtn.setTitle(NSLocalizedString("Time", comment: ""), for: .normal)
         ServiceBtn.setTitle(NSLocalizedString("Select Service", comment: ""), for: .normal)
         publishLbl.text = NSLocalizedString("Publish", comment: "")
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            toArabic.ReverseButtonAlignment(Button: placesBtn)
            toArabic.ReverseButtonAlignment(Button: placeOfServicesBtn)
            toArabic.ReverseButtonAlignment(Button: TimeBtn)
            toArabic.ReverseButtonAlignment(Button: ServiceBtn)
            toArabic.ReverseImage(Image: publishBtnImage)
            toArabic.ReverseImage(Image: arrowImage)
        }
        
     }

    
    @IBAction func PublishBtn_pressed(_ sender: Any) {
        if EventNameTxtField.text == "" || EventDetailsTxtField.text == "" || choosenPlaceOfServiceID == "0" || choosenDateTime == "" || SelectedServiceCategoriesEvent.choosenIDs.count == 0 {
            HUD.flash(.label(NSLocalizedString("Please fill all fields", comment: "")) , onView: self.view , delay: 1.6 , completion: nil)
        }else {
            CreateEvent()
        }
    }
    
    
    @IBAction func PlaceBtn_pressed(_ sender: Any) {
        PickerMode = 0
        PickerActionSheet(pickerMode: 0, title: NSLocalizedString("Choose place of Event", comment: ""))
    }
    
    @IBAction func placeOfServiceBtn_pressed(_ sender: Any) {
        PickerMode = 1
         PickerActionSheet(pickerMode: 1, title: NSLocalizedString("Choose Place of service", comment: ""))
    }
    
    
    @IBAction func TimeBtn_pressed(_ sender: Any) {
        ShowDateTimePicker()
    }
    
    
    @IBAction func SelecrServiceBtn_pressed(_ sender: Any) {
        
        if choosenPlaceID == "" {
            HUD.flash(.label(NSLocalizedString("Please choose city", comment: "")) , onView: self.view , delay: 1.6 , completion: nil)
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChooseMultiServicesVC") as! ChooseMultiServicesVC
            vc.cityID = choosenPlaceID
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    
    
    
    func ShowDateTimePicker(){
        
        let message = "\n\n\n\n\n\n"
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.actionSheet)
        alert.isModalInPopover = true
        
        let datePicker: UIDatePicker = UIDatePicker()
        datePicker.frame = CGRect(x: 10, y: 10, width: self.view.frame.width, height: 150)
        datePicker.datePickerMode = UIDatePicker.Mode.dateAndTime
        datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale =  NSLocale(localeIdentifier: "en") as Locale


        //Add the picker to the alert controller
        alert.view.addSubview(datePicker)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            //Perform Action
            let selectedDate = dateFormatter.string(from: datePicker.date)
            self.choosenDateTime = selectedDate
            self.TimeBtn.setTitle(selectedDate, for: .normal)
        })
        
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion:nil)
        
    }
    
    
    
    
}


// MARK: - API Requests
extension CreateEventVC {
    
    func GetCities() {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: "\(ApiManager.Apis.CitiesList.description)\(User.shared.data?.user?.country_id ?? "0")", method: .get, Header: [
            "Accept": "application/json",
            "locale": UserDefaults.standard.string(forKey: "Language") ?? "en",
            "timezone": TimeZoneValue.localTimeZoneIdentifier
        ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                HUD.hide()
                do {
                    self.places = try JSONDecoder().decode(Cities.self, from: data!)
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                keyWindow?.rootViewController = vc
                
            }
            
        }
    }
    
    func GetAreas() {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: "\(ApiManager.Apis.AreasList.description)\(choosenPlaceID)", method: .get, Header: [
            "Accept": "application/json",
            "locale": UserDefaults.standard.string(forKey: "Language") ?? "en",
            "timezone": TimeZoneValue.localTimeZoneIdentifier
        ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                HUD.hide()
                do {
                    self.placeOfservice = try JSONDecoder().decode(AreaList.self, from: data!)
                    self.placeOfServicesBtn.setTitle(NSLocalizedString("Place of Service", comment: ""), for: .normal)
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                keyWindow?.rootViewController = vc
                
            }
            
        }
    }
    
    
    
    func CreateEvent() {
        var params = [String:Any]()
        
        params = ["event_name":EventNameTxtField.text! , "event_details":EventDetailsTxtField.text! , "area_id": choosenPlaceOfServiceID , "event_date":choosenDateTime]
        var counter = 0
        SelectedServiceCategoriesEvent.choosenIDs.forEach { (id) in
            params["service_id[\(counter)]"] = id
            counter+=1
        }
    
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.CreateEvent.description, method: .post, parameters: params,encoding: URLEncoding.default, Header:["Authorization": "Bearer \(User.shared.TakeToken())", "Accept": "application/json" , "locale" : UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier],ExtraParams: "", view: self.view) { (data, tmp) in
            if tmp == nil {
                HUD.hide()
                do {
                    self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                    HUD.flash(.label(self.success.msg?[0] ?? "Success") , onView: self.view , delay: 1.6 , completion: {
                        (tmp) in
                        SelectedServiceCategoriesEvent.choosenIDs.removeAll()
                        SelectedServiceCategoriesEvent.choosenNames.removeAll()
                        self.navigationController?.popViewController(animated: true)
                    })
                    
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



// MARK: - PickerDelegate

extension CreateEventVC : UIPickerViewDataSource , UIPickerViewDelegate {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
     }
     
     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch PickerMode {
        case 0: // places
            return places.data?.count ?? 0
            
        case 1: // place of service
            return placeOfservice.data?.count ?? 0

        default:
            return 0
        }
        
     }
     
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch PickerMode {
        case 0: // places
            return places.data?[row].city_name ?? ""
            
        case 1: // places of services
            return placeOfservice.data?[row].area_name ?? ""
            
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       switch PickerMode {
       case 0: // places
          choosenPlaceIndex = pickerView.selectedRow(inComponent: 0)
           break
       case 1: // place of service
          choosenPlaceOfServiceIndex = pickerView.selectedRow(inComponent: 0)
           break
       default:
            break
       }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func PickerActionSheet(pickerMode:Int,title:String) {
        let message = "\n\n\n\n\n\n"
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.isModalInPopover = true
        
        let height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 300)
        alert.view.addConstraint(height)
        
        let pickerFrame = UIPickerView(frame: CGRect(x: 0, y: 20, width: 270, height: 220))
        pickerFrame.tag = 555
        //set the pickers datasource and delegate
        pickerFrame.delegate = self
        pickerFrame.dataSource = self
        //Add the picker to the alert controller
        alert.view.addSubview(pickerFrame)
        let okAction = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            switch pickerMode {
            case 0: // places
                self.placesBtn.setTitle(self.places.data?[self.choosenPlaceIndex].city_name ?? "", for: .normal)
                self.choosenPlaceID = "\(self.places.data?[self.choosenPlaceIndex].id ?? Int())"
                self.GetAreas()
                
                break
                
            case 1: // places of services
                self.placeOfServicesBtn.setTitle(self.placeOfservice.data?[self.choosenPlaceOfServiceIndex].area_name ?? "", for: .normal)
                self.choosenPlaceOfServiceID = "\(self.placeOfservice.data?[self.choosenPlaceOfServiceIndex].id ?? Int())"
                break
            default:
                break
            }
            
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
}


struct SelectedServiceCategoriesEvent {
    public static var choosenIDs = [String]()
    public static var choosenNames = [String]()
}
