//
//  DriverViewController.swift
//  UserLoginAndRegistration
//
//  Created by Mark on 2/4/17.
//  Copyright © 2017 Sergey Kargopolov. All rights reserved.
//

import UIKit
import MapKit

class DriverViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, CarpoolDriverController , UITableViewDelegate , UITableViewDataSource{

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var acceptCarpoolBtn: UIButton!
    
    @IBOutlet weak var arrivedBtn: UIButton!
    private var locationManager = CLLocationManager()
    private var userLocation : CLLocationCoordinate2D?
    private var passengerLocation : CLLocationCoordinate2D?
    
    var message = ""
    var title1 = ""
    var requestAlive = true
    
    var passenger : [String] = []
    
    private var timer = Timer()
    
    @IBOutlet weak var tableview: UITableView!
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        return self.passenger.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UITableViewCell
        cell.textLabel?.text = self.passenger[indexPath.row]
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var cancel = UITableViewRowAction(style: .default, title: "Cancel", handler: {
            (action,indexPath) in
            
//            if self.acceptedCarpool{
            
                self.driverCanceledCarpool = true
                self.acceptCarpoolBtn.isHidden = true
                //            arrivedBtn.isHidden = true
            CarpoolDriverHandler.instace.statusRequest(status: "wait",arrived:false,name:self.passenger[indexPath.row])
                CarpoolDriverHandler.instace.cancelCarpoolForDriver(name: self.passenger[indexPath.row])
                self.passenger.remove(at: indexPath.row)
                self.tableview.deleteRows(at: [indexPath], with: .automatic)
                self.timer.invalidate()
//            }
            
        })
        
        var arrived = UITableViewRowAction(style: .default, title: "Arrived", handler: {
            (action,indexPath) in
            print(self.passenger[indexPath.row])
            
//            if self.acceptedCarpool{
                CarpoolDriverHandler.instace.arrived(name: self.passenger[indexPath.row])
                self.passenger.remove(at: indexPath.row)
                self.tableview.deleteRows(at: [indexPath], with: .automatic)
//            }
            
        })
        
        arrived.backgroundColor = UIColor.gray

        return [cancel,arrived]
        
    }
    
    func passengerCanceledCarpool(name:String){
        if !driverCanceledCarpool{
            CarpoolDriverHandler.instace.cancelCarpoolForDriver(name:name)
            self.acceptedCarpool = false
            self.acceptCarpoolBtn.isHidden = true
            self.arrivedBtn.isHidden = true
            carpoolRequest(title: "Carpool Canceled", message: "The Passenger Has Cenceled The Carpool", requestAlive: false)
            
        }
    }
    
    @IBAction func back(_ sender: Any) {
        if acceptedCarpool{
            acceptCarpoolBtn.isHidden = true
            arrivedBtn.isHidden = true
//            CarpoolDriverHandler.instace.cancelCarpoolForDriver()
            timer.invalidate()
        }
        
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func cancelCarpool(_ sender: Any) {
        if acceptedCarpool{
            
            driverCanceledCarpool = true
            acceptCarpoolBtn.isHidden = true
//            arrivedBtn.isHidden = true
            CarpoolDriverHandler.instace.statusRequest(status: "wait",arrived:false)
//            CarpoolDriverHandler.instace.cancelCarpoolForDriver()
            timer.invalidate()
            
        }
        
    }
    
    @IBAction func arrivedCarpool(_ sender: Any) {
        
        if acceptedCarpool{
            
//            driverCanceledCarpool = true
//            acceptCarpoolBtn.isHidden = true
//            arrivedBtn.isHidden = true
//            CarpoolDriverHandler.instace.statusRequest(status: "wait")
//            CarpoolDriverHandler.instace.cancelCarpoolForDriver()
//            FIRDatabase.database().reference().child(Constants.REQUEST).child(CarpoolDriverHandler.instace.uid_test).removeValue()
//            DBProvider.Instance.requestRef.child(CarpoolDriverHandler.instace.uid_test).removeValue()
            
//            CarpoolDriverHandler.instace.arrived()
//            timer.invalidate()
            
        }

        
    }
    
    func acceptCarpool(lat: Double, long: Double,no:Int,whereto:String,name:String) {
        
//        if !acceptedCarpool {
        
        self.passenger.append(name)
//        self.tableview.reloadData()
            print("tam mai mun in wa")
            print(whereto)
        self.message = "You have a reauest for a carpool at this location Lat: \(lat), Long: \(long) number \(no) where to \(whereto)"
        self.title1 = "Carpool Request"
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childAdded){ (snapshot: FIRDataSnapshot) in
            
            CarpoolDriverHandler.instace.uid_req = snapshot.key
            
            //            let value = snapshot.value as! NSDictionary
            //            let name = value[Constants.NAME] as! String
            
            //            CarpoolDriverHandler.instace.setuidReq(uid: snapshot.key)
            print("aaaaaaaaaa\(CarpoolDriverHandler.instace.uid_test)")
            print("bbbbbbbbbb\(CarpoolDriverHandler.instace.uid_req)")
            if(CarpoolDriverHandler.instace.uid_test == CarpoolDriverHandler.instace.uid_req){
                
                print("I'm coming")
//                print(message)
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
                
                let alert = UIAlertController(title: self.title1, message:self.message, preferredStyle: .alert)
//                print(message)
                if self.requestAlive {
                    print("GGEZ")
                    let accept = UIAlertAction(title: "Accept", style: .default, handler: { (alertAction: UIAlertAction) in
                        self.acceptedCarpool = true
                        self.acceptCarpoolBtn.isHidden = false
                        self.arrivedBtn.isHidden = false
                        //                CarpoolHandler.instace.observeMessageForPassenger()
                        //                CarpoolHandler.instace.delegate = self
                        CarpoolDriverHandler.instace.statusRequest(status: "busy",arrived:false)
                        
                        //                                self.timer = Timer.scheduledTimer(timeInterval:TimeInterval(10), target: self, selector: #selector(DriverViewController.updateDriverLocation), userInfo: nil, repeats: true)
                        CarpoolDriverHandler.instace.carpoolAccepted(lat: Double(self.userLocation!.latitude), long: self.userLocation!.longitude)
                        //test
                        //                                CarpoolDriverHandler.instace.updateSeat()
                        
                        
//                        self.passenger.append(name)
                        self.tableview.reloadData()
                        
                        
                    })
                    
//                    let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    
                    let cancel = UIAlertAction(title: "Cancel", style: .default, handler: {(alertAction: UIAlertAction) in
                        
                        CarpoolDriverHandler.instace.statusRequest(status: "wait",arrived:false)
                        self.passenger.removeLast()
                        
                    })
                    
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

            carpoolRequest(title: "Carpool Request", message: "You have a reauest for a carpool at this location Lat: \(lat), Long: \(long) number \(no) where to \(whereto)", requestAlive: true)
//        }

    }
    
    func carpoolCanceled() {
        acceptedCarpool = false
        acceptCarpoolBtn.isHidden = true
        arrivedBtn.isHidden = true
        
        
        
        timer.invalidate()
    }
    
    func arrived(name:String){
        let alert = UIAlertController(title: "Arrived", message: "Please rate me", preferredStyle: .alert)
        
        func handler(act:UIAlertAction) {
            print((act.title)!)
            
            var ratenaja = Double((act.title)!)
            
            let alert = UIAlertController(title: "Arrived", message: "Please rate me", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "comment"
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction:UIAlertAction) in
                let textField = alert.textFields![0] // Force unwrapping because we know it exists.
                print("Text field: \((textField.text)!)")
                
                DBProvider.Instance.passengerRef.child(name).observeSingleEvent(of: .value, with: {
                    (snapshot) in
                    let value = snapshot.value as! NSDictionary
                    
                    var comment = value[Constants.COMMENT] as! String
                    if comment != "" {
                        comment = "\(comment) ,\((textField.text)!)"
                    } else{
                        comment = textField.text!
                    }
                    
                    var rate = value[Constants.RATE] as! Double
                    var time = value[Constants.TIME] as! Double
                    
                    time = time + 1
                    rate = ((rate * (time-1)) + ratenaja!) / time
                    
                    print(rate)
                    print(time)
                    DBProvider.Instance.passengerRef.child(name).updateChildValues([Constants.COMMENT:comment,Constants.RATE:rate,Constants.TIME:time])
                })
                
            }))
            self.present(alert, animated: true, completion: nil)
            
            
        }
        for s in ["1", "2", "3", "4", "5"] {
            alert.addAction(
                UIAlertAction(title: s, style: .default, handler: handler))
        }
        
        self.present(alert, animated: true, completion: nil)
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
        
        
        
//        DBProvider.Instance.requestRef.observe(FIRDataEventType.childAdded){ (snapshot: FIRDataSnapshot) in
//            
//            CarpoolDriverHandler.instace.uid_req = snapshot.key
//            
////            let value = snapshot.value as! NSDictionary
////            let name = value[Constants.NAME] as! String
//            
////            CarpoolDriverHandler.instace.setuidReq(uid: snapshot.key)
//            print("aaaaaaaaaa\(CarpoolDriverHandler.instace.uid_test)")
//            print("bbbbbbbbbb\(CarpoolDriverHandler.instace.uid_req)")
//            if(CarpoolDriverHandler.instace.uid_test == CarpoolDriverHandler.instace.uid_req){
//                
//                print("I'm coming")
//                print(message)
////            if(name == CarpoolDriverHandler.instace.user){
//        
////                DBProvider.Instance.requestRef.child((CarpoolDriverHandler.instace.uid_req)).observeSingleEvent(of: .value, with: { (snapshot) in
////                    
////                    
////                    let value = snapshot.value as! NSDictionary
////                    
////                    let status = value[Constants.STATUS_CARPOOL] as! String
////                    //                    let status = "busy"
////                    print(status)
////                    if(status == "wait"){
////                        CarpoolDriverHandler.instace.setStatus(s:true)
//////                        print(self.status)
////                    }else{
////                        CarpoolDriverHandler.instace.setStatus(s:false)
//////                        print(self.status)
////                    }
////                    
////                    if (CarpoolDriverHandler.instace.getStatus()){
////                        print("eieieieieieieieieieieiei")
//                
//                        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
//                        print(message)
//                        if requestAlive {
//                            print("GGEZ")
//                            let accept = UIAlertAction(title: "Accept", style: .default, handler: { (alertAction: UIAlertAction) in
//                                
//                                self.acceptedCarpool = true
//                                self.acceptCarpoolBtn.isHidden = false
//                                //                CarpoolHandler.instace.observeMessageForPassenger()
//                                //                CarpoolHandler.instace.delegate = self
////                                CarpoolDriverHandler.instace.statusRequest(status: "busy")
//                                
////                                self.timer = Timer.scheduledTimer(timeInterval:TimeInterval(10), target: self, selector: #selector(DriverViewController.updateDriverLocation), userInfo: nil, repeats: true)
//                                
//                                CarpoolDriverHandler.instace.carpoolAccepted(lat: Double(self.userLocation!.latitude), long: self.userLocation!.longitude)
//                                //test
////                                CarpoolDriverHandler.instace.updateSeat()
//                                
//                            })
//                            
//                            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//                            
//                            //            pass.canCallCarpool(delegateCalled: false)
//                            
//                            alert.addAction(accept)
//                            alert.addAction(cancel)
//                            
//                        }
//                            
//                        else{
//                            
//                            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
//                            alert.addAction(ok)
//                        }
//                        
//                        self.present(alert, animated:true, completion: nil)
//            }
//            
//                    
////                })
////            }
//            //             self.checkTest()
//            
//        }

        
        
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
