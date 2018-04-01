//
//  TicketDetailView.swift
//  Ryder
//
//  Created by Hannah Elarabawy on 3/31/18.
//  Copyright © 2018 Kevin Tan. All rights reserved.
//

import UIKit
import FirebaseFirestore

class TicketDetailView: UIScrollView {
    
    var m_vehicle: Vehicle!
    var logoImageView: UIImageView!
    var transitTypeLabel: UILabel!
    var numberLabel: UILabel!
    var transitNumberLabel: UILabel!
    var starImageView: UIImageView!
    var starButton: UIButton!
    var nextLabel: UILabel!
    var nextLocationLabel: UILabel!
    var directionLabel: UILabel!
    var mapView: UIImageView!
    
    var routeArray = [RouteStop]()
    
    var topLine: UIView!
    var bottomLine: UIView!
    
    let padding: CGFloat = 20
    
//    init(vehicle: Vehicle, allStops: [Vehicle.RouteStopData], parent: UIViewController) {
    init(vehicle: Vehicle, parent: UIView) {
        self.m_vehicle = vehicle
        let statusBar = UIApplication.shared.statusBarFrame
        
        super.init(frame: CGRect(x: padding, y: statusBar.height + padding/2, width: parent.frame.width - 2 * padding, height: parent.frame.height - 2 * padding))
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        self.layer.backgroundColor = UIColor(red: 1.0, green: 130/255, blue: 72/255, alpha: 1.0).cgColor
        
        let mapPadding: CGFloat = 8
        let mapWidth: CGFloat = self.frame.width - 2*mapPadding
        
        logoImageView = UIImageView(frame: CGRect(x: 18, y: 10, width: 34, height: 34))
        self.addSubview(logoImageView)
        transitTypeLabel = UILabel(frame: CGRect(x: logoImageView.frame.maxX + 9, y: mapPadding, width: 60, height: 29))
        nextLabel = UILabel(frame: CGRect(x: logoImageView.frame.minX, y: 0, width: 72, height: 20))
        numberLabel = UILabel(frame: CGRect(x: mapWidth, y: 0, width: 32, height: 26))
        nextLocationLabel = UILabel(frame: CGRect.zero)
        directionLabel = UILabel(frame: CGRect.zero)
        
        if (vehicle.type == "Bus") {
            print("entered")
            logoImageView.image = UIImage(named: "metro_logo.png")
            transitTypeLabel.text = "Bus"
            transitTypeLabel.textColor = Charcoal
            nextLabel.text = NextDest.nextBus
            //lines
            topLine = UIView(frame: CGRect(x: 0, y: 42 + mapPadding, width: 313, height: 3))
            bottomLine = UIView(frame: CGRect(x: 13, y: 48 + mapPadding, width: 313, height: 2))
            topLine.layer.backgroundColor = Charcoal.cgColor
            bottomLine.layer.backgroundColor = Charcoal.cgColor
            self.addSubview(topLine)
            self.addSubview(bottomLine)
        } else if (vehicle.type == "Train") {
            logoImageView.image = UIImage(named: "amtrak_logo.png")
            transitTypeLabel.text = "Train"
            transitTypeLabel.textColor = .white
            nextLabel.text = NextDest.nextTrain
        }
        
        nextLabel.font = UIFont(name: "Poppins-Medium", size: 14.0)
        nextLabel.textColor = .white
        // transit number label
        transitTypeLabel.font = UIFont(name: "Poppins-BoldItalic", size: 32.0)
        transitTypeLabel.sizeToFit()
        transitTypeLabel.center.y = logoImageView.center.y
        self.addSubview(transitTypeLabel)
        
        transitNumberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 31, height: 26))
        transitNumberLabel.text = vehicle.routeNumber
        transitNumberLabel.font = UIFont(name: "Poppins-Bold", size: 32.0)
        transitNumberLabel.textColor = .white
        transitNumberLabel.sizeToFit()
        transitNumberLabel.frame = CGRect(x: self.frame.width - transitNumberLabel.frame.width - 19, y: transitTypeLabel.frame.minY, width: transitNumberLabel.frame.width, height: transitNumberLabel.frame.height)
        transitNumberLabel.center.y = transitTypeLabel.center.y
        self.addSubview(transitNumberLabel)
        
        // number label
        numberLabel.text = "№"
        numberLabel.font = UIFont(name: "Poppins-Bold", size: 32.0)
        numberLabel.textColor = .white
        numberLabel.sizeToFit()
        numberLabel.frame = CGRect(x: transitNumberLabel.frame.minX - 4 - numberLabel.frame.width, y: 0, width: numberLabel.frame.width, height: numberLabel.frame.height)
        numberLabel.center.y = transitNumberLabel.center.y
        self.addSubview(numberLabel)
        
        //next stop
        nextLabel.frame = CGRect(x: logoImageView.frame.minX, y: logoImageView.frame.maxY + 34.0, width: 72.0, height: 20)
        nextLabel.sizeToFit()
        self.addSubview(nextLabel)
        
        // destination
        nextLocationLabel.frame = CGRect(x: nextLabel.frame.minX, y: nextLabel.frame.maxY + 5, width: mapWidth, height: 90.0)
        setLineSpacing(nextLocationLabel, text: vehicle.nextStop, lineHeightMultiple: 0.8)
        nextLocationLabel.font = UIFont(name: "Poppins-Medium", size: 32.0)
        nextLocationLabel.textColor = .white
        nextLocationLabel.numberOfLines = 2
        nextLocationLabel.sizeToFit()
        self.addSubview(nextLocationLabel)
        
        starButton = UIButton(frame: CGRect(x: mapWidth - 28.0, y: 0, width: 28, height: 28))
        
        // direction label
        directionLabel.text = "EASTBOUND"
        directionLabel.font = UIFont(name: "Poppins-Light", size: 24.0)
        directionLabel.textColor = .white
        directionLabel.sizeToFit()
        directionLabel.frame = CGRect(x: nextLocationLabel.frame.minX, y: nextLocationLabel.frame.maxY + 5, width: directionLabel.frame.width, height: directionLabel.frame.height)
        self.addSubview(directionLabel)
        
        // map view
        mapView = UIImageView(image: UIImage(named: "maptest.png"))
        mapView.frame = CGRect(x: mapPadding, y: directionLabel.frame.maxY + 20, width: mapWidth, height: mapWidth)
        mapView.layer.cornerRadius = 10
        mapView.clipsToBounds = true
        self.addSubview(mapView)
        
        // star button
        starButton = UIButton(frame: CGRect(x: mapView.frame.maxX - 28, y: 0, width: 28, height: 28))
        starButton.setImage(UIImage(named: "hollow_star.png"), for: .normal)
        starButton.center.y = directionLabel.center.y
        self.addSubview(starButton)
        starButton.addTarget(self, action: #selector(clickStar), for: .touchUpInside)
        
        if (vehicle.isStarred) {
            self.addSubview(starImageView)
        }
        
//        allStops = [
//            Vehicle.RouteStopData
//        ]
//        
        // route stops
        // FOR TEST
        
        let width = self.frame.width - 2*mapPadding
        var origin: CGPoint = CGPoint(x: mapPadding, y: mapView.frame.maxY + 22)
        for stop in vehicle.routeStops {
            let rs = RouteStop(origin: origin, stopLabel: stop.name, timeLabel: secToTime(stop.time), viewWidth: width)
            self.addSubview(rs)
            origin.y += rs.frame.height
        }
        
        self.contentSize = CGSize(width: self.frame.width, height: origin.y + 20)
        
        /*
        let rs1 = RouteStop(origin: CGPoint.init(x: mapPadding, y: mapView.frame.maxY + 22), stopLabel: "Westwood SB & Lindbrook NS", timeLabel: "1:36 PM", viewWidth: width)
        self.addSubview(rs1)
        
        let rs2 = RouteStop(origin: CGPoint.init(x: mapPadding, y: rs1.frame.maxY), stopLabel: "Wilshire/Federal", timeLabel: "12:02 AM", viewWidth: width)
        self.addSubview(rs2)
        
        let rs3 = RouteStop(origin: CGPoint.init(x: mapPadding, y: rs2.frame.maxY), stopLabel: "Westwood SB & Lindbrook NS", timeLabel: "5:54 AM", viewWidth: width)
        self.addSubview(rs3)
        
        //allStops[0].
        // actual loop
//        for route in routeArray {
//            let rs = RouteStop(origin: CGPoint, stopLabel: route.stop, timeLabel: route.time)
//            self.addSubview(rs)
//        }*/
    }
    
    @objc func clickStar() {
        if (m_vehicle.isStarred) {
            m_vehicle.isStarred = false
            starButton.setImage(UIImage(named: "hollow_star.png"), for: .normal)
        } else {
            m_vehicle.isStarred = true
            starButton.setImage(UIImage(named: "star.png"), for: .normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
