//
//  BusStop.swift
//  LiveBus
//
//  Created by Arthur GUIBERT on 31/01/2015.
//  Copyright (c) 2015 Arthur GUIBERT. All rights reserved.
//

import Foundation
import CoreLocation

class BusStop {
    var name: String?
    var indicator: String?
    var locality: String?
    var coordinate: CLLocationCoordinate2D?
    var code: String?
    
    init(name: String?, indicator: String?, locality: String?, coordinate: CLLocationCoordinate2D?)
    {
        self.name = name
        self.indicator = indicator
        self.locality = locality
        self.coordinate = coordinate
    }
    
    init(code: String?, name: String?)
    {
        self.code = code
        self.name = name
    }
    
    init(json: JSON)
    {
        self.name = json["name"].string
        self.indicator = json["indicator"].string
        self.locality = json["locality"].string
        self.code = json["atcocode"].string
        
        if json["latitude"].double != nil &&  json["longitude"].double != nil {
            self.coordinate = CLLocationCoordinate2D(latitude: json["latitude"].doubleValue, longitude: json["longitude"].doubleValue)
        }
    }
    
    class func getNearbyStops(coordinate: CLLocationCoordinate2D, callback: Array<BusStop> -> Void) {
        var stops: [BusStop] = []
        
        APIRequest.request("https://transportapi.com/v3/uk/bus/stops/near.json", parameters: ["lat" : "\(coordinate.latitude)", "lon" : "\(coordinate.longitude)", "rpp" : "10"], callback: {(response: AnyObject?) -> Void in
            
            if response != nil {
                let json = JSON(response!)
                
                if json["stops"].array != nil {
                    for (index: String, subJson: JSON) in json["stops"] {
                        let stop = BusStop(json: subJson)
                        stops.append(stop)
                    }
                }
            }
            
            callback(stops)
        });
    }
}