//
//  ViewController.swift
//  Ryder
//
//  Created by Kevin Tan on 3/30/18.
//  Copyright © 2018 Kevin Tan. All rights reserved.
//

import UIKit
import Gimbal
import FirebaseFirestore

let noBluetooth = false

class MainTableViewController: UITableViewController, GMBLBeaconManagerDelegate {

    private let cellPadding: CGFloat = 9
    
    lazy var beaconManager = GMBLBeaconManager()
    lazy var refresh: UIRefreshControl! = createRefreshControl()
    lazy var mutex: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    var vehiclesInRange = [Vehicle]()
    
    var currentDetailId: String? = nil
    var oldStar = false
    
    var firstTime = true
    
    var timeouts = [String : Int]()
    var timer: Timer!
    
    var isAnimating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 202, height: 66))
        self.navigationItem.titleView = containerView
        
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = Charcoal.cgColor
        self.navigationController?.navigationBar.layer.shadowRadius = 4
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.5
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        
        let title = UIImage(named: "ryder")
        let titleImageView = UIImageView(image: title)
        titleImageView.contentMode = .scaleAspectFit
        
        let titleWidth: CGFloat = containerView.frame.width*0.5, titleHeight: CGFloat = containerView.frame.height*0.5
        titleImageView.frame = CGRect(x: containerView.frame.width/2 - titleWidth/2, y: containerView.frame.height/2 - titleHeight*0.875, width: titleWidth, height: titleHeight)
        containerView.addSubview(titleImageView)

        self.beaconManager.delegate = self
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: cellPadding))
        
        if noBluetooth {
            createDummyVehicle()
        }
    }
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstTime {
            firstTime = false
            self.reloadTickets()
        }
        
        if !noBluetooth {
            self.beaconManager.startListening()
            if vehiclesInRange.isEmpty {
                self.beginRefreshingControl()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Helper Functions
    
    private func createDummyVehicle() {
        let identifier = "MKTY-MM2M4"
     
        if !self.timeouts.keys.contains(identifier) {
            
            DispatchQueue.global(qos: .background).async {
                Firestore.firestore().collection("vehicles").getDocuments { (snapshot, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    if let snapshot = snapshot {
                        for document in snapshot.documents {
                            if let id = document.data()["beaconID"] as? String,
                                id == identifier,
                                let nextStop = document.data()["nextStop"] as? String,
                                let routeRef = document.data()["route"] as? DocumentReference,
                                let routeNumber = document.data()["number"] as? String,
                                let rawDirection = document.data()["direction"] as? String,
                                let direction = getStringFromDirection(rawDirection),
                                let times = document.data()["timeTo"] as? [Int] {
                                self.getRoute(from: routeRef, id: id, nextStop: nextStop, direction: direction, routeNumber: routeNumber, times: times)
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    private func getRoute(from routeRef: DocumentReference, id: String, nextStop: String, direction: String, routeNumber: String, times: [Int]) {
        routeRef.getDocument { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let snapshot = snapshot,
                let secondRouteNumber = snapshot.data()?["short_name"] as? String,
                let stops = (snapshot.data()?["stops"] as? [String : Any])?[String(direction.first!)] as? [String],
                let agencyRef = snapshot.data()?["agency"] as? DocumentReference {
                var route: String
                if Int(secondRouteNumber) != nil {
                    route = secondRouteNumber
                } else {
                    route = routeNumber
                }
                
                var stopData = [Vehicle.RouteStopData]()
                if let idxOfNext = stops.index(of: nextStop) {
                    for i in idxOfNext ... stops.count-1 {
                        guard i-idxOfNext < times.count else {
                            break
                        }
                        let stop = stops[i]
                        let element = Vehicle.RouteStopData(
                            name: stop,
                            time: times[i-idxOfNext]
                        )
                        stopData.append(element)
                    }
                }
                
                self.getAgency(from: agencyRef, id: id, nextStop: nextStop, direction: direction, routeNumber: route, routeStopData: stopData)
            }
        }
    }
    
    private func getAgency(from agencyRef: DocumentReference, id: String, nextStop: String, direction: String, routeNumber: String, routeStopData: [Vehicle.RouteStopData]) {
        agencyRef.getDocument { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let snapshot = snapshot, let type = snapshot.data()?["type"] as? String {
                let vehicle = Vehicle(id: id, nextStop: nextStop, type: type, direction: direction, routeNumber: routeNumber, routeStops: routeStopData)
                self.vehiclesInRange.append(vehicle)
                DispatchQueue.main.async {
                    self.reloadTickets()
                    if let control = self.refresh {
                        control.endRefreshing()
                        let when = DispatchTime.now() + 0.5
                        DispatchQueue.main.asyncAfter(deadline: when, execute: {
                            self.tableView.refreshControl = nil
                            self.refresh = nil
                            self.tableView.isUserInteractionEnabled = true
                        })
                    }
                }
            }
        }
    }
    
    private func beginTiming() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
    }
    
    private func reloadTickets() {
        mutex.wait()
        var set = IndexSet()
        set.insert(0)
        tableView.reloadSections(set, with: .automatic)
        mutex.signal()
    }
    
    private func createRefreshControl() -> UIRefreshControl {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        label.text = "Searching for nearby vehicles... Hang tight!"
        label.font = UIFont(name: "Poppins-LightItalic", size: 14)
        label.textColor = UIColor(white: 0.6, alpha: 1.0)
        label.sizeToFit()
        
        let control = UIRefreshControl()
        control.frame.size = CGSize(width: control.frame.width, height: control.frame.height + 10)
        label.center = CGPoint(x: control.frame.width/2, y: control.frame.height)
        label.tag = 1
        control.addSubview(label)
        
        return control
        
    }
    
    private func beginRefreshingControl() {
        refresh = createRefreshControl()
        tableView.refreshControl = self.refresh
        
        if let label = self.refresh.viewWithTag(1) as? UILabel {
            label.center.x = self.refresh.frame.width/2
        }
        
        refresh.beginRefreshing()
        self.tableView.setContentOffset(CGPoint(x: 0, y: -refresh.frame.size.height), animated: true)
        self.tableView.isUserInteractionEnabled = false
    }
    
    @objc func timerAction(_ sender: Timer!) {
        
        for key in timeouts.keys {
            timeouts[key]! -= 1
            print(key + " " + String(timeouts[key]!))
            if timeouts[key]! <= 0 {
                
                if let index = vehiclesInRange.index(where: { $0.id == key}) {
                    vehiclesInRange.remove(at: index)
                    self.reloadTickets()
                }
                
                timeouts.removeValue(forKey: key)
                if timeouts.isEmpty {
                    timer.invalidate()
                    timer = nil
                    
                    self.beginRefreshingControl()
                }
                
            }
        }
        
    }
    
    // MARK: UITableViewDataSource/UITableViewDelegate methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vehiclesInRange.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "TicketViewCell") {
//            return cell
//        }
//
        let objects = Bundle.main.loadNibNamed("TicketViewCell", owner: self, options: nil)
        for object in objects ?? [] {
            if let cell = object as? TicketViewCell {
                let vehicle = vehiclesInRange[indexPath.row]
                cell.configure(using: vehicle)
                return cell
            }
        }
        
        return UITableViewCell(style: .default, reuseIdentifier: "boob")
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 194 + 2*cellPadding
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? TicketViewCell {
            var rect = cell.backgroundImageView.frame
            rect.origin.x += 3
            rect.size.width -= 7.5
            
            let cellFrame = navigationController!.view.convert(rect, from: cell)
            print(cellFrame)
            
            let whiteView = UIView(frame: UIScreen.main.bounds)
            whiteView.backgroundColor = .white
            whiteView.alpha = 0
            whiteView.tag = 69
            self.navigationController?.view.addSubview(whiteView)

            let ticketDetailView = TicketDetailView(vehicle: vehiclesInRange[indexPath.row], parentFrame: (self.navigationController?.view)!, initialFrame: cellFrame)
            ticketDetailView.delegate = self
            self.navigationController?.view.addSubview(ticketDetailView)
            ticketDetailView.expand()
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
                whiteView.alpha = 0.75
            }, completion: nil)
            
            self.tableView.isUserInteractionEnabled = false
            self.currentDetailId = vehiclesInRange[indexPath.row].id
            self.oldStar = vehiclesInRange[indexPath.row].isStarred
        }
        
    }
    
    // MARK: GMBLBeaconManagerDelegate methods
    
    func beaconManager(_ manager: GMBLBeaconManager!, didReceive sighting: GMBLBeaconSighting!) {
        
        guard let identifier = sighting.beacon.identifier else {
            return
        }
        
        // HARD CODE O3O
        if subscriptions.contains(where: { (subscription) -> Bool in
            subscription.shortName == "602" && subscription.direction == "E"
        }) && identifier == "MKTY-MM2M4" {
            print("YEETED")
        }
        
        else if subscriptions.contains(where: { (subscription) -> Bool in
            subscription.shortName == "768" && subscription.direction == "S"
        }) && identifier == "NNS6-34KS6" {
            print("YOTE")
        }
        
        if !self.timeouts.keys.contains(identifier) {
            
            DispatchQueue.global(qos: .background).async {
                Firestore.firestore().collection("vehicles").getDocuments { (snapshot, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    if let snapshot = snapshot {
                        for document in snapshot.documents {
                            if let id = document.data()["beaconID"] as? String,
                                id == identifier,
                                let nextStop = document.data()["nextStop"] as? String,
                                let routeRef = document.data()["route"] as? DocumentReference,
                                let routeNumber = document.data()["number"] as? String,
                                let rawDirection = document.data()["direction"] as? String,
                                let direction = getStringFromDirection(rawDirection),
                                let times = document.data()["timeTo"] as? [Int] {
                                self.getRoute(from: routeRef, id: id, nextStop: nextStop, direction: direction, routeNumber: routeNumber, times: times)
                            }
                        }
                    }
                }
            }
            
        }
        
        timeouts[identifier] = 10
        beginTiming()
    }
    
    // MARK: ScrollViewDelegate methods
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let detailView = scrollView as? TicketDetailView {
            if detailView.frame.origin.y >= 32 && !isAnimating {
                isAnimating = true
                detailView.delegate = nil
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
                    detailView.frame.origin.y = 32
                }, completion: { [unowned self] (success) in
                    self.isAnimating = false
                    detailView.delegate = self
                })
            }
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let detailView = scrollView as? TicketDetailView {
            if detailView.frame.origin.y >= 32 && !isAnimating {
                isAnimating = true
                detailView.delegate = nil
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
                    detailView.frame.origin.y = 32
                }, completion: { [unowned self] (success) in
                    self.isAnimating = false
                    detailView.delegate = self
                })
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let detailView = scrollView as? TicketDetailView {
            let initial: CGFloat = 32
            let initialHeight: CGFloat = UIScreen.main.bounds.height + 20
            print(detailView.contentOffset.y)
            print(scrollView.contentSize.height - 64)
            
            if detailView.contentOffset.y <= 0 {
                detailView.frame.origin.y += abs(detailView.contentOffset.y)
                detailView.contentOffset.y = 0
                
                if detailView.frame.origin.y >= initial + 140 {
                    detailView.delegate = nil
                    if let whiteView = navigationController?.view.viewWithTag(69), !isAnimating {
                        isAnimating = true
                        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
                            detailView.frame = CGRect(x: detailView.frame.minX, y: UIScreen.main.bounds.height, width: detailView.frame.width, height: detailView.frame.height)
                            whiteView.alpha = 0
                        }, completion: { (success) in
                            detailView.removeFromSuperview()
                            whiteView.removeFromSuperview()
                            self.isAnimating = false
                            self.tableView.isUserInteractionEnabled = true
                            
                            if detailView.m_vehicle.isStarred != self.oldStar {
                                self.reloadTickets()
                            }
                        })
                    }
                }
            }
                
            else if detailView.contentOffset.y > 0 && detailView.contentOffset.y <= 80 {
                detailView.frame.origin.y = initial - detailView.contentOffset.y/2
            }
            
            else if detailView.contentOffset.y >= 473 - 80 && detailView.contentOffset.y <= 497.5 {
                detailView.frame.size.height = initialHeight - (detailView.contentOffset.y - (473-80))/2
            }
        }
    }

}

