//
//  TicketViewCell.swift
//  Ryder
//
//  Created by Dustin Newman on 3/31/18.
//  Copyright © 2018 Kevin Tan. All rights reserved.
//

import UIKit

class TicketViewCell: UITableViewCell {
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var transitTypeLabel: UILabel!
    @IBOutlet var transitNumberLabel: UILabel!
    @IBOutlet var starImageView: UIImageView!
    @IBOutlet var nextLabel: UILabel!
    @IBOutlet var nextLocationLabel: UILabel!
    @IBOutlet var directionLabel: UILabel!
    
    @IBOutlet var topLine: UIView!
    @IBOutlet var bottomLine: UIView!
    
    func configure(using vehicle: Vehicle) {
        if vehicle.type == "Bus" {
            backgroundImageView.image = UIImage(named: "ticket_bus_metro")
            if let constraint = logoImageView.constraints.first(where: { $0.identifier == "widthConstraint" }) {
                constraint.constant = 34
            }
            logoImageView.image = UIImage(named: "metro_logo")
            transitTypeLabel.textColor = Charcoal
            nextLabel.text = NextDest.nextBus
            
            topLine.isHidden = false
            bottomLine.isHidden = false
        }
            
        else if vehicle.type == "Train" {
            backgroundImageView.image = UIImage(named: "blueticket")
            if let constraint = logoImageView.constraints.first(where: { $0.identifier == "widthConstraint" }) {
                constraint.constant = 50
            }
            logoImageView.image = UIImage(named: "amtrak_logo")
            transitTypeLabel.textColor = .white
            nextLabel.text = NextDest.nextTrain
            
            topLine.isHidden = true
            bottomLine.isHidden = true
        }
        setLineSpacing(nextLocationLabel, text: vehicle.nextStop, lineHeightMultiple: 0.8)
        transitNumberLabel.text = vehicle.routeNumber
        transitTypeLabel.text = vehicle.type
        directionLabel.text = vehicle.direction
        
        if let subscription = subscriptions.first(where: { $0.shortName == vehicle.routeNumber && $0.direction == String(vehicle.direction.first!) }) {
            starImageView.isHidden = !subscription.isStarred
            vehicle.isStarred = subscription.isStarred
        } else {
            starImageView.isHidden = true
        }
        
        selectionStyle = .none
        backgroundColor = .clear
    }
    
}
