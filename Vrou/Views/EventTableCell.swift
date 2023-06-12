//
//  EventTableCell.swift
//  Vrou
//
//  Created by Mac on 1/12/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

class EventTableCell: UITableViewCell {

    
    @IBOutlet weak var EventName: UILabel!
    @IBOutlet weak var EventDescription: UILabel!
    @IBOutlet weak var EventDetails: UILabel!
    @IBOutlet weak var OffersCountLbl: UILabel!
    
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var eventStatus: UILabel!
    
    @IBOutlet weak var offersLbl: UILabel!
    @IBOutlet weak var arrowLbl: UILabel!
    
    let toArabic = ToArabic()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func UpdateView(event:EventModel) {
        EventName.text = event.event_name ?? ""
        EventDescription.text = event.event_description ?? ""
        
        var eventDetials = NSLocalizedString("I need ", comment: "")
        var f_loop = false
        event.services?.forEach({ (service) in
            if f_loop {
                 eventDetials += ", " + (service.service_category ?? "")
            }else {
                 eventDetials += (service.service_category ?? "")
                f_loop = true
            }
           
        })
        
        EventDetails.text = eventDetials
        OffersCountLbl.text = "\(event.salons_offers_count ?? 0)"
        locationLbl.text = event.area?.area_name ?? ""
        DateLbl.text = event.event_date ?? ""
        TimeLbl.text = event.event_time ?? ""
        eventStatus.text = event.event_status ?? ""
        
        Localizations()
    }
    
    
    func Localizations() {
        offersLbl.text =  NSLocalizedString("Offers", comment: "")
        arrowLbl.text = NSLocalizedString(">", comment: "")
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            toArabic.ReverseLabelAlignment(label: locationLbl)
            toArabic.ReverseLabelAlignment(label: DateLbl)
            toArabic.ReverseLabelAlignment(label: TimeLbl)
        }
    }
    
    

}
