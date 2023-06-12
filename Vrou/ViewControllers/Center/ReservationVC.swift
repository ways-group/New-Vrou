//
//  ReservationVC.swift
//  BeautySalon
//
//  Created by Islam Elgaafary on 10/3/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import FSCalendar
import MXParallaxHeader
import Alamofire
import SwiftyJSON
import PKHUD
import SDWebImage
import RSSelectionMenu
import MOLH

class ReservationVC: UIViewController, MXParallaxHeaderDelegate{
    
    // MARK: - IBOutlet
    @IBOutlet weak var SalonBackground: UIImageView!
    @IBOutlet weak var SalonLogo: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var ServiceImage: UIImageView!
    @IBOutlet weak var ServiceName: UILabel!
    @IBOutlet weak var ServiceDescription: UILabel!
    @IBOutlet weak var ServicePrice: UILabel!
    @IBOutlet weak var ServiceDuration: UILabel!
    
    @IBOutlet weak var timesCollection: UICollectionView!
    @IBOutlet weak var specialistsCollection: UICollectionView!
    @IBOutlet weak var SelectBranch: UIButton!
    @IBOutlet weak var SelectBranchLbl: UILabel!
    
    @IBOutlet weak var ServicePriceBottom: UILabel!
    @IBOutlet weak var ChooseSpecialistHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var mainView: FBShimmeringView!
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var reservationTimesHeight: NSLayoutConstraint!
    @IBOutlet weak var TimesNote: UILabel!
    
    @IBOutlet weak var TimesView: UIView!
    @IBOutlet weak var SalonViewDataHeight: NSLayoutConstraint!
    @IBOutlet weak var SalonView_parentDataHieght: NSLayoutConstraint!
    
    // MARK: - Variables
    var ServiceID = "1"
    var selectedDate = ""
    var selectedTime = ""
    var SelectedemployeeID = "0"
    var SelectedBranchIndex = 0
    var SelectedBranchID = ""
    var branchesNames = [String]()
    var serviceDetails = ServiceDetials()
    
    var serviceImage = UIImage()
    var serviceName = ""
    var serviceDescription = ""
    var servicePrice  = ""
    var serviceDuration = ""
    
    var TimesSlotsCounter = 0
    var times = [String]()
    
    var tmp1 = Int()
    var tmp2 = Int()
    
    var success = ErrorMsg()
    
    var FromHome = false
    var timeDateSlot = ""
    var getBranches = false
    
    var TodayDateSelected = true
    var FromSalonVC = false
    var toArabic = ToArabic()
    
    var TodayDatePage = 0
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
       
        calendar.delegate = self
        calendar.allowsMultipleSelection = false
       
        // ScrollHeaderSetup
        scrollView.parallaxHeader.view = headerView
        scrollView.parallaxHeader.height = 250
        scrollView.parallaxHeader.mode = .bottom
        scrollView.parallaxHeader.delegate = self
        
        // LoadingIndicatorSetup
        mainView.contentView = logo
        mainView.isShimmering = true
        mainView.shimmeringSpeed = 550
        mainView.shimmeringOpacity = 1
        
        if (FromHome){
            SelectBranch.isHidden = true
            SelectBranchLbl.isHidden = true
            SalonView_parentDataHieght.constant = 180
        }
        
        
        SetUpCollectionView(collection: timesCollection)
        SetUpCollectionView(collection: specialistsCollection)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
         selectedDate = dateFormatter.string(from: Date())
        
        GetReservationData(ServiceID: ServiceID, date: FormatDate(date: Date()))
        
        
        ServiceImage.image = serviceImage
        ServiceName.text = serviceName
        ServiceDescription.text = serviceDescription
        ServiceDuration.text = serviceDuration
        
    }
    

    func SetUpCollectionView(collection:UICollectionView){
      collection.delegate = self
      collection.dataSource = self
    }
    
    func FormatDate(date:Date) -> String {
         let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: date)
    }
    
    // MARK: - SalonLogoBtn
    @IBAction func SalonLogoBtn_pressed(_ sender: Any) {
        if !FromSalonVC {
            NavigationUtils.goToSalonProfile(from: self, salon_id: serviceDetails.data?.salon?.id ?? 0)
        }
    }
    
    // MARK: - SelectBranchPressed
    @IBAction func SelectBranch_pressed(_ sender: Any) {
        
        let selectionMenu =  RSSelectionMenu(dataSource: branchesNames) { (cell, object, indexPath) in
            cell.textLabel?.text = "\(self.branchesNames[indexPath.row])"
            cell.textLabel?.textColor = .black
            cell.textLabel?.textAlignment = .center
        }
        
        selectionMenu.setSelectedItems(items: [self.SelectBranch.title(for: .normal) ?? ""]) {
            (item, index, isSelected, selectedItems)  in
            
            self.SelectBranch.setTitle(item, for: .normal)
            self.SelectBranch.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            self.SelectedBranchID = "\(self.serviceDetails.data?.service?.branches?[index].id ?? Int()  )"
            self.SelectedBranchIndex = index
            self.times.removeAll()
            
            self.mainView.isHidden = false
            self.mainView.contentView = self.logo
            self.mainView.isShimmering = true
            self.mainView.shimmeringSpeed = 550
            self.mainView.shimmeringOpacity = 1
            self.GetReservationData(ServiceID: self.ServiceID, date: self.FormatDate(date: Date()))
        }
        
        // show as PresentationStyle = Push
        selectionMenu.show(style: .popover(sourceView: SelectBranch, size: CGSize(width: 220, height: 100)) , from: self)
        
    }
    
 // MARK: - AddCartBtn
    @IBAction func AddCartBtn_pressed(_ sender: Any) {
            if User.shared.isLogedIn() {
                
                if serviceDetails.data?.salon?.reservation_policy ?? "" == "" || serviceDetails.data?.salon?.reservation_policy  == nil {
                    if FromHome {
                        AddToCart(home: 1)
                    }else {
                        AddToCart(home: 0)
                    }
                   
                }else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReservationPolicyPopUpVC") as! ReservationPolicyPopUpVC
                          vc.modalPresentationStyle = .overCurrentContext
                          vc.delegate = self
                          vc.polictTxt = serviceDetails.data?.salon?.reservation_policy ?? ""
                          self.present(vc, animated: true, completion: nil)
                }
                }else {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
                    vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                    self.present(vc, animated: true, completion: nil)
                }
    }
    
    
}


// MARK: - CalendarDelegate
extension ReservationVC : FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        calendar.locale = NSLocale(localeIdentifier: "en") as Locale
        
        if date != calendar.today {
            calendar.today = .none
        }
        
        var note = ""
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            note = "Can't select previous date"
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar"{
            note = "الموعد غير متاح للحجز"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = dateFormatter.string(from: date)
       
        let t1 = dateFormatter.string(from: Date())
        let t2 = dateFormatter.date(from: t1)
        
        if date <  Date() && selectedDate != t1 {
            
            HUD.flash(.label(note) , onView: self.view , delay: 1.5 , completion: {
                (tmp) in
                HUD.show(.progress , onView: self.view)
                    self.times.removeAll()
                    self.TodayDateSelected = true
                    self.GetReservationData(ServiceID: self.ServiceID, date:  self.selectedDate)
            })
            self.selectedDate = dateFormatter.string(from: Date())
            calendar.select(Date(), scrollToDate: true)


        }else if selectedDate == t1 {
            self.selectedDate = selectedDate
            HUD.show(.progress , onView: self.view)
            self.times.removeAll()
            self.TodayDateSelected = true
            self.GetReservationData(ServiceID: self.ServiceID, date:  self.selectedDate)
            
        } else {
             self.selectedDate = selectedDate
             HUD.show(.progress , onView: self.view)
             self.times.removeAll()
             self.GetReservationData(ServiceID: self.ServiceID, date:  self.selectedDate)
        }
        
     
       

        
    }
    
}



extension ReservationVC  {
    
    // MARK: - ServiceData_API
    func GetReservationData(ServiceID:String, date:String) {
        var FinalURL = ""
        
        if User.shared.isLogedIn() {
              FinalURL = "\(ApiManager.Apis.ServiceDetials.description)service_id=\(ServiceID)&date=\(date)&user_hash_id=\(User.shared.TakeHashID())"
        }else {
              FinalURL = "\(ApiManager.Apis.ServiceDetials.description)service_id=\(ServiceID)&date=\(date)&user_hash_id=0"
        }
      
        
        ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: [ "Accept": "application/json",
        "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                HUD.hide()
                do {
                    self.serviceDetails = try JSONDecoder().decode(ServiceDetials.self, from: data!)
                    let service = self.serviceDetails.data?.service ?? Service()
                    let branch = service.branches?[self.SelectedBranchIndex] ?? SalonBranch()
                   
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    
                    var xx = dateFormatter.date(from:  branch.today_work_times?.from ?? "00:00")!
                    
                    if  branch.today_work_times?.from ?? "" != "" {
                        
                        if self.TodayDateSelected {
                            
                            while xx < dateFormatter.date(from: dateFormatter.string(from: Date()))! {
                                xx = dateFormatter.date(from: self.GetTimeSlot(startTime: dateFormatter.string(from: xx), duration: self.serviceDetails.data?.service?.service_duration ?? ""))!
                            }
                            self.TodayDateSelected = false
                            
                        }
                        
                        
                        self.SetUpTimes(startTime: dateFormatter.string(from: xx), endTime: branch.today_work_times?.to ?? "", duration: self.serviceDetails.data?.service?.service_duration ?? "", busyTime: branch.service_busy_times ?? [""])
                        
                    }
                    
                    
                    if !self.getBranches {
                        self.self.serviceDetails.data?.service?.branches?.forEach({ (branch) in
                            self.branchesNames.append(branch.branch_name ?? "")
                        })
                        self.getBranches = true
                    }
                    
                    self.SelectBranch.setTitle(branch.branch_name, for: .normal)
                    self.SelectedBranchID = "\(branch.id ?? Int())"
                    self.SetImage(image: self.SalonBackground, link: self.serviceDetails.data?.salon?.salon_background ?? "")
                    self.SetImage(image: self.SalonLogo, link: self.serviceDetails.data?.salon?.salon_logo ?? "")
                    self.SalonName.text = self.serviceDetails.data?.salon?.salon_name ?? ""
                    
                    self.SetImage(image: self.ServiceImage, link: service.image ?? "")
                    self.ServiceName.text = self.serviceDetails.data?.service?.service_name ?? ""
                    self.ServiceDescription.text = self.serviceDetails.data?.service?.service_description ?? ""

                     let currency = "\(self.serviceDetails.data?.service?.branches?[self.SelectedBranchIndex].currency?.currency_name ?? "")"
                    var finalString = ""
                    if self.FromHome {
                        finalString = "\(self.serviceDetails.data?.service?.branches?[self.SelectedBranchIndex].pivot?.home_price ?? "") \(currency)"
                    }else {
                        finalString = "\(self.serviceDetails.data?.service?.branches?[self.SelectedBranchIndex].pivot?.price ?? "") \(currency)"
                    }
                    
                       let amountText = NSMutableAttributedString.init(string: finalString)
                    amountText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 7, weight: .semibold),NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)], range: NSMakeRange(finalString.count-currency.count,currency.count))
                    
                    
                    self.ServicePrice.attributedText = amountText
                    
                    let amountText2 = NSMutableAttributedString.init(string: finalString)
                    amountText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 7, weight: .semibold),NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)], range: NSMakeRange(finalString.count-currency.count,currency.count))
                    
                    self.ServicePriceBottom.attributedText = amountText2
                    self.ServiceDuration.text = "\(self.serviceDetails.data?.service?.service_duration ?? "") mins"
                    
                    if self.times.count == 0 {
                        self.reservationTimesHeight.constant = 0
                        self.TimesNote.isHidden = true
                    }else {
                        self.reservationTimesHeight.constant = 250
                        self.TimesNote.isHidden = false
                        self.TimesView.setNeedsLayout()
                    }
                    
                    if branch.employees?.count == 0 {
                        self.ChooseSpecialistHeight.constant = 0
                    }
                    self.timesCollection.reloadData()
                    self.specialistsCollection.reloadData()
                    self.mainView.isHidden = true
                    self.mainView.isShimmering = false
                    
                    if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                        self.toArabic.ReverseCollectionDirection(collectionView: self.specialistsCollection)
                    }
                    
                    if self.ServiceDescription.isTruncated {
                        self.SalonViewDataHeight.constant = self.SalonViewDataHeight.constant + (self.ServiceDescription.TxtActualHeight - self.ServiceDescription.bounds.size.height)
                         self.SalonView_parentDataHieght.constant = self.SalonView_parentDataHieght.constant + (self.ServiceDescription.TxtActualHeight - self.ServiceDescription.bounds.size.height)
                    }
                    
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                      self.mainView.isHidden = true
                      self.mainView.isShimmering = false
                }
                
            }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                keyWindow?.rootViewController = vc
                
            }
        }
    }

    // MARK: - AddToCart_API
    func AddToCart(home:Int) {
          HUD.show(.progress , onView: view)
        
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.AddServiceToCart.description, method: .post, parameters: ["service_id":ServiceID , "branch_id":SelectedBranchID , "employee_id": SelectedemployeeID , "service_time":selectedTime , "service_date":selectedDate , "home_status": "\(home)"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())",
            "Accept": "application/json",
            "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
            ExtraParams: "", view: self.view) { (data, tmp) in
              if tmp == nil {
                  HUD.hide()
                do {
                    self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                    self.mainView.isHidden = true
                    self.mainView.isShimmering = false
                    self.AddedToCartPopUp(header: self.success.msg?[0] ?? "Added to Cart")
                    
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                    self.mainView.isHidden = true
                    self.mainView.isShimmering = false
                }
                
              }else if tmp == "401" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                keyWindow?.rootViewController = vc
                
                }

          }
      }

    // MARK: - SetupTimes
    func SetUpTimes(startTime:String , endTime:String , duration:String , busyTime:[String]) {
        
        if startTime == endTime {
            return
        }
        
        if !CheckBusyTime(times: busyTime, timeslot: startTime) {
            times.append(startTime)
        }
        
        var timeSlot = GetTimeSlot(startTime: startTime, duration: duration)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "'T'HH:mm"
        
        
        while timeSlot != endTime && Int(timeSlot.replacingOccurrences(of: ":", with: ""))! < Int(endTime.replacingOccurrences(of: ":", with: ""))! && (dateFormatter.date(from: "T\(timeSlot)"))! < dateFormatter.date(from: "T\(endTime)")!  {
            
            if !CheckBusyTime(times: busyTime, timeslot: timeSlot) {
                times.append(timeSlot)
            }
            let OldTimeSlot = timeSlot
            timeSlot = GetTimeSlot(startTime: timeSlot, duration: duration)
            
            if (Calendar.current.dateComponents([.minute], from: dateFormatter.date(from: "T\(OldTimeSlot)" )!, to: dateFormatter.date(from: "T\(timeSlot)")!).minute ?? 0) < Int(duration) ?? 0 {
                
                return
            }
            
            
            tmp1 = Int(timeSlot.replacingOccurrences(of: ":", with: ""))!
            tmp2 = Int(endTime.replacingOccurrences(of: ":", with: ""))!
            
        }

    
    }
    
    // MARK: - GetTimeSlot
    func GetTimeSlot(startTime:String, duration:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        let date = dateFormatter.date(from: "\(selectedDate)T\(startTime)")
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.year, .month , .hour, .minute], from: date!)
        
        let date2 = calendar.date(byAdding: .minute, value: Int(duration) ?? 0, to: date!)
        
        let comp2 = calendar.dateComponents([.year, .month , .hour, .minute], from: date2!)
        
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date2!)
    }
    
    
    func CheckBusyTime(times:[String], timeslot : String ) -> Bool {
         return times.contains(timeslot)
    }
    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
    }

    
    
}


// MARK: - CollectionViewDelegate
extension ReservationVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout  {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == specialistsCollection {
            return serviceDetails.data?.service?.branches?[SelectedBranchIndex].employees?.count ?? 0
        }
        
        if collectionView == timesCollection {
            return times.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == specialistsCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BestSpecialistCollCell", for: indexPath) as? BestSpecialistCollCell {
                cell.reservation = true
                cell.UpdateView(employee: serviceDetails.data?.service?.branches?[SelectedBranchIndex].employees?[indexPath.row] ?? Employee())
                
                return cell
            }
        }
        
        if collectionView == timesCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeCollCell", for: indexPath) as? TimeCollCell {
                
                cell.UpdateView(time: times[indexPath.row])
                
                return cell
            }
        }
        return ForYouCollCell()
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        if collectionView == specialistsCollection {
            let height:CGSize = CGSize(width: self.specialistsCollection.frame.width/4.6 , height: self.specialistsCollection.frame.height)
            
            return height
        }
        
        if collectionView == timesCollection {
            let height:CGSize = CGSize(width: self.timesCollection.frame.width/3 , height: self.timesCollection.frame.height/5)
            
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
        if collectionView == timesCollection {
            selectedTime = times[indexPath.row]
        }
        
        if collectionView == specialistsCollection {
            SelectedemployeeID = "\(serviceDetails.data?.service?.branches?[SelectedBranchIndex].employees?[indexPath.row].id ?? Int())"
        }
        
    }
    
}

// MARK: - ConfirmPressedDelegate
extension ReservationVC : ConfirmPressed {
    func ConfirmPressed_func() {
        if FromHome {
            AddToCart(home: 1)
        }else {
            AddToCart(home: 0)
        }
        
    }
    
    
    func AddedToCartPopUp(header:String) {
        var msg_1 = ""
        var msg_2 = ""
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            msg_1 = "Continue"; msg_2 = "Cart"
        }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar"  {
            msg_1 = "متابعة"; msg_2 = "السلة"
        }
        
        let alert = UIAlertController(title: "", message: header , preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: msg_1, style: .cancel, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: msg_2, style: .default, handler: { (_) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReservationNavController") as! ReservationNavController
            keyWindow?.rootViewController = vc
        }))
        
        self.present(alert, animated: false, completion: nil)
    }
    
    
    
}
