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
    var time: Double = 0.0
    var isStarred: Bool
    
    init(id: String, nextStop: String, type: String) {
        self.id = id
        self.nextStop = nextStop
        self.type = type
        
        super.init()
    }
    
}
