//
//  ViewController.swift
//  LocationBasedAwake-GeoFencing-
//
//  Created by Pritam Bolenwar on 19/08/14.
//  Copyright (c) 2014 Pritam. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Foundation

class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate
{
    @IBOutlet var coordinateLabel:UILabel
    @IBOutlet var mapView:MKMapView
    @IBOutlet var trackButton:UIButton
    var locationManager:CLLocationManager
    
    init(coder aDecoder: NSCoder!)
    {
        self.locationManager = CLLocationManager()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        /// Initializing the Location manager
        if(!CLLocationManager.locationServicesEnabled())
        {
            NSLog("%@","You need to enable location services to use this app.");
            return;
        }
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 20
        self.locationManager.activityType = CLActivityType.OtherNavigation
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        var  version:NSString  = UIDevice.currentDevice().systemVersion
        let ver_float  = version.floatValue
        if (ver_float >= 5.0)
        {
             self.locationManager.requestAlwaysAuthorization()
        }
        var userdefalts : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if(!userdefalts.valueForKey("Track") || userdefalts.valueForKey("Track").isEqualToString("No"))
        {
            trackButton.setTitle("Untrack", forState: UIControlState.Normal)
        }
        else
        {
            trackButton.setTitle("Track", forState: UIControlState.Normal)
        }
        self.locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /// Tracking the geofences
    @IBAction func trackButtonClicked(sender : AnyObject)
    {
        println("Button was clicked", sender)
        var userdefalts : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if(!userdefalts.valueForKey("Track") || userdefalts.valueForKey("Track").isEqualToString("No"))
        {
            var initialCoordinate:CLLocationCoordinate2D ;
            initialCoordinate = CLLocationCoordinate2D(latitude: self.locationManager.location.coordinate.latitude,longitude: self.locationManager.location.coordinate.longitude)
            var  dictonary:NSMutableDictionary = NSMutableDictionary.dictionary();
            dictonary.setValue("Tracking Locations", forKey:"title")
            dictonary.setValue(NSNumber.numberWithDouble(initialCoordinate.latitude), forKey: "latitude")
            dictonary.setValue(NSNumber.numberWithDouble(initialCoordinate.longitude), forKey: "longitude")
            dictonary.setValue(NSNumber.numberWithFloat(100.0), forKey: "radius")
            NSUserDefaults.standardUserDefaults().setObject(dictonary, forKey:"Dictionary");
            var locationTotrack:CLRegion = self.getClregionFromDictionary(dictonary)
            self.locationManager.startUpdatingLocation()
            self.locationManager.startMonitoringForRegion(locationTotrack);
            userdefalts.setValue("Yes", forKey: "Track")
            sender.setTitle("Untrack", forState: UIControlState.Normal)
        }
        else
        {
            userdefalts.setValue("No", forKey: "Track")
            var dictionaryGetfromPreviousTrack : NSDictionary = NSUserDefaults.standardUserDefaults().objectForKey("Dictionary") as NSDictionary
            var locationTotrack:CLRegion = self.getClregionFromDictionary(dictionaryGetfromPreviousTrack)
            self.locationManager.stopUpdatingLocation()
            self.locationManager.stopMonitoringForRegion(locationTotrack)
            sender.setTitle("Track", forState: UIControlState.Normal)
        }
    }
    
    func getClregionFromDictionary( dictionarytoLocation: NSDictionary) -> CLRegion
    {
        var title: NSString = dictionarytoLocation.valueForKey("title") as NSString
        var latitude: CLLocationDegrees  = dictionarytoLocation.valueForKey("latitude").doubleValue
        var longitude: CLLocationDegrees  = dictionarytoLocation.valueForKey("longitude").doubleValue
        var  centerCoordinate:CLLocationCoordinate2D  = CLLocationCoordinate2DMake(latitude, longitude)
        var  regionRadius:CLLocationDistance  = dictionarytoLocation.valueForKey("radius").doubleValue
        return  CLRegion(circularRegionWithCenter:centerCoordinate, radius: regionRadius, identifier: title)
    }
    
    func currentLocation()
    {
        var initialCoordinate:CLLocationCoordinate2D
        initialCoordinate = CLLocationCoordinate2D(latitude: self.locationManager.location.coordinate.latitude,longitude: self.locationManager.location.coordinate.longitude);
        self.coordinateLabel.text = NSString(format: "%f,%f", initialCoordinate.latitude ,initialCoordinate.longitude)
        let myRegion:MKCoordinateRegion  = MKCoordinateRegionMakeWithDistance(initialCoordinate, 300, 300);
        self.mapView.setRegion(myRegion,animated: true)
        self.mapView.centerCoordinate = initialCoordinate;
        self.mapView.userTrackingMode = MKUserTrackingMode.Follow;
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!)
    {
        locationManager.stopUpdatingLocation()
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: AnyObject[]!)
    {
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as CLLocation
        var coord = locationObj.coordinate
        println(coord.latitude)
        println(coord.longitude)
        self.currentLocation();
    }

     func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!)
     {
        var  stringURL:NSString  = "beacon://";
        var url:NSURL  = NSURL.URLWithString(stringURL)
        UIApplication.sharedApplication().openURL(url)
        var initialCoordinate:CLLocationCoordinate2D
        initialCoordinate = CLLocationCoordinate2D(latitude: self.locationManager.location.coordinate.latitude,longitude: self.locationManager.location.coordinate.longitude);
        self.coordinateLabel.text = NSString(format: "%f,%f", initialCoordinate.latitude ,initialCoordinate.longitude)
        let myRegion:MKCoordinateRegion  = MKCoordinateRegionMakeWithDistance(initialCoordinate, 300, 300);
        self.mapView.setRegion(myRegion,animated: true)
        self.mapView.centerCoordinate = initialCoordinate;
        self.mapView.userTrackingMode = MKUserTrackingMode.Follow;
     }
}