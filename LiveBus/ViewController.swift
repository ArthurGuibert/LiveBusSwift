//
//  ViewController.swift
//  LiveBus
//
//  Created by Arthur GUIBERT on 31/01/2015.
//  Copyright (c) 2015 Arthur GUIBERT. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    let defaultZoomLevel : Double = 6000
    let locManager = CLLocationManager()
    var locationAcquired = false
    var stops: [BusStop]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // How original is this title?
        title = "LiveBus"
        
        addFavoriteButton()
        addLocationButton()
    }
    
    func addFavoriteButton() {
        // Adding the favotite icon
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: nil)
        let button = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        button.frame = CGRectMake(0, 0, 53, 32)
        button.addTarget(self, action: Selector("goToFavorite"), forControlEvents: UIControlEvents.TouchUpInside)
        
        let icon = UILabel(frame: CGRectMake(0, 0, 32, 32))
        icon.font = UIFont(name: "dripicons", size: 20)
        icon.textColor = UIColor(white: 1, alpha: 1)
        icon.text = "\u{e040}"
        button.addSubview(icon)
        navigationItem.leftBarButtonItem?.customView = button
    }
    
    func addLocationButton() {
        // Adding the gps icon
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: nil)
        let button = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        button.frame = CGRectMake(0, 0, 53, 32)
        button.addTarget(self, action: Selector("startLocation"), forControlEvents: UIControlEvents.TouchUpInside)
        
        let icon = UILabel(frame: CGRectMake(32, 0, 32, 32))
        icon.font = UIFont(name: "dripicons", size: 20)
        icon.textColor = UIColor(white: 1, alpha: 1)
        icon.text = "\u{e024}"
        button.addSubview(icon)
        navigationItem.rightBarButtonItem?.customView = button
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func performSearch(searchText: String) {
        var request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText
        request.region = self.mapView.region
        
        // Clearing the map
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        var search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { (response: MKLocalSearchResponse!, error: NSError!) -> Void in
            if response != nil && response.mapItems.count > 0 {
                let mapItem = response.mapItems[0] as MKMapItem
                
                let p = MKMapPointForCoordinate(mapItem.placemark.coordinate)
                let rect = MKMapRectMake(p.x - self.defaultZoomLevel / 2, p.y - self.defaultZoomLevel / 2, self.defaultZoomLevel, self.defaultZoomLevel)
                self.mapView.setVisibleMapRect(rect, animated: true)
                
                self.searchWithCoordinate(mapItem.placemark.coordinate)
            }
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        performSearch(searchBar.text)
        self.mapView.showsUserLocation = false
    }
    
    func searchWithCoordinate(coordinate: CLLocationCoordinate2D)
    {
        BusStop.getNearbyStops(coordinate, {(stops: Array<BusStop>) -> Void in
            // Clear annotations
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            self.stops = stops
            
             dispatch_async(dispatch_get_main_queue(),{
                // Add the annotation to the map - in the UI thread so that the annotations are updated
                for item in stops {
                    let stop = item as BusStop
                    
                    var annotation = MKPointAnnotation()
                    annotation.coordinate = stop.coordinate!
                    annotation.title = stop.name!
                    annotation.subtitle = stop.indicator!
                    self.mapView.addAnnotation(annotation)
                }
            })
            
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showBusStop" {
            let vb = segue.destinationViewController as LiveDeparturesController
            vb.stop = sender as? BusStop
        }
    }
    
    // MapView
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        println(view.annotation.title)
        
        for item in stops! {
            let stop = item as BusStop
            
            if stop.coordinate?.latitude == view.annotation.coordinate.latitude && stop.coordinate?.longitude == view.annotation.coordinate.longitude {
                
                performSegueWithIdentifier("showBusStop", sender: stop)
                
                break
            }
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("pinView")
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinView")
            annotationView.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.ContactAdd) as UIView
        }
        
        annotationView.canShowCallout = true;
        annotationView.enabled = true
        
        return annotationView;
    }
    
    // User location services
    func startLocation() {
        locManager.delegate = self
        locManager.requestWhenInUseAuthorization()
        
        locationAcquired = false
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
            locManager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            locManager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        if !locationAcquired {
            let p = MKMapPointForCoordinate(newLocation.coordinate)
            let rect = MKMapRectMake(p.x - self.defaultZoomLevel / 2, p.y - self.defaultZoomLevel / 2, self.defaultZoomLevel, self.defaultZoomLevel)
            
            self.mapView.setVisibleMapRect(rect, animated: true)
            
            searchWithCoordinate(newLocation.coordinate)
            
            locationAcquired = true
        }
    }
    
    // Go to the favorite bus stop
    func goToFavorite() {
        let userDefault = NSUserDefaults(suiteName: "group.com.slipcorp.LiveBus")
        let name = userDefault?.stringForKey("favoriteStopName")
        let code = userDefault?.stringForKey("favoriteStopCode")
        
        if name != nil && code != nil {
            let favorite = BusStop(code: code, name: name)
            performSegueWithIdentifier("showBusStop", sender: favorite)
        }
    }
}

