//
//  Departure.swift
//  LiveBus
//
//  Created by Arthur GUIBERT on 01/02/2015.
//  Copyright (c) 2015 Arthur GUIBERT. All rights reserved.
//

import Foundation

class Departure {
    let stop: BusStop?
    let line: String?
    let direction: String?
    let departureTime: NSTimeInterval?
    
    init(stop: BusStop?, line: String?, direction: String?, departureTime: NSTimeInterval?)
    {
        self.stop = stop
        self.line = line
        self.direction = direction
        self.departureTime = departureTime
    }
    
    class func getDepartures(stop: BusStop, callback: Array<Departure> -> Void) {
        var departures: [Departure] = []
        
        APIRequest.request("https://transportapi.com/v3/uk/bus/stop/\(stop.code!)/live.json", parameters: nil, callback: {(response: AnyObject?) -> Void in
            
            if response != nil {
                let json = JSON(response!)
                
                let requestTime = json["request_time"].stringValue
                
                if json["departures"] != nil {
                    for (line: String, subJson: JSON) in json["departures"] {
                        for (index: String, depJson: JSON) in subJson {
                            let date = Departure.intervalFromStrings(requestTime, departureTime: depJson["expected_departure_time"].stringValue)
                            
                            let departure = Departure(stop: stop, line: line, direction: depJson["direction"].string, departureTime: date)
                            departures.append(departure)
                        }
                    }
                }
            }
            
            callback(departures)
        });
    }
    
    class func intervalFromStrings(timeBase: String, departureTime: String) -> NSTimeInterval {
        // The base date format is like this: 2015-02-01T10:51:30+00:00
        // The departure time however has a different format: 09:31
        
        let baseScanner = NSScanner(string: timeBase)
        baseScanner.charactersToBeSkipped = NSCharacterSet(charactersInString: "T-:")
        var components = [Int]()
        var value: Int = 0
        
        while baseScanner.scanInteger(&value) {
            components.append(value)
        }
        
        var minutes = components[components.count - 4] + components[components.count - 5] * 60
        
        let scanner = NSScanner(string: departureTime)
        scanner.charactersToBeSkipped = NSCharacterSet(charactersInString: ":")
        components.removeAll(keepCapacity: false)
        
        while scanner.scanInteger(&value) {
            components.append(value)
        }
        
        if components.count < 2 {
            return 0
        }
        
        minutes = components[components.count - 1] + components[components.count - 2] * 60 - minutes
        
        if minutes < 0 {
            minutes += 24 * 60
        }
        
        return NSTimeInterval(minutes * 60)
    }
}