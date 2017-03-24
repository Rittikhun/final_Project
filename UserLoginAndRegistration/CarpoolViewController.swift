//
//  CarpoolViewController.swift
//  UserLoginAndRegistration
//
//  Created by Mark on 2/4/17.
//  Copyright © 2017 Sergey Kargopolov. All rights reserved.
//

import UIKit
import MapKit

class CarpoolViewController: UIViewController, CLLocationManagerDelegate,MKMapViewDelegate {
    
    @IBOutlet weak var map_item: UITabBarItem!
    private var locationManager = CLLocationManager()
    private var userLocation : CLLocationCoordinate2D?
    private var name = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializaLocationManager()
        
        var image : UIImage? = UIImage(named:"map-icon.png")?.withRenderingMode(.alwaysOriginal)
        
        map_item.selectedImage = image
        
        DBProvider.Instance.userRef.child((DBProvider.Instance.username?.uid)!).observeSingleEvent(of: .value, with: {
            (snapshot) in
            let value = snapshot.value as! NSDictionary
            self.name = value[Constants.NAME] as! String
        })

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initializaLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locationManager.location?.coordinate{
            
            userLocation = CLLocationCoordinate2D(latitude:location.latitude , longitude:location.longitude )
            
        }
        
        updateLocation()
        
        if UIApplication.shared.applicationState == .active {
        } else {
            updateLocation()
//            updateDriverLocation()
        }
        
    }
    
    func updateLocation(){
        DBProvider.Instance.locationRef.child((DBProvider.Instance.username?.uid)!).updateChildValues([Constants.NAME:self.name,Constants.LATITUDE:userLocation?.latitude,Constants.LONGITUDE:userLocation?.longitude])
    }
    
    @IBAction func passengerBtn(_ sender: Any) {

        DBProvider.Instance.statusCarpool(status: "passenger")
        
    }

    @IBAction func driverBtn(_ sender: Any) {
        
        DBProvider.Instance.statusCarpool(status: "driver")
        
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
