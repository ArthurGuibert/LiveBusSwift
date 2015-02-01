//
//  TodayViewController.swift
//  BusExtension
//
//  Created by Arthur GUIBERT on 01/02/2015.
//  Copyright (c) 2015 Arthur GUIBERT. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreLocation

class TodayViewController: UITableViewController, NCWidgetProviding {
    var departures: [Departure]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Regestering the custom cell we're going to use
        var nib = UINib(nibName: "TodayDepartureCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "TodayCell")
        
        // Do any additional setup after loading the view from its nib.
        self.preferredContentSize = CGSizeMake(0, 218);
        
        let userDefault = NSUserDefaults(suiteName: "group.com.slipcorp.LiveBus")
        let name = userDefault?.stringForKey("favoriteStopName")
        let code = userDefault?.stringForKey("favoriteStopCode")
        
        if name != nil && code != nil {
            let favorite = BusStop(code: code, name: name)
            
            Departure.getDepartures(favorite, { (departures: Array<Departure>) -> Void in
                self.departures = departures
                
                if self.departures != nil {
                    self.departures!.sort({$0.departureTime < $1.departureTime})
                }
                dispatch_async(dispatch_get_main_queue(),{
                    self.tableView.reloadData()
                })
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        completionHandler(NCUpdateResult.NewData)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let departure: Departure = departures![indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier("TodayCell") as TodayDepartureCell
        
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
        if departures == nil {
            return 0
        }
        
        return departures!.count
    }
    
    func widgetMarginInsetsForProposedMarginInsets
        (defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) {
            return UIEdgeInsetsZero
    }
}
