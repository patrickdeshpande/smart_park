//
//  ViewController.swift
//  Smart Park
//
//  Created by Patrick Deshpande on 7/15/16.
//  Copyright © 2016 Patrick Deshpande. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class customPin: MKPinAnnotationView {
    var meter: parkingMeter!
}



class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapview: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapview.delegate = self
        mapview.userTrackingMode = .None
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(ViewController.getNearbyParkingSpots))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Organize, target: self, action: #selector(ViewController.analyze))
        spam()
                
    }
    
    func analyze() {
        let second = self.storyboard!.instantiateViewControllerWithIdentifier("analysisView") as! analysisView
        self.navigationController?.pushViewController(second, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var locationManager = CLLocationManager()
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapview.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    var firstScroll = false
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        //scroll to the user's position here
        if firstScroll == false {
            centerMapOnLocation(userLocation.location!)
            getNearbyParkingSpots()
            firstScroll = true
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius:CLLocationDistance = 200
        var coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapview.setRegion(coordinateRegion, animated: true)
    }
    
    func handleResponse(data: NSData?, response: NSURLResponse?, err: NSError?){
        if err != nil {
            print("Error making request: \(err)")
        }
        do {
            let responseObject: AnyObject? =  try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            print("response object: \(responseObject)")
            
            if let dict = responseObject as? NSDictionary {
                print("status for claim: \(dict["Status"])")
                
            }
            getNearbyParkingSpots()
        }
        catch let error as NSError {
            print("Error trying to parse JSON: \(error)")
        }
        
        
    }
    
    // When user taps on the disclosure button you can perform a segue to navigate to another view controller
    var claimed = false
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if control == view.rightCalloutAccessoryView{
            //print(view.annotation!.coordinate.latitude)
            //print(view.annotation!.coordinate.longitude)
            var temp: parkingMeter!
            for i in arrOfMeters {
                if i.latitude == view.annotation!.coordinate.latitude && i.longitude == view.annotation!.coordinate.longitude {
                    //found the meter
                    temp = i
                    break
                }
            }
            if temp != nil {
                if temp.userID == nil {
                    //claim the parking spot
                    var req = EZHttp(inurl: "http://www.ramp9.com/smart_meter/claim_parking_spot.php", inparam: "meterID=\(temp.id)&userID=\(UIDevice.currentDevice().identifierForVendor!.UUIDString)", inmethod: nil, completion: handleResponse)
                    claimed = true
                    print("claiming parking spot")
                    for i in arrOfMeters {
                        if i.latitude == temp.latitude && i.longitude == temp.longitude {
                            i.userID = UIDevice.currentDevice().identifierForVendor!.UUIDString
                                                    }
                    }
                    
                }
                else {
                    var req = EZHttp(inurl: "http://www.ramp9.com/smart_meter/release_parking_spot.php", inparam: "meterID=\(temp.id)&userID=\(UIDevice.currentDevice().identifierForVendor!.UUIDString)", inmethod: nil, completion: handleResponse)
                    for i in arrOfMeters {
                        if i.latitude == temp.latitude && i.longitude == temp.longitude {
                            i.userID = nil
                        }
                    }
                }
                getNearbyParkingSpots()
            }
            
            
        }
    }
    
    // Here we add disclosure button inside annotation window
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        //print("viewForannotation")
        if annotation is MKUserLocation {
            //return nil
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        
        if pinView == nil {
            //println("Pinview was nil")
            pinView = customPin.init(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            //pinView!.animatesDrop = true
        }
        
        let button = UIButton(type: UIButtonType.DetailDisclosure) as UIButton // button with info sign in it
        
        pinView?.rightCalloutAccessoryView = button
        
        
        return pinView
    }
    
    
    func displayParkingSpots(){
        for meter in arrOfMeters {
            let location = CLLocationCoordinate2DMake(meter.latitude, meter.longitude)
            let dropPin = MKPointAnnotation()
            dropPin.coordinate = location
            
            if meter.userID == nil {
                dropPin.title = "Claim"
            }
            else if meter.userID == UIDevice.currentDevice().identifierForVendor!.UUIDString {
                print(meter.userID)
                dropPin.title = "Release"
            }

            dispatch_async(dispatch_get_main_queue()){
                self.mapview.addAnnotation(dropPin)
            }
        }
    }
    
    
    
    var arrOfMeters: [parkingMeter] = [parkingMeter]()
    func nearbySpotsLoaded(data: NSData?, response: NSURLResponse?, err: NSError?){
        if err != nil {
            print("Error making request: \(err)")
        }
        do {
            let responseObject: AnyObject? =  try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            print("response object: \(responseObject)")
            arrOfMeters.removeAll()
            if let dict = responseObject as? [NSDictionary] {
                for i: NSDictionary in dict {
                
                    let tempID = i["userID"] as? String
                    print(tempID)
                    let tempArrive = i["arrived"] as? Bool
                    print(tempArrive)
                    let tempMeter = parkingMeter(id: (i["id"]?.integerValue)!, latitude: (i["meterLatitude"]?.doubleValue)!, longitude: (i["meterLongitude"]?.doubleValue)!, userID: tempID, arrived: tempArrive)
                    arrOfMeters.append(tempMeter)
                }
                displayParkingSpots()
                
            }
        }
        catch let error as NSError {
            print("Error trying to parse JSON: \(error)")
        }
        
        
    }
    
    func presentArrival(data: NSData?, response: NSURLResponse?, err: NSError?) {
        if err != nil {
            print("Error making request: \(err)")
        }
        do {
            let responseObject: AnyObject? =  try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            print("response object: \(responseObject)")
            if let dict = responseObject as? NSDictionary {
                print("string value: \(dict["value"] as? NSString)")
                if (dict["value"] as? NSString)! == "true" {
                    timer.invalidate()
                    let alertController = UIAlertController(title: "Arrival", message:
                        "You have arrived!", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
        catch let error as NSError {
            print("Error trying to parse JSON: \(error)")
        }
    }
    
    func apiCall() {
        if claimed == false {
            return
        }
        print("helppppp")
         var req = EZHttp(inurl: "http://www.ramp9.com/smart_meter/get_m2x_data.php", inparam: nil, inmethod: "POST", completion: presentArrival)
    }
    
    var timer = NSTimer()
    func spam() {
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "apiCall", userInfo: nil, repeats: true)
        
    }
    
    

    
    func getNearbyParkingSpots(){
        mapview.removeAnnotations(mapview.annotations)

        var lat = self.mapview.userLocation.location!.coordinate.latitude
        var lon = self.mapview.userLocation.location!.coordinate.longitude
        print("lat: \(lat), lon: \(lon)")
        var req = EZHttp(inurl: "http://www.ramp9.com/smart_meter/get_nearby_parking.php", inparam: "userLatitude=\(lat)&userLongitude=\(lon)&userID=\(UIDevice.currentDevice().identifierForVendor!.UUIDString)", inmethod: nil, completion: nearbySpotsLoaded)
    }
    
    
    

}

