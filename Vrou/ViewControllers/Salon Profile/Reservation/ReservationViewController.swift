//
//  ReservationViewController.swift
//  Vrou
//
//  Created by Esraa Masuad on 5/11/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import PKHUD
import MXParallaxHeader


protocol UpdateSelectedServiceIDs {
    func sendServicesIDs(list: [Int])
}
class ReservationViewController: UIViewController, UpdateSelectedServiceIDs {
   
    func sendServicesIDs(list: [Int]) {
        selectedServicesIdsList = list
        //FROM_ServiceSelection = true
        GetReservationData(salonID: salonID, ServiceID: ServiceID, date:selectedDate)
    }

    @IBOutlet weak var SalonBackground: UIImageView!
    @IBOutlet weak var SalonLogo: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var SalonCategory_lbl: UILabel!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var branchesCollectionView: UICollectionView!
    @IBOutlet weak var timeCollectionView: UICollectionView!
    @IBOutlet weak var SpecialistCollectionView: UICollectionView!

    @IBOutlet weak var tableView: UITableView!{
        didSet{
            self.tableView.register(UINib(nibName: String(describing: ReservationTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ReservationTableViewCell.self))
        }
    }
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var salonHeaderView: UIView!
    
    // Footer IBOutlets
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var currencyLbl: UILabel!
    
    // Variables
    var salonID = "45"
    var ServiceID = "28"
    var selectedDate = ""
    var selectedTime = ""
    var SelectedEmployeeID = Int()
    var SelectedBranchID = 0
    var serviceDetails: ServiceDetialsData? = ServiceDetialsData()
    var branches: [SalonBranch]?
    var selectedServicesList : [Service]?
    var selectedServicesIdsList : [Int] = []
    var salon : Salon?
    var service : Service?
    var employees: [Employee]?
    var workTimeDetailsModel: WorkTimeDetailsModel?
    var selectedBranch: SalonBranch?
    
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
    
    var specialistCellIdentifier = "ServicesCollCell"
    var timeCellIdentifier =  "ServiceTimeCollectionViewCell"
    var branchesCellIdentifier = "ServiceBranchesCollectionViewCell"
    var items:[(Int, String)] = [(0,"")]
    var FROM_ServiceSelection = false
//        = [(0,""), (1, "Select Branch"),
//                                 (2, "Reservation date"),
//                                 (3, "Reservation time"),
//                                 (4, "Choose a specialist")]
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setTransparentNavagtionBar()
        SetupHeaderView()
        
        //get current date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = NSLocale(localeIdentifier: "en") as Locale
        selectedDate = dateFormatter.string(from: Date())
        selectedServicesIdsList = [Int(ServiceID)!]
        GetReservationData(salonID: salonID, ServiceID: ServiceID, date:selectedDate)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func SetupHeaderView()  {
        tableView.parallaxHeader.view = headerView
        tableView.parallaxHeader.height = 380
        tableView.parallaxHeader.minimumHeight = 200
        tableView.parallaxHeader.mode = .fill
        headerView.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        salonHeaderView.layer.cornerRadius = 20
        salonHeaderView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    func setAllItems(){
        if selectedServicesList?.count ?? 0 > 0 {
            items = [(0,""), (1, "Select Branch".ar()),
                     (2, "Reservation date".ar()),
                     (3, "Reservation time".ar())]
            if serviceDetails?.specialists?.count ?? 0 > 0 {
                items.append((4, "Choose a specialist".ar()))
            }
        }else {
            items = [(0,"")]
        }
    }
    
    func FormatDate(date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
   
    
    
    @IBAction func X_BtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func SideMenuBtnPressed(_ sender: Any) {
         Vrou.openSideMenu(vc: self)
    }
    
    
}

//MARK: -
extension ReservationViewController {
    
    
    @IBAction func openServicesList_pressed(_ sender: UIButton) {
        let vc = UIStoryboard(name: "SalonProfile", bundle: nil).instantiateViewController(withIdentifier: "SelectServiceVC") as! SelectServiceVC
        vc.delegate = self
        vc.salon = salon
        vc.allSelectedServicesList = selectedServicesList ?? []
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //SalonLogoBtn
       @IBAction func SalonLogoBtn_pressed(_ sender: Any) {
           if !FromSalonVC {
               NavigationUtils.goToSalonProfile(from: self, salon_id: salon?.id ?? 0)
           }
       }
       
     
    //AddCartBtn
    @IBAction func AddCartBtn_pressed(_ sender: Any) {
        if User.shared.isLogedIn() {

            //let police = salon?.reservation_policy ?? ""
//            if  police == "" && selectedTime != ""{
//                if FromHome {
//                    AddToCart(home: 1)
//                }else {
//                    AddToCart(home: 0)
//                }
//            }
            
             if selectedTime == "" {
                HUD.flash(.label("Please select reservation time!".ar()) , onView: self.view , delay: 1.6 , completion: nil)
             }
            else {
                let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "ReservationPolicyPopUpVC") as! ReservationPolicyPopUpVC
                vc.modalPresentationStyle = .overCurrentContext
                vc.delegate = self
                vc.polictTxt = salon?.reservation_policy ?? ""
                self.present(vc, animated: true, completion: nil)
            }
        }else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginRequiredNavController") as! LoginRequiredNavController
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        }
    }
    
}


//MARK: - TableView [Selected Services, Branches, Date, Time, Specialist]
extension ReservationViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? (selectedServicesList?.count ?? 0) + 1 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //titles
        if (indexPath.row == 0) && (items[indexPath.section].0 ==  indexPath.section) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
            let title = cell.viewWithTag(1) as! UILabel
            title.text = items[indexPath.section].1
            return cell
        }
        
        //contect
        switch items[indexPath.section].0 {
        case 0:
             let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReservationTableViewCell.self), for: indexPath) as! ReservationTableViewCell
             cell.configure(service: selectedServicesList?[indexPath.row - 1])
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "calenderCell", for: indexPath)
            let calendar = cell.viewWithTag(1) as! FSCalendar
            calendarHeightConstraint = calendar.constraints[0]
            calendar.delegate = self
            calendar.allowsMultipleSelection = false
            calendar.scope = .week
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "collectionViewcell", for: indexPath)
            let collectionView = cell.viewWithTag(1) as! UICollectionView
            branchesCollectionView = collectionView
            branchesCollectionView.register(UINib(nibName: branchesCellIdentifier, bundle: nil), forCellWithReuseIdentifier: branchesCellIdentifier)
            collectionView.delegate = self
            collectionView.dataSource = self
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "collectionViewcell", for: indexPath)
            let collectionView = cell.viewWithTag(1) as! UICollectionView
            if timeCollectionView == nil {
            timeCollectionView = collectionView
            timeCollectionView.register(UINib(nibName: timeCellIdentifier, bundle: nil), forCellWithReuseIdentifier: timeCellIdentifier)
            collectionView.delegate = self
            collectionView.dataSource = self
            }
            collectionView.reloadData()
           
            return cell
        default://4
            let cell = tableView.dequeueReusableCell(withIdentifier: "collectionViewcell", for: indexPath)
            let collectionView = cell.viewWithTag(1) as! UICollectionView
            SpecialistCollectionView = collectionView
            SpecialistCollectionView.register(UINib(nibName: specialistCellIdentifier, bundle: nil), forCellWithReuseIdentifier: specialistCellIdentifier)
            SpecialistCollectionView.delegate = self
            SpecialistCollectionView.dataSource = self
            SpecialistCollectionView.reloadData()
            return cell
        }
       
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch (indexPath.section, indexPath.row){
        case (0, let row): //selected service
            return row == 0 ? 0 : 120
        case (1, _)://selected branch
            return  35
        case (2, let row): //calender
            return row == 0 ? 40 : 120
        case (3, let row): //selected time
            return row == 0 ? 40 : 60
        case (4, let row): //specialist
            return row == 0 ? 40 : 130
        default:
            return 0
        }
    }

    
    
}


 //MARK: - CollectionView [Salon Branches, Times, Specialists]
extension ReservationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case branchesCollectionView:
            return branches?.count ?? 0
        case timeCollectionView:
            return times.count
        case SpecialistCollectionView:
            return employees?.count ?? 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
        case branchesCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: branchesCellIdentifier, for: indexPath) as! ServiceBranchesCollectionViewCell
            
            let item = branches?[indexPath.row]
            cell.branchName_lbl.text = item?.branch_name ?? ""
            cell.isSelected = (item?.id == SelectedBranchID) ? true : false
            return cell
            
        case timeCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: timeCellIdentifier, for: indexPath) as! ServiceTimeCollectionViewCell
            cell.time_lbl.text = times[indexPath.row]
            return cell
        default: //14
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: specialistCellIdentifier, for: indexPath) as! ServicesCollCell
            cell.setSpecialist(item: employees?[indexPath.row] ?? Employee())
            return cell 
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        switch collectionView {
        case branchesCollectionView:
            return CGSize(width: 100, height: 35)
        case timeCollectionView:
            return CGSize(width: 55, height: 55)
        case SpecialistCollectionView:
            return CGSize(width: 100, height: 130)
        default:
            return CGSize(width: 150, height: 200)
        }
     }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { return 0 }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { return 0 }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView {
        case branchesCollectionView:
            self.selectedBranch = branches?[indexPath.row]
            self.SelectedBranchID = branches?[indexPath.row].id ?? 0
//            self.times.removeAll()
//            self.GetReservationData(salonID: salonID, ServiceID: self.ServiceID, date: self.FormatDate(date: Date()))
        case SpecialistCollectionView:
            self.SelectedEmployeeID = employees?[indexPath.row].id ?? Int()
            
        case timeCollectionView:
            selectedTime = times[indexPath.row]
            
        default:
            print("none selected")
        }
    }
    
}
