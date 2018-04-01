//
//  TicketDetailViewController.swift
//  Ryder
//
//  Created by Hannah Elarabawy on 3/31/18.
//  Copyright © 2018 Kevin Tan. All rights reserved.
//

import UIKit

class TicketDetailViewController: UIView {
    
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
    
    init(VehicleID: String) {
        logoImageView.image = UIImage(named: "metro_logo.png")
        transitTypeLabel.text = "Bus"
        transitNumberLabel.text = "31"
        starImageView.image = UIImage(named: "star.png")
        nextLabel.text = "NEXT STOP"
        nextLocationLabel.text = "42 St./ Sepulveda Blvd."
        directionLabel.text  = "EASTBOUND"
        mapView.image = UIImage(named: "maptest.png")
        
        topLine = UIView(frame: CGRect(x: 0, y: 42, width: 313, height: 3))
        bottomLine = UIView(frame: CGRect(x: 13, y: 48, width: 313, height: 2))

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
