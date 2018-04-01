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
    var starButton: UIButton!
    var nextLabel: UILabel!
    var nextLocationLabel: UILabel!
    var directionLabel: UILabel!
    var mapView: UIImageView!
    
    var routeArray = [RouteStop]()
    
    var topLine: UIView!
    var bottomLine: UIView!
    
    let padding: CGFloat = 24
    
    var targetExpandFrame: CGRect
    var targetDirectionLabelFrame: CGRect!
    
    var panRecognizer: UIPanGestureRecognizer?
    
//    init(vehicle: Vehicle, allStops: [Vehicle.RouteStopData], parent: UIViewController) {
    init(vehicle: Vehicle, parentFrame: UIView, initialFrame: CGRect) {
        self.m_vehicle = vehicle
        let statusBar = UIApplication.shared.statusBarFrame
        
        targetExpandFrame = CGRect(x: padding-0.5, y: statusBar.height + padding/2, width: parentFrame.frame.width - 2 * padding, height: parentFrame.frame.height + 20)
        super.init(frame: targetExpandFrame)
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        self.layer.backgroundColor = UIColor(red: 1.0, green: 130/255, blue: 72/255, alpha: 1.0).cgColor
        
        let mapPadding: CGFloat = 8
        let mapWidth: CGFloat = self.frame.width - 2*mapPadding
        if (vehicle.type == "Bus") {
            logoImageView = UIImageView(frame: CGRect(x: 15, y: 4, width: 34, height: 34))
        } else {
            logoImageView = UIImageView(frame: CGRect(x: 15, y: 4, width: 50, height: 34))
        }
        logoImageView.contentMode = .scaleAspectFit
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
            topLine = UIView(frame: CGRect(x: 0, y: logoImageView.frame.maxY + 2.5, width: 313, height: 3))
            bottomLine = UIView(frame: CGRect(x: 13, y: topLine.frame.maxY + 4, width: 313, height: 2))
            topLine.layer.backgroundColor = Charcoal.cgColor
            bottomLine.layer.backgroundColor = Charcoal.cgColor
            self.addSubview(topLine)
            self.addSubview(bottomLine)
        } else if (vehicle.type == "Train") {
            self.backgroundColor = UIColor(red: 32/255, green: 85/255, blue: 131/255, alpha: 1)
            let stripeView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 20))
            stripeView.backgroundColor = UIColor(white: 0, alpha: 0.3)
            self.addSubview(stripeView)
            self.sendSubview(toBack: stripeView)
            
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
        transitTypeLabel.center.y = logoImageView.center.y + 3
        self.addSubview(transitTypeLabel)
        
        transitNumberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 31, height: 26))
        transitNumberLabel.text = vehicle.routeNumber
        transitNumberLabel.font = UIFont(name: "Poppins-Bold", size: 32.0)
        transitNumberLabel.textColor = .white
        transitNumberLabel.sizeToFit()
        transitNumberLabel.frame = CGRect(x: self.frame.width - transitNumberLabel.frame.width - 15, y: transitTypeLabel.frame.minY, width: transitNumberLabel.frame.width, height: transitNumberLabel.frame.height)
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
        nextLabel.center.y -= 12.5
        self.addSubview(nextLabel)
        
        // destination
        nextLocationLabel.frame = CGRect(x: nextLabel.frame.minX, y: nextLabel.frame.maxY + 5, width: mapWidth, height: 90.0)
        setLineSpacing(nextLocationLabel, text: vehicle.nextStop, lineHeightMultiple: 0.8)
        nextLocationLabel.font = UIFont(name: "Poppins-Medium", size: 32.0)
        nextLocationLabel.textColor = .white
        nextLocationLabel.numberOfLines = 2
        nextLocationLabel.sizeToFit()
        self.addSubview(nextLocationLabel)
        
        starButton = UIButton(frame: CGRect(x: mapWidth - 28.0, y: 0, width: 34, height: 34))
        
        // direction label
        directionLabel.text = vehicle.direction
        directionLabel.font = UIFont(name: "Poppins-Light", size: 24.0)
        directionLabel.textColor = .white
        directionLabel.sizeToFit()
        targetDirectionLabelFrame = CGRect(x: nextLocationLabel.frame.minX, y: nextLocationLabel.frame.maxY + 5, width: directionLabel.frame.width, height: directionLabel.frame.height)
        
        directionLabel.font = UIFont(name: "Poppins-Medium", size: 16.0)
        directionLabel.sizeToFit()
        directionLabel.frame = CGRect(x: self.frame.width - directionLabel.frame.width - 9, y: nextLocationLabel.frame.maxY + 3, width: directionLabel.frame.width, height: directionLabel.frame.height)
        self.addSubview(directionLabel)
        
        // map view
        mapView = UIImageView(image: UIImage(named: "maptest.png"))
        mapView.frame = CGRect(x: mapPadding, y: directionLabel.frame.maxY + 20, width: mapWidth, height: mapWidth)
        mapView.layer.cornerRadius = 10
        mapView.clipsToBounds = true
        self.addSubview(mapView)
        
        // star button
        starButton = UIButton(frame: CGRect(x: mapView.frame.maxX - 28, y: 0, width: 28, height: 28))
        if (vehicle.isStarred) {
            starButton.setImage(UIImage(named: "star.png"), for: .normal)
        } else {
            starButton.setImage(UIImage(named: "hollow_star.png"), for: .normal)
        }
        starButton.center.y = directionLabel.center.y
        self.addSubview(starButton)
        starButton.addTarget(self, action: #selector(clickStar), for: .touchUpInside)

        let width = self.frame.width - 2*mapPadding
        var origin: CGPoint = CGPoint(x: mapPadding, y: mapView.frame.maxY + 22)
        for stop in vehicle.routeStops {
            let rs = RouteStop(origin: origin, stopLabel: stop.name, timeLabel: secToTime(stop.time), viewWidth: width)
            if vehicle.type == "Train" {
                rs.timeLabel.textColor = .white
            }
            self.addSubview(rs)
            origin.y += rs.frame.height
        }
        
        self.contentSize = CGSize(width: self.frame.width, height: origin.y + 20)
        
        self.frame = initialFrame
        
    }
    
    @objc func clickStar() {
        if (m_vehicle.isStarred) {
            m_vehicle.isStarred = false
            subscriptions.remove(Subscription(
                shortName: m_vehicle.routeNumber,
                direction: String(m_vehicle.direction.first!),
                agency: "",
                isStarred: true
            ))
            starButton.setImage(UIImage(named: "hollow_star.png"), for: .normal)
        } else {
            m_vehicle.isStarred = true
            subscriptions.insert(Subscription(
                shortName: m_vehicle.routeNumber,
                direction: String(m_vehicle.direction.first!),
                agency: "",
                isStarred: true
            ))
            starButton.setImage(UIImage(named: "star.png"), for: .normal)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Helper Functions
    
    func expand() {
        //self.directionLabel.font = UIFont(name: "Poppins-Light", size: 24.0)
        self.starButton.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            self.frame = self.targetExpandFrame
            self.directionLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5).translatedBy(x: self.targetDirectionLabelFrame.minX - self.directionLabel.frame.minX + 85, y: 0)
            self.starButton.alpha = 1
            //self.directionLabel.frame = self.targetDirectionLabelFrame
        }, completion: { (success) in
            //self.directionLabel.font = UIFont(name: "Poppins-Light", size: 24.0)
        })
    }
    
}
