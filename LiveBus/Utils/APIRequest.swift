//
//  APIRequest.swift
//  LiveBus
//
//  Created by Arthur GUIBERT on 31/01/2015.
//  Copyright (c) 2015 Arthur GUIBERT. All rights reserved.
//

import Foundation

let appId = "YOUR_APP_ID"
let apiKey = "YOUR_API_KEY"

class APIRequest {
    // Small function to retrieve a json from an URL + parameters
    class func request(baseUrl: String, parameters: Dictionary<String,String>?,callback: AnyObject? -> Void) {
        var fullUrl = baseUrl + "?"
        
        if parameters != nil {
            for (key, value) in parameters! {
                fullUrl += key + "=" + value + "&"
            }
        }
        
        fullUrl += "app_id=\(appId)&api_key=\(apiKey)"
        
        let request = NSURLRequest(URL: NSURL(string: fullUrl)!)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            var jsonError: NSError?
            let json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &jsonError)
            
            if jsonError == nil && json != nil {
                callback(json)
            } else {
                callback(nil)
            }
        }
        
        task.resume()
    }
    
    class func dataFromURL(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        let task = NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: NSData(data: data))
        }
        
        task.resume()
    }
}