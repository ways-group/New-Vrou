//
//  HistoryReservationsVC.swift
//  Vrou
//
//  Created by Mac on 11/7/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import PKHUD
import Alamofire
import SwiftyJSON

class HistoryReservationsVC: UIViewController {
    
    @IBOutlet weak var noOfferImage: UIImageView!
    @IBOutlet weak var ReservationsTable: UITableView!
    @IBOutlet weak var EmptyCartView: UIView!
    
    var myReservations = MyReservations()
    var request = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ReservationsTable.delegate = self
        ReservationsTable.dataSource = self
        ReservationsTable.separatorStyle = .none
        let offerImage = UIImage.gifImageWithName("Animation - 1733825557396")
        noOfferImage.image = offerImage
    }
    
    
    
}

extension HistoryReservationsVC:  UITableViewDelegate , UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if myReservations.data?.reservations?.count ?? 0 == 0 && request {
            EmptyCartView.isHidden = false // To be updated
        }
        
        return myReservations.data?.reservations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ReservationCartTableCell", for: indexPath) as? ReservationCartTableCell {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.UpdateView(reservation: myReservations.data?.reservations?[indexPath.row] ?? Reservation() , histoty: true)
            
            return cell
        }
        
        return ReservationCartTableCell()
    }
}

