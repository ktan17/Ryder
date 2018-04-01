//
//  SearchViewController.swift
//  Ryder
//
//  Created by Dustin Newman on 4/1/18.
//  Copyright © 2018 Kevin Tan. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController {
    @IBOutlet weak var topbar: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        topbar.layer.masksToBounds = false
        topbar.layer.shadowColor = Charcoal.cgColor
        topbar.layer.shadowRadius = 4
        topbar.layer.shadowOpacity = 0.5
        topbar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        
        searchBar.backgroundImage = UIImage()
    }
}
