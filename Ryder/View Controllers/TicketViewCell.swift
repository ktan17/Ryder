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
    
    @IBOutlet var topLine: UIView!
    @IBOutlet var bottomLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let attributedString = NSMutableAttributedString(string: "42 St. / Sepulveda Blvd.")
        
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
    
}
