//
//  ReservationExtension.swift
//  Vrou
//
//  Created by Esraa Masuad on 5/13/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import PKHUD
import Alamofire
import FSCalendar

//Calculate Time
extension ReservationViewController {
    
    
}

//MARK: - Calender
extension ReservationViewController : FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        calendar.locale = NSLocale(localeIdentifier: UserDefaults.standard.string(forKey: "Language") ?? "en") as Locale
        
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
        dateFormatter.locale = NSLocale(localeIdentifier: "en") as Locale
        let selectedDate = dateFormatter.string(from: date)
       
        let t1 = dateFormatter.string(from: Date())
        let t2 = dateFormatter.date(from: t1)
        
        if date <  Date() && selectedDate != t1 {
            
            HUD.flash(.label(note) , onView: self.view , delay: 1.5 , completion: {
                (tmp) in
                HUD.show(.progress , onView: self.view)
                    self.times.removeAll()
                    self.TodayDateSelected = true
                self.GetReservationData(salonID: self.salonID, ServiceID: self.ServiceID, date:  self.selectedDate)
            })
            self.selectedDate = dateFormatter.string(from: Date())
            calendar.select(Date(), scrollToDate: true)


        }else if selectedDate == t1 {
            self.selectedDate = selectedDate
            HUD.show(.progress , onView: self.view)
            self.times.removeAll()
            self.TodayDateSelected = true
            self.GetReservationData(salonID: self.salonID, ServiceID: self.ServiceID, date:  self.selectedDate)
            
        } else {
             self.selectedDate = selectedDate
             HUD.show(.progress , onView: self.view)
             self.times.removeAll()
            self.GetReservationData(salonID: self.salonID, ServiceID: self.ServiceID, date:  self.selectedDate)
        }
        
     
       

        
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
}


//Api
extension ReservationViewController {

    func GetReservationData(salonID: String, ServiceID:String, date:String) {
        HUD.show(.progress , onView: self.view)
        let user_hash_id = User.shared.isLogedIn() ? User.shared.TakeHashID() : "0"
        var FinalURL =  "\(ApiManager.Apis.ReservationDetails.description)salon_id=\(salonID)&user_hash_id=\(user_hash_id)&date=\(date)&"
        
        for item in selectedServicesIdsList {
            FinalURL += "services_id[]=\(item)&"
        }
        FinalURL.remove(at: FinalURL.index(before: FinalURL.endIndex))
        
        ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: [ "Accept": "application/json",
        "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                HUD.hide()
                do {
                    let decoded_data = try JSONDecoder().decode(ServiceDetials.self, from: data!)
                    self.serviceDetails = decoded_data.data
                    self.selectedServicesList = self.serviceDetails?.services
                    self.salon = self.serviceDetails?.salon
                    self.employees = self.serviceDetails?.specialists
                    self.branches = self.serviceDetails?.branches
                    self.setData()

                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {}
        }
    }
    
    //Update Time When Select Branch or Date
    func updateTimeRequest() {
        let FinalURL =  "\(ApiManager.Apis.branchAvailableTime.description)branch_id=\(SelectedBranchID)&date=\(selectedDate)"
        
        ///salon/branch-available-time?branch_id=61&date=2020-05-14
        ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header: [ "Accept": "application/json",
        "locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                HUD.hide()
                do {
                    let decoded_data = try JSONDecoder().decode(BranchAvailableTimeGeneralModel.self, from: data!)
                    let availableTime = decoded_data.data?.branch_available_time?.work_times
                    if (availableTime?.count ?? 0) >= 1 {
                        self.workTimeDetailsModel = availableTime?[0]
                        self.setAvailableTime()
                    }
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
            }else if tmp == "401" {}
        }
    }
    
    func setData(){
        //set header data
        SetImage(image: SalonLogo, link: salon?.salon_logo ?? "")
        SetImage(image: SalonBackground, link: salon?.salon_background ?? "")
        SalonName.text = salon?.salon_name ?? ""
        SalonCategory_lbl.text = salon?.category?.category_name ?? ""
        
        self.setAllItems() //reset items
        
        if ((self.branches?.count ?? 0) >= 1) {
            self.SelectedBranchID = self.branches?[0].id ?? 0
        }
        self.tableView.reloadData()
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            //self.toArabic.ReverseCollectionDirection(collectionView: self.specialistsCollection)
        }
        
//        if !FROM_ServiceSelection {
//            updateTimeRequest()
//        }else {
//            FROM_ServiceSelection = false
//        }
        
        updateTimeRequest()
        SetFooterPriceData()
    }
    
    
    func SetFooterPriceData() {
        if selectedServicesList?.count ?? 0 > 0 {
            var TotalPrice = Float()
            selectedServicesList?.forEach({ (service) in
                TotalPrice += (service.service_price! as NSString).floatValue
            })
            currencyLbl.text = selectedServicesList?[0].currency ?? ""
            priceLbl.text = "\(TotalPrice)"
        }else {
            (currencyLbl.text , priceLbl.text) = ("","")
        }
    }
    
    // MARK: - AddToCart_API
    func AddToCart(home:Int) {
          HUD.show(.progress , onView: view)
        
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.AddServiceToCart.description, method: .post, parameters: ["service_id":ServiceID , "branch_id":SelectedBranchID , "employee_id": "\(SelectedEmployeeID)" , "service_time":selectedTime , "service_date":selectedDate , "home_status": "\(home)"], encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())",
            "Accept": "application/json",
            "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
            ExtraParams: "", view: self.view) { (data, tmp) in
              if tmp == nil {
                  HUD.hide()
                do {
                    self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                    self.AddedToCartPopUp(header: self.success.msg?[0] ?? "Added to Cart")
                    
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
              }
          }
      }
    
    // MARK: - AddMultiServicesToCart_API
    func AddMultiServicesToCart() {
          HUD.show(.progress , onView: view)
        var params = ["branch_id": "\(SelectedBranchID)" , "employee_id": "\(SelectedEmployeeID)" , "service_time":selectedTime , "service_date":selectedDate]
        
        for (index, item) in selectedServicesList!.enumerated(){
            params["services_id[\(index)]"] = "\(item.id ?? Int())"
        }
        
        ApiManager.shared.ApiRequest(URL: ApiManager.Apis.AddMultiServiceToCart.description, method: .post, parameters: params , encoding: URLEncoding.default, Header: [ "Authorization": "Bearer \(User.shared.TakeToken())",
            "Accept": "application/json",
            "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ],
            ExtraParams: "", view: self.view) { (data, tmp) in
              if tmp == nil {
                  HUD.hide()
                do {
                    self.success = try JSONDecoder().decode(ErrorMsg.self, from: data!)
                    self.AddedToCartPopUp(header: self.success.msg?[0] ?? "Added to Cart")
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
              }
          }
      }

    func setAvailableTime(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = NSLocale(localeIdentifier: "en") as Locale
        
        var xx = dateFormatter.date(from:  workTimeDetailsModel?.from ?? "00:00")!
        
        if  workTimeDetailsModel?.from ?? "" != "" {
        
        if self.TodayDateSelected {
        while xx < dateFormatter.date(from: dateFormatter.string(from: Date()))! {
        xx = dateFormatter.date(from: self.GetTimeSlot(startTime: dateFormatter.string(from: xx), duration: "60"))!
        }
        self.TodayDateSelected = false
        }
        self.SetUpTimes(startTime: dateFormatter.string(from: xx), endTime: workTimeDetailsModel?.to ?? "", duration:  "60", busyTime: [""])
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
        dateFormatter.locale = NSLocale(localeIdentifier: "en") as Locale
        
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
        print("times => \(times)")
        self.tableView.reloadData()
    
    }
    
    // MARK: - GetTimeSlot
    func GetTimeSlot(startTime:String, duration:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        dateFormatter.locale = NSLocale(localeIdentifier: "en") as Locale
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

// MARK: - ConfirmPressedDelegate
extension ReservationViewController : ConfirmPressed {
    
    func ConfirmPressed_func() {
       // FromHome ? AddToCart(home: 1) : AddToCart(home: 0)
        AddMultiServicesToCart()
    }
    
    func AddedToCartPopUp(header:String) {

        let msg_1 = "Continue".ar()
        let msg_2 = "Cart".ar()
        
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



