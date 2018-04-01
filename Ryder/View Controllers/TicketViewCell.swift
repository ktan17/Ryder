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

    private func setNextStopText(_ text: String) {
        let attributedString = NSMutableAttributedString(string: text)
        
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        
        // *** set LineSpacing property in points ***
        paragraphStyle.lineHeightMultiple = 0.8 // Whatever line spacing you want in points
        
        // *** Apply attribute to string ***
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        // *** Set Attributed String to your label ***
        
        nextLocationLabel.text = nil
        nextLocationLabel.attributedText = attributedString;
    }
    
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
        setNextStopText(vehicle.nextStop)
        transitTypeLabel.text = vehicle.type
        directionLabel.text = vehicle.direction
        
        selectionStyle = .none
        backgroundColor = .clear
    }
    
}
