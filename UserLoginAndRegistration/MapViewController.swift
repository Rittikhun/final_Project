//
//  MapViewController.swift
//  UserLoginAndRegistration
//
//  Created by CNC on 10/11/2559 BE.
//  Copyright © 2559 Sergey Kargopolov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseCore
import FirebaseDatabase

class MapViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
//    @IBOutlet weak var locationLabel: UITextView!
    
    @IBOutlet weak var map_item: UITabBarItem!
    
    let myGeo = CLGeocoder()
    
    var ref: FIRDatabaseReference!
    
    
    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        
        let myCGPoint = sender.location(in: mapView)
        
        
        let myMapPoint = mapView.convert(myCGPoint, toCoordinateFrom: mapView)
        
        var getLat: CLLocationDegrees = myMapPoint.latitude
        
        var getLon: CLLocationDegrees = myMapPoint.longitude
        
        var getLocation: CLLocation = CLLocation(latitude: getLat, longitude: getLon)
        
        myGeo.reverseGeocodeLocation(getLocation) { (placemark, error) in
            
            if error != nil {
                
                print("THERE WAS AN ERROR")
                
            } else {
                
                if let place = placemark?[0] {
                    
                    let title = "\(place.thoroughfare!)"
                    
                    let annotation = MKPointAnnotation()
                    
                    annotation.coordinate = myMapPoint
                    
                    annotation.title = "\(title)"
                    
                    annotation.subtitle = "Location \(sender.location(in: self.mapView))"
                    
                    print(annotation.subtitle)
                    
                    self.mapView.addAnnotation(annotation)
                    
                }
                
            }
            
        }
        
        
    }
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ref = FIRDatabase.database().reference()
        
        print("ssssssss")
        
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
//        self.locationManager.requestWhenInUseAuthorization()
//
//        self.locationManager.startUpdatingLocation()
//
//        
//        mapView.showsUserLocation = true
//
//        mapView.delegate = self
        
        
        CLLocationManager().requestAlwaysAuthorization()
        
        var image : UIImage? = UIImage(named:"map-icon.png")?.withRenderingMode(.alwaysOriginal)
        
        map_item.selectedImage = image
        
        mapView.setUserTrackingMode(.follow, animated: true)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        
        let myLocation = location.coordinate
        
        let post = [ "location": "\(myLocation)" ] as [NSString : Any]
        let childUpdates = ["/location/d": post]
        ref.updateChildValues(childUpdates)
        
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        
        self.mapView.setRegion(region, animated: true)
        
//        self.mapView.showsUserLocation = true
        
        //        var userLocation: CLLocation = locations[0] as! CLLocation
        //
        //        let long = userLocation.coordinate.longitude
        //
        //        let lat = userLocation.coordinate.latitude
        
        myGeo.reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            if ( error != nil) {
                
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                
                return
                
            }
            
            if (placemarks?.count)! > 0 {
                
                let pm = (placemarks?[0])! as CLPlacemark
                
//                self.displayLocationInfo(placemark: pm)
                
            } else {
                
                print("Problem with the date recieved from geocoder")
                
            }
            
        })
        
    }
    
//    func displayLocationInfo(placemark: CLPlacemark) {
//        
//        locationLabel.text = "\(placemark.thoroughfare!) , \(placemark.locality!), \(placemark.administrativeArea!), \(placemark.postalCode!), \(placemark.country!)"
//        
//    }
    
    
    
    //        CLGeocoder().reverseGeocodeLocation(location){
    //
    //            (placemark, error) in
    //
    //            if error != nil {
    //
    //                print("ERROR LOCATION")
    //
    //            }
    //
    //            else {
    //
    //                if let place = placemark?[0] {
    //
    //                    self.locationLabel.text = "\(place.subThoroughfare!) \(place.thoroughfare!) \(place.country!)"
    //
    //                    print(self.locationLabel.text)
    //
    //                }
    //
    //            }
    //
    //        }
    
    //    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
