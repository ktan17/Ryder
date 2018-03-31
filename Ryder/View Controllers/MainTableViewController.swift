//
//  ViewController.swift
//  Ryder
//
//  Created by Kevin Tan on 3/30/18.
//  Copyright © 2018 Kevin Tan. All rights reserved.
//

import UIKit
import Gimbal

class MainTableViewController: UITableViewController, GMBLBeaconManagerDelegate {

    lazy var beaconManager = GMBLBeaconManager()
    var vehiclesInRange = [Vehicle]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.beaconManager.delegate = self
        vehiclesInRange.append(Vehicle())
        vehiclesInRange.append(Vehicle())
        vehiclesInRange.append(Vehicle())
        
        tableView.separatorStyle = .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.beaconManager.startListening()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                cell.selectionStyle = .none
                return cell
            }
        }
        
        return UITableViewCell(style: .default, reuseIdentifier: "boob")
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 212
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("im gay")
    }
    
    // MARK: GMBLBeaconManagerDelegate methods
    
    func beaconManager(_ manager: GMBLBeaconManager!, didReceive sighting: GMBLBeaconSighting!) {
        print(sighting.rssi)
    }

}

