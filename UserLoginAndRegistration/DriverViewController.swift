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
    
//    var pass = PassengerViewController()
    
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
        
        if UIApplication.shared.applicationState == .active {
            //                mapView.showAnnotations(self.locations, animated: true)
        } else {
            updateDriverLocation()
//            print("App is backgrounded. New location is %@", mostRecentLocation)
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
            CarpoolDriverHandler.instace.statusRequest(status: "wait")
            CarpoolDriverHandler.instace.cancelCarpoolForDriver()
            timer.invalidate()
            
        }
        
    }
    
    func acceptCarpool(lat: Double, long: Double,no:Int,whereto:String) {
        
//        if !acceptedCarpool {
            print("tam mai mun in wa")
            print(whereto)
            carpoolRequest(title: "Carpool Request", message: "You have a reauest for a carpool at this location Lat: \(lat), Long: \(long) number \(no) where to \(whereto)", requestAlive: true)
//        }

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
//        CarpoolDriverHandler.instace.check()
//        print(CarpoolDriverHandler.instace.check())
//        print("kkkk \(CarpoolDriverHandler.instace.uid_req)")
//        CarpoolDriverHandler.instace.checkTest()
//        print("status naja \(CarpoolDriverHandler.instace.status)")
        
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childAdded){ (snapshot: FIRDataSnapshot) in
            
            CarpoolDriverHandler.instace.uid_req = snapshot.key
            
//            let value = snapshot.value as! NSDictionary
//            let name = value[Constants.NAME] as! String
            
//            CarpoolDriverHandler.instace.setuidReq(uid: snapshot.key)
            print("aaaaaaaaaa\(CarpoolDriverHandler.instace.uid_test)")
            print("bbbbbbbbbb\(CarpoolDriverHandler.instace.uid_req)")
            if(CarpoolDriverHandler.instace.uid_test == CarpoolDriverHandler.instace.uid_req){
                
                print("I'm coming")
                print(message)
//            if(name == CarpoolDriverHandler.instace.user){
        
//                DBProvider.Instance.requestRef.child((CarpoolDriverHandler.instace.uid_req)).observeSingleEvent(of: .value, with: { (snapshot) in
//                    
//                    
//                    let value = snapshot.value as! NSDictionary
//                    
//                    let status = value[Constants.STATUS_CARPOOL] as! String
//                    //                    let status = "busy"
//                    print(status)
//                    if(status == "wait"){
//                        CarpoolDriverHandler.instace.setStatus(s:true)
////                        print(self.status)
//                    }else{
//                        CarpoolDriverHandler.instace.setStatus(s:false)
////                        print(self.status)
//                    }
//                    
//                    if (CarpoolDriverHandler.instace.getStatus()){
//                        print("eieieieieieieieieieieiei")
                
                        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
                        print(message)
                        if requestAlive {
                            print("GGEZ")
                            let accept = UIAlertAction(title: "Accept", style: .default, handler: { (alertAction: UIAlertAction) in
                                
                                self.acceptedCarpool = true
                                self.acceptCarpoolBtn.isHidden = false
                                //                CarpoolHandler.instace.observeMessageForPassenger()
                                //                CarpoolHandler.instace.delegate = self
//                                CarpoolDriverHandler.instace.statusRequest(status: "busy")
                                
                                self.timer = Timer.scheduledTimer(timeInterval:TimeInterval(10), target: self, selector: #selector(DriverViewController.updateDriverLocation), userInfo: nil, repeats: true)
                                
                                CarpoolDriverHandler.instace.carpoolAccepted(lat: Double(self.userLocation!.latitude), long: self.userLocation!.longitude)
                                //test
//                                CarpoolDriverHandler.instace.updateSeat()
                                
                            })
                            
                            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                            
                            //            pass.canCallCarpool(delegateCalled: false)
                            
                            alert.addAction(accept)
                            alert.addAction(cancel)
                            
                        }
                            
                        else{
                            
                            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(ok)
                        }
                        
                        self.present(alert, animated:true, completion: nil)
            }
            
                    
//                })
//            }
            //             self.checkTest()
            
        }

//        if (CarpoolDriverHandler.instace.getStatus()){
//            print("eieieieieieieieieieieiei")
//        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
//        
//        if requestAlive {
//            let accept = UIAlertAction(title: "Accept", style: .default, handler: { (alertAction: UIAlertAction) in
//            
//                self.acceptedCarpool = true
//                self.acceptCarpoolBtn.isHidden = false
////                CarpoolHandler.instace.observeMessageForPassenger()
////                CarpoolHandler.instace.delegate = self
//                CarpoolDriverHandler.instace.statusRequest(status: "busy")
//                
//                self.timer = Timer.scheduledTimer(timeInterval:TimeInterval(10), target: self, selector: #selector(DriverViewController.updateDriverLocation), userInfo: nil, repeats: true)
//                
//                CarpoolDriverHandler.instace.carpoolAccepted(lat: Double(self.userLocation!.latitude), long: self.userLocation!.longitude)
//                //test
////                CarpoolHandler.instace.cancelCarpool()
//                
//            })
//            
//            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//            
////            pass.canCallCarpool(delegateCalled: false)
//            
//            alert.addAction(accept)
//            alert.addAction(cancel)
//        }
//        
//        else{
//            
//            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
//            alert.addAction(ok)
//        }
//        
//        present(alert, animated:true, completion: nil)
//        }
        
    }
    
    
    
    //custom pin
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var v : MKAnnotationView! = nil
        let ident = "pin"
        v = mapView.dequeueReusableAnnotationView(withIdentifier: ident)
        if let t = annotation.title, t == "passenger" {
            if v == nil {
                v = MKAnnotationView(annotation: annotation,reuseIdentifier:ident)
                v.image = UIImage(named: "061-128")
                v.bounds.size.height /= 3.0
                v.bounds.size.width /= 3.0
                v.centerOffset = CGPoint(x:0,y:-20)
                v.canShowCallout = true
            }
            v.annotation = annotation
        }
        
        
        return v
        
    }


    
//    func map(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
//    {
//        if !(annotation is MKPointAnnotation) {
//            return nil
//        }
//        
//        let annotationIdentifier = "AnnotationIdentifier"
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
//        
//        if annotationView == nil {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
//            annotationView!.canShowCallout = true
//        }
//        else {
//            annotationView!.annotation = annotation
//        }
//        
//        let pinImage = UIImage(named: "map-icon")
//        annotationView!.image = pinImage
//        return annotationView
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
