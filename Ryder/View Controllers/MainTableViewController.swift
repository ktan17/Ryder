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

class MainTableViewController: UITableViewController, GMBLBeaconManagerDelegate {

    private let cellPadding: CGFloat = 9
    
    lazy var beaconManager = GMBLBeaconManager()
    lazy var refresh: UIRefreshControl! = createRefreshControl()
    
    var vehiclesInRange = [Vehicle]()
    
    var timeouts = [String : Int]()
    var timer: Timer!
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.beaconManager.startListening()
        self.beginRefreshingControl()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Helper Functions
    
    private func beginTiming() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
    }
    
    private func reloadTickets() {
        var set = IndexSet()
        set.insert(0)
        tableView.reloadSections(set, with: .automatic)
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

        if let cell = tableView.dequeueReusableCell(withIdentifier: "TicketViewCell") {
            return cell
        }
        
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
        let noodle = TicketDetailView(vehicle: vehiclesInRange[indexPath.row], parent: self)
        self.navigationController?.view.addSubview(noodle)
    }
    
    // MARK: GMBLBeaconManagerDelegate methods
    
    func beaconManager(_ manager: GMBLBeaconManager!, didReceive sighting: GMBLBeaconSighting!) {
        
        func getRoute(from routeRef: DocumentReference, id: String, nextStop: String) {
            routeRef.getDocument { (snapshot, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if let snapshot = snapshot, let agencyRef = snapshot.data()?["agency"] as? DocumentReference {
                    getAgency(from: agencyRef, id: id, nextStop: nextStop)
                }
            }
        }
        
        func getAgency(from agencyRef: DocumentReference, id: String, nextStop: String) {
            agencyRef.getDocument { (snapshot, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if let snapshot = snapshot, let type = snapshot.data()?["type"] as? String {
                    let vehicle = Vehicle(id: id, nextStop: nextStop, type: type)
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
        
        guard let identifier = sighting.beacon.identifier else {
            return
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
                                let routeRef = document.data()["route"] as? DocumentReference {
                                getRoute(from: routeRef, id: id, nextStop: nextStop)
                            }
                        }
                    }
                }
            }
            
        }
       
        timeouts[identifier] = 10
        beginTiming()
        
    }

}

