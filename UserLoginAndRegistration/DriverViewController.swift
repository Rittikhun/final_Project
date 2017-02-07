//
//  DriverViewController.swift
//  UserLoginAndRegistration
//
//  Created by Mark on 2/4/17.
//  Copyright © 2017 Sergey Kargopolov. All rights reserved.
//

import UIKit
import MapKit

class DriverViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, CarpoolDriverController {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var acceptCarpoolBtn: UIButton!
    
    private var locationManager = CLLocationManager()
    private var userLocation : CLLocationCoordinate2D?
    private var passengerLocation : CLLocationCoordinate2D?
    
    private var timer = Timer()
    
    private var acceptedCarpool = false
    private var driverCanceledCarpool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializaLocationManager()
        
        CarpoolDriverHandler.instace.delegate = self
        CarpoolDriverHandler.instace.observeMessagesForDriver()

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
            
            if passengerLocation != nil {
                
                if acceptedCarpool {
                    let passengerAnnotation = MKPointAnnotation()
                    passengerAnnotation.coordinate = passengerLocation!
                    passengerAnnotation.title = "passenger"
                    map.addAnnotation(passengerAnnotation)
                }
                
            }
            
        }
        
    }
    
    func passengerCanceledCarpool(){
        if !driverCanceledCarpool{
            CarpoolDriverHandler.instace.cancelCarpoolForDriver()
            self.acceptedCarpool = false
            self.acceptCarpoolBtn.isHidden = true
            carpoolRequest(title: "Carpool Canceled", message: "The Passenger Has Cenceled The Carpool", requestAlive: false)
            
        }
    }
    
    @IBAction func back(_ sender: Any) {
        if acceptedCarpool{
            acceptCarpoolBtn.isHidden = true
            CarpoolDriverHandler.instace.cancelCarpoolForDriver()
            timer.invalidate()
        }
        
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func cancelCarpool(_ sender: Any) {
        if acceptedCarpool{
            
            driverCanceledCarpool = true
            acceptCarpoolBtn.isHidden = true
            CarpoolDriverHandler.instace.cancelCarpoolForDriver()
            timer.invalidate()
            
        }
        
    }
    
    func acceptCarpool(lat: Double, long: Double) {
        
        if !acceptedCarpool {
            carpoolRequest(title: "Carpool Request", message: "You have a reauest for a carpool at this location Lat: \(lat), Long: \(long)", requestAlive: true)
        }
        
    }
    
    func carpoolCanceled() {
        acceptedCarpool = false
        acceptCarpoolBtn.isHidden = true
        timer.invalidate()
    }
    
    func updatePassengerLocation(lat: Double, long: Double) {
        passengerLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    func updateDriverLocation(){
        CarpoolDriverHandler.instace.updateDriverLocation(lat: userLocation!.latitude, long: userLocation!.longitude)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func carpoolRequest(title: String,message: String,requestAlive: Bool){
        
        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
        
        if requestAlive {
            let accept = UIAlertAction(title: "Accept", style: .default, handler: { (alertAction: UIAlertAction) in
            
                self.acceptedCarpool = true
                self.acceptCarpoolBtn.isHidden = false
                
                self.timer = Timer.scheduledTimer(timeInterval:TimeInterval(10), target: self, selector: #selector(DriverViewController.updateDriverLocation), userInfo: nil, repeats: true)
                
                CarpoolDriverHandler.instace.carpoolAccepted(lat: Double(self.userLocation!.latitude), long: self.userLocation!.longitude)
                
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            
            alert.addAction(accept)
            alert.addAction(cancel)
        }
        
        else{
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
        }
        
        present(alert, animated:true, completion: nil)
        
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