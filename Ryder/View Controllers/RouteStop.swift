//
//  RouteStop.swift
//  Ryder
//
//  Created by Hannah Elarabawy on 3/31/18.
//  Copyright © 2018 Kevin Tan. All rights reserved.
//

import UIKit

class RouteStop: UIView {
    
    private let viewWidth: CGFloat = 320
    private let padding: CGFloat = 18
    private let dotDiameter: CGFloat = 22
    private let lineWidth: CGFloat = 4
    
    var stopLabel: UILabel!
    var timeLabel: UILabel!
    var dotView: UIView!
    var lineView: UIView!
    
    init(origin: CGPoint, stopLabel: String, timeLabel: String) {
        
        // initiate frame
        self.stopLabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewWidth * 2/3, height: 30))
        self.stopLabel.numberOfLines = 0
        
        // setting font
        self.stopLabel.font = UIFont(name: "Poppins-Medium", size: 16.0)
        self.stopLabel.textColor = .white
        
        // stop label
        self.stopLabel.text = stopLabel
        self.stopLabel.sizeToFit()
        
        // set frame
        super.init(frame: CGRect(x: origin.x, y: origin.y, width: self.viewWidth, height: self.stopLabel.frame.height + padding*2))
        
        self.stopLabel.center.y = self.frame.height / 2
        
        // dot + line construction
        self.dotView = UIView(frame: CGRect(x: viewWidth*2/3, y: origin.y, width: dotDiameter, height: dotDiameter))
        self.dotView.clipsToBounds = true
        self.dotView.layer.cornerRadius = dotDiameter/2
        self.lineView = UIView(frame: CGRect(x: viewWidth*2/3, y: origin.y, width: lineWidth, height: self.frame.height))
        
        // time label
        self.timeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 23))
        self.timeLabel.text = timeLabel
        self.timeLabel.font =  UIFont(name: "Poppins-Medium", size: 16.0)
        self.timeLabel.textColor = Charcoal
        self.timeLabel.sizeToFit()
        self.timeLabel.frame = CGRect(x: viewWidth - self.timeLabel.frame.width, y: self.frame.height / 2 - self.timeLabel.frame.height / 2, width: self.timeLabel.frame.width, height: self.timeLabel.frame.height)
        self.timeLabel.center.y = self.frame.height / 2
        
        self.addSubview(self.stopLabel)
        self.addSubview(dotView)
        self.addSubview(lineView)
        self.addSubview(self.timeLabel)

    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
