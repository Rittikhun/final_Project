//
//  PassengerViewController.swift
//  UserLoginAndRegistration
//
//  Created by Mark on 2/4/17.
//  Copyright © 2017 Sergey Kargopolov. All rights reserved.
//

import UIKit
import MapKit

//protocol HandleMapSearch {
//    func dropPinZoomIn(_ placemark:MKPlacemark)
//}
class PassengerViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, CarpoolPassengerController/*,UISearchBarDelegate*/,HandleMapSearch,UIPickerViewDelegate,UIPickerViewDataSource{

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var callBtn: UIButton!
    
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var locationToGo: UITextField!
    
    @IBOutlet weak var rateText: UITextField!
    
//    var searchController:UISearchController!
//    var localSearchRequest:MKLocalSearchRequest!
//    var localSearch:MKLocalSearch!
//    var localSearchResponse:MKLocalSearchResponse!
    
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    
    var rate = ["0","1","2","3","4","5"]
    
    var no = 1 ;
    
//    var d = DriverViewController()
    
    private var locationManager = CLLocationManager()
    private var userLocation : CLLocationCoordinate2D?
    private var DriverLocation : CLLocationCoordinate2D?
    
    private var picker = UIPickerView()
    
    private var timer = Timer()
    
    private var canCallCarpool = true
    private var passengerCancelRequest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializaLocationManager()
        CarpoolHandler.instace.observeMessageForPassenger()
        CarpoolHandler.instace.delegate = self
        
        picker.delegate = self
        picker.dataSource = self
        
        rateText.inputView = picker
        
//        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
//        searchController = UISearchController(searchResultsController: locationSearchTable)
//        searchController?.searchResultsUpdater = locationSearchTable
//        let searchBar = searchController!.searchBar
//        searchBar.sizeToFit()
//        searchBar.placeholder = "Search for places"
//        navigationItem.titleView = searchController?.searchBar
//        searchController?.hidesNavigationBarDuringPresentation = false
//        searchController?.dimsBackgroundDuringPresentation = true
//        definesPresentationContext = true
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = map
        locationSearchTable.handleMapSearchDelegate = self

        //background location update
        self.locationManager.allowsBackgroundLocationUpdates = true
        
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
    
    func dropPinZoomIn(_ placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
//        map.removeAnnotations(map.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        locationToGo.text = "\(annotation.title!)"
//        self.setLocation(location: "\(annotation.title!)")
//        if let city = placemark.locality,
//            let state = placemark.administrativeArea {
//            annotation.subtitle = "\(city) \(state)"
//        }
//        map.addAnnotation(annotation)
//        let span = MKCoordinateSpanMake(0.05, 0.05)
//        let region = MKCoordinateRegionMake(placemark.coordinate, span)
//        map.setRegion(region, animated: true)
    }
    
    func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
//    @IBAction func showSearchBar(_ sender: UIButton) {
//        
//        searchController = UISearchController(searchResultsController: nil)
//        searchController.hidesNavigationBarDuringPresentation = false
//        self.searchController.searchBar.delegate = self
//        present(searchController, animated: true, completion: nil)
//        
//        
//    }
    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
//        //1
//        searchBar.resignFirstResponder()
//        dismiss(animated: true, completion: nil)
////        if self.mapView.annotations.count != 0{
////            annotation = self.mapView.annotations[0]
////            self.mapView.removeAnnotation(annotation)
////        }
//        //
//        localSearchRequest = MKLocalSearchRequest()
//        localSearchRequest.naturalLanguageQuery = searchBar.text
//        localSearch = MKLocalSearch(request: localSearchRequest)
//        localSearch.start { (localSearchResponse, error) -> Void in
//            
//            if localSearchResponse == nil{
//                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
//                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alertController, animated: true, completion: nil)
//                return
//            }
//            //3
////            self.pointAnnotation = MKPointAnnotation()
////            self.pointAnnotation.title = searchBar.text
////            self.setLocation(location:searchBar.text!)
////            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
////            
////            
////            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
////            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
////            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
//            
//            self.locationToGo.text = searchBar.text
//        }
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let mostRecentLocation = locations.last else {
            return
        }
        
        if let location = locationManager.location?.coordinate{
            
            userLocation = CLLocationCoordinate2D(latitude:location.latitude , longitude:location.longitude )
            
//            print(userLocation)
            
            
            
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
            
            if UIApplication.shared.applicationState == .active {
                //                mapView.showAnnotations(self.locations, animated: true)
            } else {
                updatePassengerLocation()
//                print("App is backgrounded. New location is %@", mostRecentLocation)
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
                //arrived
                if CarpoolHandler.instace.statusArrived {
                    canCallCarpool(delegateCalled: false)
                    timer.invalidate()
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
                            
                            DBProvider.Instance.driverRef.child(drivername).observeSingleEvent(of: .value, with: {
                                (snapshot) in
                                let value = snapshot.value as! NSDictionary
                                
                                var comment = value[Constants.COMMENT] as! String
                                if comment != "" {
                                    comment = "\(comment) ,\((textField.text)!)"
                                }
                                
                                var rate = value[Constants.RATE] as! String
                                var time = value[Constants.TIME] as! Double
                                var rateavg = value[Constants.RATEAVG] as! Double
                                
                                if rate != "" {
                                    rate = "\(rate) ,\(ratenaja!)"
                                } else{
                                    rate = "\(ratenaja!)"
                                }
                                
                                
                                time = time + 1
                                rateavg = ((rateavg * (time-1)) + ratenaja!) / time
                                
                                
                                DBProvider.Instance.driverRef.child(drivername).updateChildValues([Constants.COMMENT:comment,Constants.RATE:rate,Constants.TIME:time,Constants.RATEAVG:rateavg])
                            })
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                        
                    }
                    for s in ["1", "2", "3", "4", "5"] {
                        alert.addAction(
                            UIAlertAction(title: s, style: .default, handler: handler))
                    }
                    
                    self.present(alert, animated: true, completion: nil)

                    
                } else{
                    CarpoolHandler.instace.cancelCarpool()
                    //test
                    canCallCarpool(delegateCalled: false)
                    timer.invalidate()
                    alertTheUser(title: "Carpool Canceled", message: "\(drivername) Canceled Carpool Request")
                }
                
//                CarpoolHandler.instace.cancelCarpool()
//                //test
//                canCallCarpool(delegateCalled: false)
//                timer.invalidate()
//                alertTheUser(title: "Carpool Canceled", message: "\(drivername) Canceled Carpool Request")
            }
        }
        
        passengerCancelRequest = false
        
    }
    
    func updateDriverLocation(lat: Double, long: Double) {
        DriverLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
//        print(DriverLocation)
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
    
    
//    @IBAction func back(_ sender: Any) {
//        
//        if !canCallCarpool{
//            CarpoolHandler.instace.cancelCarpool()
//            timer.invalidate()
//        }
//        self.dismiss(animated: true, completion: nil)
//
//    }
    
    @IBAction func back(_ sender: Any) {
        if !canCallCarpool{
            CarpoolHandler.instace.cancelCarpool()
            timer.invalidate()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func re(_ sender: Any) {
        
        if(no > 1){
            no = no - 1
            number.text = "\(no)"
        } else{
            number.text = "1"
            
        }
        
    }
    
    
    @IBAction func add(_ sender: Any) {
        
//        print(no)
        if no != 4 {
            no = no + 1
            number.text = "\(no)"
//        print(number.text)
        }
        
    }

    @IBAction func callDriver(_ sender: Any) {
        if (locationToGo.text != "" && rateText.text != "") {
        if self.userLocation != nil {
            if self.canCallCarpool {
                
                self.canCallCarpool(delegateCalled: self.canCallCarpool)
                CarpoolHandler.instace.requestCarpool(latitude: Double(self.userLocation!.latitude), longitude: Double(self.userLocation!.longitude),no: no ,whereto:self.locationToGo.text!,rate:Double(rateText.text!)!)
                
//                CarpoolHandler.instace.statusRequest(status: "eiei")
                
                timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(PassengerViewController.updatePassengerLocation), userInfo: nil, repeats: true)
            }
            else {
                canCallCarpool(delegateCalled: canCallCarpool)
//                d.carpoolCanceled()
                passengerCancelRequest = true
                CarpoolHandler.instace.cancelCarpool()
                timer.invalidate()
            }
        }
        }
        else{
            alertTheUser(title: "ลืมอะไรอ๊ะเปล่า", message: "ยังไม่ได้ระบุสถานที่เดินทางหรือคะแนนขั้นต่ำ")
        }
        
        
        
    }
    
    //custom image
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var v : MKAnnotationView! = nil
        let ident = "pin"
        v = mapView.dequeueReusableAnnotationView(withIdentifier: ident)
        if let t = annotation.title, t == "Driver Location" {
            if v == nil {
                v = MKAnnotationView(annotation: annotation,reuseIdentifier:ident)
                v.image = UIImage(named: "icon_car-128")
                v.bounds.size.height /= 3.0
                v.bounds.size.width /= 3.0
                v.centerOffset = CGPoint(x:0,y:-20)
                v.canShowCallout = true
            }
            v.annotation = annotation
        }
        
        
        return v
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rate.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rate[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        rateText.text = rate[row]
        self.view.endEditing(false)
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
//        let pinImage = UIImage(named: "customPinImage")
//        annotationView!.image = pinImage
//        return annotationView
//    }

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
