//
//  PassengerViewController.swift
//  UserLoginAndRegistration
//
//  Created by Mark on 2/4/17.
//  Copyright © 2017 Sergey Kargopolov. All rights reserved.
//

import UIKit
import MapKit

class PassengerViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, CarpoolPassengerController {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var callBtn: UIButton!
    
    private var locationManager = CLLocationManager()
    private var userLocation : CLLocationCoordinate2D?
    private var DriverLocation : CLLocationCoordinate2D?
    
    private var timer = Timer()
    
    private var canCallCarpool = true
    private var passengerCancelRequest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializaLocationManager()
        CarpoolHandler.instace.observeMessageForPassenger()
        CarpoolHandler.instace.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    private func initializaLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        map.showsUserLocation = true
        
        map.setUserTrackingMode(.follow, animated: true)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locationManager.location?.coordinate{
            
            userLocation = CLLocationCoordinate2D(latitude:location.latitude , longitude:location.longitude )
            
            let region = MKCoordinateRegion(center: userLocation!,span: MKCoordinateSpan(latitudeDelta:0.01,longitudeDelta:0.01))
            
            map.setRegion(region, animated: true)
            
            map.removeAnnotations(map.annotations)
            
            if DriverLocation != nil {
                if !canCallCarpool {
                    let driverAnnotation = MKPointAnnotation()
                    driverAnnotation.coordinate = DriverLocation!
                    driverAnnotation.title = "Driver Location"
                    map.addAnnotation(driverAnnotation)
                }
            }
            
        }
        
    }
    
    func canCallCarpool(delegateCalled: Bool) {
        if delegateCalled {
            callBtn.setTitle("Cancel Carpool", for: UIControlState.normal)
            canCallCarpool = false
        }
        else{
            callBtn.setTitle("Call Carpool", for: UIControlState.normal)
            canCallCarpool = true
        }
    }
    
    func driverAcceptedRequest(requestAccepted: Bool, drivername: String) {
        
        if !passengerCancelRequest {
            if requestAccepted {
                alertTheUser(title: "Carpool Accepted", message: "\(drivername) Accepted Your Carpool Request")
            }
            else {
                CarpoolHandler.instace.cancelCarpool()
                timer.invalidate()
                alertTheUser(title: "Carpool Canceled", message: "\(drivername) Canceled Carpool Request")
            }
        }
        
        passengerCancelRequest = false
        
    }
    
    func updateDriverLocation(lat: Double, long: Double) {
        DriverLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    func updatePassengerLocation() {
        CarpoolHandler.instace.updatePassengerLocation(lat: userLocation!.latitude, long: userLocation!.longitude)
    }
    
    private func alertTheUser(title:String ,message:String){
        let alert = UIAlertController(title:title ,message:message ,preferredStyle: .alert)
        let ok = UIAlertAction(title:"OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func back(_ sender: Any) {
        
        if !canCallCarpool{
            CarpoolHandler.instace.cancelCarpool()
            timer.invalidate()
        }
        self.dismiss(animated: true, completion: nil)

    }

    @IBAction func callDriver(_ sender: Any) {
        
        if userLocation != nil {
            if canCallCarpool {
                CarpoolHandler.instace.requestCarpool(latitude: Double(userLocation!.latitude), longitude: Double(userLocation!.longitude))
                
                timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(PassengerViewController.updatePassengerLocation), userInfo: nil, repeats: true)
            }
            else {
                passengerCancelRequest = true
                CarpoolHandler.instace.cancelCarpool()
                timer.invalidate()
            }
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
