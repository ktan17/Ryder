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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.beaconManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.beaconManager.startListening()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: GMBLBeaconManagerDelegate methods
    
    func beaconManager(_ manager: GMBLBeaconManager!, didReceive sighting: GMBLBeaconSighting!) {
        print(sighting.rssi)
    }

}

