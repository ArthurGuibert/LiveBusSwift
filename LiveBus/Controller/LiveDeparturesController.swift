//
//  LiveDeparturesController.swift
//  LiveBus
//
//  Created by Arthur GUIBERT on 01/02/2015.
//  Copyright (c) 2015 Arthur GUIBERT. All rights reserved.
//

import UIKit

class LiveDeparturesController: UITableViewController {
    var stop: BusStop?
    var departures: [Departure]?
    let cellHeight: CGFloat = 60.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Regestering the custom cell we're going to use
        var nib = UINib(nibName: "DepartureCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "DepartureCell")
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        title = stop?.name
        
        // Adding the favorite button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: nil)
        let button = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        button.frame = CGRectMake(0, 0, 53, 32)
        button.addTarget(self, action: Selector("setFavorite"), forControlEvents: UIControlEvents.TouchUpInside)
        
        let icon = UILabel(frame: CGRectMake(36, 0, 32, 32))
        icon.font = UIFont(name: "dripicons", size: 20)
        icon.textColor = UIColor(white: 1, alpha: 1)
        icon.text = "\u{e040}"
        button.addSubview(icon)
        navigationItem.rightBarButtonItem?.customView = button
        
        // Hiding separator
        tableView.separatorColor = UIColor(white: 1, alpha: 0)
        
        // Fetching data
        Departure.getDepartures(stop!, { (departures: Array<Departure>) -> Void in
            self.departures = departures
            
            if self.departures != nil {
                self.departures!.sort({$0.departureTime < $1.departureTime})
            }
            
            dispatch_async(dispatch_get_main_queue(),{
                self.tableView.reloadData()
            })
        })
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        Departure.getDepartures(stop!, { (departures: Array<Departure>) -> Void in
            self.departures = departures
            
            if self.departures != nil {
                self.departures!.sort({$0.departureTime < $1.departureTime})
            }
            
            // Refreshing on the main thread
            dispatch_async(dispatch_get_main_queue(),{
                self.tableView.reloadData()
                sender.endRefreshing()
            })
        })
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let departure: Departure = departures![indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier("DepartureCell") as DepartureCell

        cell.lineLabel.text = departure.line
        cell.directionLabel.text = departure.direction
        
        let t = Int(departure.departureTime! / 60)
        
        if t == 0 {
            cell.timeLabel.text = "due"
        } else {
            cell.timeLabel.text = "\(t) min"
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if departures != nil {
            return departures!.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }
    
    func setFavorite() {
        let userDefault = NSUserDefaults(suiteName: "group.com.slipcorp.LiveBus")
        userDefault?.setObject(stop?.name, forKey: "favoriteStopName")
        userDefault?.setObject(stop?.code, forKey: "favoriteStopCode")
        userDefault?.synchronize()
    }
}
