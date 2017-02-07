//
//  CarpoolHandler.swift
//  UserLoginAndRegistration
//
//  Created by Mark on 2/4/17.
//  Copyright © 2017 Sergey Kargopolov. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol CarpoolPassengerController : class{
    func canCallCarpool(delegateCalled: Bool)
    func driverAcceptedRequest(requestAccepted: Bool, drivername:String )
    func updateDriverLocation(lat: Double, long: Double)
}
class CarpoolHandler{
    
    private static let instance = CarpoolHandler()
    
    weak var delegate: CarpoolPassengerController?
    
    var user = ""
    var uid_req = ""
    var driver = ""
    
    static var instace: CarpoolHandler {
        return instance
    }
    
    func requestCarpool(latitude: Double , longitude: Double){
        
        let username = FIRAuth.auth()?.currentUser
        
        let ref = FIRDatabase.database().reference()
        
        print("uid: \(FIRAuth.auth()?.currentUser?.uid)")
        
        //                    self.performSegue(withIdentifier: "homeView", sender: self);
        
        ref.child("users").child((username!.uid)).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as! NSDictionary
            
            let usernamef = value["name"] as! String
            
            CarpoolHandler.instace.user = usernamef
            
            let data : Dictionary<String, Any> = [Constants.NAME: self.user, Constants.LATITUDE: latitude , Constants.LONGITUDE: longitude]
            
            DBProvider.Instance.requestRef.childByAutoId().setValue(data)
            
        })
        
        
        
    }
    
    func observeMessageForPassenger(){
        
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childAdded){ (snapshot: FIRDataSnapshot) in
        
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.user {
                        self.uid_req = snapshot.key
//                        print("The value is \(self.uid_req)!")
                        self.delegate?.canCallCarpool(delegateCalled: true)
                        
                    }
                }
            }
            
        }
        
        DBProvider.Instance.requestAcceptedRef.observe(FIRDataEventType.childAdded){ (snapshot: FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if self.driver == "" {
                        
                        self.driver = name
                        self.delegate?.driverAcceptedRequest(requestAccepted: true, drivername: self.driver)
                        
                    }
                }
            }
            
        }
        
        DBProvider.Instance.requestAcceptedRef.observe(FIRDataEventType.childRemoved){ (snapshot: FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver{
                        self.driver = ""
                        self.delegate?.driverAcceptedRequest(requestAccepted: false, drivername: name)
                    }
                }
            }
            
            
        }
        
        DBProvider.Instance.requestAcceptedRef.observe(FIRDataEventType.childChanged){ (snapshot:FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String{
                    if name == self.driver {
                        if let lat = data[Constants.LATITUDE] as? Double {
                            if let long = data[Constants.LONGITUDE] as? Double {
                                self.delegate?.updateDriverLocation(lat: lat, long: long)
                            }
                        }
                    }
                }
            }
            
        }
        
    }

    func cancelCarpool(){
        
        print("test value \(uid_req)")
        DBProvider.Instance.requestRef.child(uid_req).removeValue()
        
    }
    
    func updatePassengerLocation(lat:Double , long:Double){
        DBProvider.Instance.requestRef.child(uid_req).updateChildValues([Constants.LATITUDE:lat , Constants.LONGITUDE:long])
    }
    
}


















