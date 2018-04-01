//
//  Vehicle.swift
//  Ryder
//
//  Created by Kevin Tan on 3/31/18.
//  Copyright © 2018 Kevin Tan. All rights reserved.
//

import Foundation

class Vehicle: NSObject {
    
    var distance: Double!
    var url: String!
    var id: String
    var nextStop: String
    var type: String
    var routeNumber: String
    var direction: String
    var isStarred = false
    
    init(id: String, nextStop: String, type: String, direction: String, routeNumber: String) {
        self.id = id
        self.nextStop = nextStop
        self.type = type
        self.direction = direction
        self.routeNumber = routeNumber
        
        super.init()
    }
    
}
