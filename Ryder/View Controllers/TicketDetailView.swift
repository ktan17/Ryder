//
//  TicketDetailViewController.swift
//  Ryder
//
//  Created by Hannah Elarabawy on 3/31/18.
//  Copyright © 2018 Kevin Tan. All rights reserved.
//

import UIKit
import FirebaseFirestore

class TicketDetailView: UIView {
    
    var logoImageView: UIImageView!
    var transitTypeLabel: UILabel!
    var transitNumberLabel: UILabel!
    var starImageView: UIImageView!
    var nextLabel: UILabel!
    var nextLocationLabel: UILabel!
    var directionLabel: UILabel!
    var mapView: UIImageView!
    
    var topLine: UIView!
    var bottomLine: UIView!
    
    /*init(vehicle: Vehicle) {
        if (vehicle.type == "Bus") {
            logoImageView.image = UIImage(named: "metro_logo.png")
            transitTypeLabel.text = "Bus"
            nextLabel.text = NextDest.nextBus
            topLine = UIView(frame: CGRect(x: 0, y: 42, width: 313, height: 3))
            bottomLine = UIView(frame: CGRect(x: 13, y: 48, width: 313, height: 2))
        } else if (vehicle.type == "Train") {
            logoImageView.image = UIImage(named: "amtrak_logo.png")
            transitTypeLabel.text = "Train"
            nextLabel.text = NextDest.nextTrain
        }
        transitNumberLabel.text = vehicle.id
        starImageView.image = UIImage(named: "star.png")
        nextLocationLabel.text = vehicle.nextStop
        
        // TODO
        directionLabel.text  = "EASTBOUND"
        mapView.image = UIImage(named: "maptest.png")
        
        if (vehicle.isStarred) {
            self.addSubview(starImageView)
        }
        
    }*/
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
