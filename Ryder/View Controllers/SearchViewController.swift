//
//  SearchViewController.swift
//  Ryder
//
//  Created by Dustin Newman on 4/1/18.
//  Copyright © 2018 Kevin Tan. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SearchViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var topbar: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var results = [Subscription]()
    
    override func viewDidLoad() {
        topbar.layer.masksToBounds = false
        topbar.layer.shadowColor = Charcoal.cgColor
        topbar.layer.shadowRadius = 4
        topbar.layer.shadowOpacity = 0.5
        topbar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") ?? UITableViewCell(style: .default, reuseIdentifier: "searchCell")
        if let shortNameLabel = cell.viewWithTag(1) as? UILabel {
            shortNameLabel.text = results[indexPath.row].shortName
        }
        if let directionLabel = cell.viewWithTag(2) as? UILabel {
            directionLabel.text = getStringFromDirection(results[indexPath.row].direction)
        }
        
        return cell
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            Firestore.firestore().collection("/busRoutes").getDocuments(completion: { (snapshot, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                if let snapshot = snapshot {
                    snapshot.query.whereField("short_name", isEqualTo: text).getDocuments(completion: { (documentsSnapshot, error) in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        if let documentsSnapshot = documentsSnapshot {
                            if documentsSnapshot.isEmpty {
                                return
                            }
                            self.results.removeAll()
                            for doc in documentsSnapshot.documents {
                                let data = doc.data()
                                let stops = data["stops"] as? [String: Any?]
                                for dir in (stops?.keys)! {
                                    self.results.append(Subscription(shortName: text, direction: dir))
                                }
                            }
                            self.tableView.reloadData()
                        }
                    })
                }
            })
        }
    }
}
