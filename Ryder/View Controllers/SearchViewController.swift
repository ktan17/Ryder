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
    var activityIndicator: UIView?
    
    var searchFailed = false
    
    override func viewDidLoad() {
        topbar.layer.masksToBounds = false
        topbar.layer.shadowColor = Charcoal.cgColor
        topbar.layer.shadowRadius = 4
        topbar.layer.shadowOpacity = 0.5
        topbar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
    }
    
    @IBAction func tappedStarButton(_ sender: UIButton!) {
        let index = sender.tag-1
        let subscription = results[index]
        if subscription.isStarred {
            sender.setBackgroundImage(UIImage(named: "hollow_star_black"), for: .normal)
            subscriptions.remove(subscription)
            results[index].isStarred = false
            
        } else {
            sender.setBackgroundImage(UIImage(named: "star_black"), for: .normal)
            subscriptions.insert(subscription)
            results[index].isStarred = true
        }
    }
    
    // MARK: Helper Functions
    
    private func makeActivityIndicator() -> UIView {
        let background = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        background.backgroundColor = UIColor(white: 0, alpha: 0.6)
        background.layer.cornerRadius = 15
        background.clipsToBounds = true
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        background.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: background.frame.width/2, y: background.frame.height/2)
        activityIndicator.startAnimating()
        
        return background
    }
    
    private func hideActivityIndicator() {
        if let indicator = activityIndicator {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                indicator.alpha = 0
            }, completion: { (success) in
                indicator.removeFromSuperview()
            })
            indicator.removeFromSuperview()
        }
    }
    
    private func updateTableAppearance() {
        if searchFailed {
            tableView.separatorStyle = .none
            tableView.allowsSelection = false
            
            if tableView.superview!.viewWithTag(30) == nil && tableView.superview!.viewWithTag(31) == nil {
                let errorLabel = UILabel(frame: CGRect.zero)
                errorLabel.font = UIFont(name: "Poppins-Medium", size: 24.0)
                errorLabel.textColor = UIColor(white: 0.8, alpha: 1.0)
                errorLabel.text = "No results found."
                errorLabel.sizeToFit()
                
                let errorSide: CGFloat = 150
                let errorImage = UIImageView(frame: CGRect(x: self.view.frame.width/2 - errorSide/2, y: self.view.frame.height/2 - errorSide/2 - errorLabel.frame.height/2 + topbar.frame.height/2, width: errorSide, height: errorSide))
                errorImage.image = UIImage(named: "Error")
                errorImage.tag = 30
                
                errorLabel.center = CGPoint(x: errorImage.center.x, y: errorImage.frame.maxY + errorLabel.frame.height/2)
                errorLabel.tag = 31
                
                tableView.superview!.addSubview(errorImage)
                tableView.superview!.addSubview(errorLabel)
            }
            
            self.tableView.reloadData()
        } else {
            tableView.separatorStyle = .singleLine
            tableView.allowsSelection = true
            
            if let errorImage = tableView.superview!.viewWithTag(30) {
                errorImage.removeFromSuperview()
            }
            
            if let errorLabel = tableView.superview!.viewWithTag(31) {
                errorLabel.removeFromSuperview()
            }
        }
    }
    
    // MARK: UITableViewDataSource/UITableViewDelegate methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let subscription = results[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") ?? UITableViewCell(style: .default, reuseIdentifier: "searchCell")
        if let shortNameLabel = cell.viewWithTag(1) as? UILabel {
            shortNameLabel.text = subscription.agency + ": " + subscription.shortName
        }
        if let directionLabel = cell.viewWithTag(2) as? UILabel {
            directionLabel.text = getStringFromDirection(subscription.direction)
        }
        
        for subview in cell.contentView.subviews {
            if let button = subview as? UIButton, button.tag != 0 {
                button.tag = indexPath.row+1
                if subscription.isStarred {
                    button.setBackgroundImage(UIImage(named: "star_black"), for: .normal)
                } else {
                    button.setBackgroundImage(UIImage(named: "hollow_star_black"), for: .normal)
                }
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            for subview in cell.contentView.subviews {
                if let button = subview as? UIButton {
                    self.tappedStarButton(button)
                }
            }
        }
    }
    
    // MARK: SearchBarDelegate methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text?.trimmingCharacters(in: .whitespaces) {
            self.results.removeAll()
            tableView.reloadData()
            
            let screen = UIScreen.main.bounds
            self.activityIndicator = makeActivityIndicator()
            self.activityIndicator!.center = CGPoint(x: screen.width/2, y: screen.height/2)
            tableView.superview!.addSubview(activityIndicator!)
            
//            let lowercased = text.lowercased()
//            if lowercased.range(of: "la") != nil || lowercased.range(of: "metro") != nil || lowercased.range(of: "losangeles") != nil {
//                Firestore.firestore().collection("/busRoutes").getDocuments(completion: { (snapshot, error) in
//                    if let error = error {
//                        print(error.localizedDescription)
//                        self.searchFailed = true
//                        self.searchBar.resignFirstResponder()
//                        self.hideActivityIndicator()
//                        self.updateTableAppearance()
//                        return
//                    }
//                    if let snapshot = snapshot {
//                        snapshot.query.whereField("agency", isEqualTo: DocumentReference( "agencies/sJ1UM2efBZycsZQ3oTOp").getDocuments(completion: { (documentsSnapshot, error) in
//                            if let error = error {
//                                print(error.localizedDescription)
//                                self.searchFailed = true
//                                self.searchBar.resignFirstResponder()
//                                self.hideActivityIndicator()
//                                self.updateTableAppearance()
//                                return
//                            }
//                            if let documentsSnapshot = documentsSnapshot {
//                                for doc in documentsSnapshot.documents {
//                                    let data = doc.data()
//                                    let result = (data["short_name"] as? String) ?? ""
//                                    let stops = data["stops"] as? [String: Any?]
//                                    for dir in (stops?.keys)! {
//                                        self.results.append(Subscription(
//                                            shortName: result,
//                                            direction: dir,
//                                            agency: "Metro - LA: ",
//                                            isStarred: false
//                                        ))
//                                    }
//                                }
//                                self.searchBar.resignFirstResponder()
//                                self.hideActivityIndicator()
//                                self.updateTableAppearance()
//                            }
//                        })
//                    }
//
//                })
//            }
//
//            else {
                Firestore.firestore().collection("/busRoutes").getDocuments(completion: { (snapshot, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        self.searchFailed = true
                        self.searchBar.resignFirstResponder()
                        self.hideActivityIndicator()
                        self.updateTableAppearance()
                        return
                    }
                    if let snapshot = snapshot {
                        snapshot.query.whereField("short_name", isGreaterThanOrEqualTo: text).getDocuments(completion: { (documentsSnapshot, error) in
                            if let error = error {
                                print(error.localizedDescription)
                                self.searchFailed = true
                                self.searchBar.resignFirstResponder()
                                self.hideActivityIndicator()
                                self.updateTableAppearance()
                                return
                            }
                            if let documentsSnapshot = documentsSnapshot {
                                if documentsSnapshot.isEmpty {
                                    self.searchFailed = true
                                    self.searchBar.resignFirstResponder()
                                    self.hideActivityIndicator()
                                    self.updateTableAppearance()
                                    return
                                }
                                for doc in documentsSnapshot.documents {
                                    let data = doc.data()
                                    let result = (data["short_name"] as? String) ?? ""
                                    if Int(result) == nil || !result.contains(text) {
                                        continue
                                    }
                                    let stops = data["stops"] as? [String: Any?]
                                    
                                    if let agencyRef = data["agency"] as? DocumentReference {
                                        agencyRef.getDocument(completion: { (snapshot, error) in
                                            if let error = error {
                                                print(error.localizedDescription)
                                                self.searchFailed = true
                                                self.searchBar.resignFirstResponder()
                                                self.hideActivityIndicator()
                                                self.updateTableAppearance()
                                                return
                                            }
                                            if let snapshot = snapshot, var agency = snapshot.data()?["name"] as? String {
                                                agency = agency.replacingOccurrences(of: "Los Angeles", with: "LA")
                                                for dir in (stops?.keys)! {
                                                    self.results.append(Subscription(
                                                        shortName: result,
                                                        direction: dir,
                                                        agency: agency,
                                                        isStarred: subscriptions.contains(where: { (subscription) -> Bool in
                                                            subscription.shortName == result && subscription.direction == dir
                                                        })
                                                    ))
                                                }
                                                self.tableView.reloadData()
                                            }
                                        })
                                    }
                                    
                                }
                                let when = DispatchTime.now() + 0.3
                                DispatchQueue.main.asyncAfter(deadline: when, execute: {
                                    self.searchFailed = self.results.isEmpty
                                    self.searchBar.resignFirstResponder()
                                    self.hideActivityIndicator()
                                    self.updateTableAppearance()
                                })
                            }
                        })
                    }
                })
            //}
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            if let errorImage = tableView.superview!.viewWithTag(30) {
                errorImage.removeFromSuperview()
            }
            
            if let errorLabel = tableView.superview!.viewWithTag(31) {
                errorLabel.removeFromSuperview()
            }
            
            self.results.removeAll()
            self.tableView.reloadData()
        }
    }
}
