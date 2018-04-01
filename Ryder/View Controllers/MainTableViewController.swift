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
                if indexPath.row == 1 {
                    cell.backgroundImageView.image = UIImage(named: "blueticket")
                }
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
        
        guard let identifier = sighting.beacon.identifier else {
            return
        }
        
        if identifier == "MKTY-MM2M4" {
            print("woohoo")
        }
        else if identifier == "NNS6-34KS6" {
            if !vehiclesInRange.contains(where: { $0.id == identifier }) {
                let vehicle = Vehicle(id: identifier)
                vehiclesInRange.append(vehicle)
                self.reloadTickets()
            }
            
            timeouts[identifier] = 10
            beginTiming()
        }
        else {
            
        }
        
    }

}

