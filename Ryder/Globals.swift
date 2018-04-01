//
//  Globals.swift
//  Ryder
//
//  Created by Kevin Tan on 3/31/18.
//  Copyright © 2018 Kevin Tan. All rights reserved.
//

import UIKit

struct APIKEYS {
    static let GIMBALKEY = "d5474e81-c991-4802-80f3-9d215419bb95"
}

let Charcoal = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1)

struct NextDest {
    static let nextBus = "NEXT STOP"
    static let nextTrain = "NEXT STATION"
}

func setLineSpacing(_ label: UILabel, text: String, lineHeightMultiple: CGFloat) {
    let attributedString = NSMutableAttributedString(string: text)
    
    // *** Create instance of `NSMutableParagraphStyle`
    let paragraphStyle = NSMutableParagraphStyle()
    
    // *** set LineSpacing property in points ***
    paragraphStyle.lineHeightMultiple = lineHeightMultiple // Whatever line spacing you want in points
    
    // *** Apply attribute to string ***
    attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
    
    // *** Set Attributed String to your label ***
    label.text = nil
    label.attributedText = attributedString;
}

func getStringFromDirection(_ direction: String) -> String? {
    switch direction {
    case "N":
        return "NORTHBOUND"
    case "S":
        return "SOUTHBOUND"
    case "E":
        return "EASTBOUND"
    case "W":
        return "WESTBOUND"
    default:
        return nil
    }
}
