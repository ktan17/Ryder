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
    var vehiclesInRange = [Vehicle]()
    var timeouts = [String : Int]()
    
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 202, height: 66))
        self.navigationItem.titleView = containerView
        
        let title = UIImage(named: "ryder")
        let titleImageView = UIImageView(image: title)
        titleImageView.contentMode = .scaleAspectFit
        
        let titleWidth: CGFloat = containerView.frame.width*0.4, titleHeight: CGFloat = containerView.frame.height*0.4
        titleImageView.frame = CGRect(x: containerView.frame.width/2 - titleWidth/2, y: containerView.frame.height/2 - titleHeight*0.8, width: titleWidth, height: titleHeight)
        containerView.addSubview(titleImageView)

        self.beaconManager.delegate = self
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: cellPadding))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.beaconManager.startListening()
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
    
    @objc func timerAction(_ sender: Timer!) {
        
        for key in timeouts.keys {
            timeouts[key]! -= 1

            if timeouts[key]! <= 0 {
                timer.invalidate()
                timer = nil
                
                timeouts.removeValue(forKey: key)
                if let index = vehiclesInRange.index(where: { $0.id == key}) {
                    vehiclesInRange.remove(at: index)
                    
                    self.reloadTickets()
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
        print("im gay")
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
                    self.reloadTickets()
                    
                    self.timeouts[id] = 10
                    self.beginTiming()
                }
            }
        }
        
        guard let identifier = sighting.beacon.identifier else {
            return
        }

        if !timeouts.keys.contains(identifier) {
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
        
        timeouts[identifier] = 10
        beginTiming()
        
    }

}

