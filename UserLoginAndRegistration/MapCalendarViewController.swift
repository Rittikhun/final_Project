//
//  MapViewController.swift
//  Map
//
//  Created by iOS Dev on 12/19/2559 BE.
//  Copyright © 2559 iOS Dev. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapCalendarViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate,UISearchBarDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var searchController:UISearchController!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    var annotation:MKAnnotation!
    
    //    @IBOutlet weak var locationLabel: UITextView!
    
    let myGeo = CLGeocoder()
    
    var location = ""
    
    @IBAction func showSearchBar(_ sender: UIButton) {
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
        
        
    }
    
    @IBAction func Back(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
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
                self.mapView.removeAnnotations(self.mapView.annotations)
                if let place = placemark?[0] {
                    
                    let title = "\(place.thoroughfare!) \(place.locality!)"
                    
                    self.setLocation(location: "\(place.thoroughfare!) \(place.locality!)")
                    
                    let annotation = MKPointAnnotation()
                    
                    annotation.coordinate = myMapPoint
                    
                    annotation.title = "\(title)"
                    
                    annotation.subtitle = "Location \(sender.location(in: self.mapView))"
                    
                    //                    print(annotation.subtitle)
                    
                    self.mapView.addAnnotation(annotation)
                    
                }
                
            }
            
        }
        
        
    }
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
//        self.locationManager.requestWhenInUseAuthorization()
        
//        self.locationManager.startUpdatingLocation()
        
        
//        mapView.showsUserLocation = true
        
//        mapView.delegate = self
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        searchController = UISearchController(searchResultsController: locationSearchTable)
        searchController?.searchResultsUpdater = locationSearchTable
        let searchBar = searchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = searchController?.searchBar
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        mapView.setUserTrackingMode(.follow, animated: true)
        
        
        
//        CLLocationManager().requestAlwaysAuthorization()
        
        //        let longPress = UILongPressGestureRecognizer(target: self, action: "longPress:")
        //        longPress.minimumPressDuration = 2
        //        self.mapView.addGestureRecognizer(longPress)
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        
        let myLocation = location.coordinate
        
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        
        self.mapView.setRegion(region, animated: true)
        
//        self.mapView.showsUserLocation = true
        
        myGeo.reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            if ( error != nil) {
                
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                
                return
                
            }
            
            if (placemarks?.count)! > 0 {
                
                //                let pm = (placemarks?[0])! as CLPlacemark
                //
                //                self.displayLocationInfo(placemark: pm)
                
            } else {
                
                print("Problem with the date recieved from geocoder")
                
            }
            
        })
        
    }
    
    func setLocation(location:String) {
        
        self.location = location
        
        print("kuykuykuy\(self.location)")
    }
    
    @IBAction func clearPin(_ sender: UIButton) {
        
        mapView.removeAnnotations(mapView.annotations)
        
    }
    //    func displayLocationInfo(placemark: CLPlacemark) {
    //
    //        locationLabel.text = "\(placemark.thoroughfare!) , \(placemark.locality!), \(placemark.administrativeArea!), \(placemark.postalCode!), \(placemark.country!)"
    //
    //    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        //1
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        if self.mapView.annotations.count != 0{
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        //
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            //3
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.setLocation(location:searchBar.text!)
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        }
    }
    
    @IBAction func AddLocation(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "unwind", sender: self)
        
        //        self.dismiss(animated: true, completion:nil);
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
}
