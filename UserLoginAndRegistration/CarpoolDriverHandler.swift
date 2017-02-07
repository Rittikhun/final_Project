//
//  CarpoolDriverHandler.swift
//  UserLoginAndRegistration
//
//  Created by Mark on 2/5/17.
//  Copyright © 2017 Sergey Kargopolov. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol CarpoolDriverController: class {
    func acceptCarpool(lat:Double,long:Double)
    func passengerCanceledCarpool()
    func carpoolCanceled()
    func updatePassengerLocation(lat:Double,long:Double)
}

class CarpoolDriverHandler{
    
    private static let instance = CarpoolDriverHandler()
    
    weak var delegate: CarpoolDriverController?
    
    var passenger = ""
    var user = ""
    var uid = ""
    
    static var instace: CarpoolDriverHandler {
        return instance
    }
    
    
    func observeMessagesForDriver() {
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childAdded){ (snapshot: FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let latitude = data[Constants.LATITUDE] as? Double {
                    if let longitude = data[Constants.LONGITUDE] as? Double {
                        self.delegate?.acceptCarpool(lat: latitude, long: longitude)
                    }
                }
                
                if let name = data[Constants.NAME] as? String{
                    self.passenger = name;
                }
            }
            
            DBProvider.Instance.requestRef.observe(FIRDataEventType.childRemoved, with: {(snapshot: FIRDataSnapshot) in
            
                if let data = snapshot.value as? NSDictionary{
                    if let name = data[Constants.NAME] as? String{
                        if name == self.passenger{
                            self.passenger = ""
                            self.delegate?.passengerCanceledCarpool()
                        }
                    }
                }
                
            })
            
        }
        
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childChanged) { (snapshot:FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary{
                if let lat = data[Constants.LATITUDE] as? Double {
                    if let long = data[Constants.LONGITUDE] as? Double {
                        self.delegate?.updatePassengerLocation(lat: lat, long: long)
                    }
                }
            }
            
        }
        
        DBProvider.Instance.requestAcceptedRef.observe(FIRDataEventType.childAdded){ (snapshot: FIRDataSnapshot) in
        
            if let data = snapshot.value as? NSDictionary {
                
                if let name = data[Constants.NAME] as? String {
                    
                    if name == self.user {
                        self.uid = snapshot.key
                    }
                    
                }
                
            }
            
        }
        
        DBProvider.Instance.requestAcceptedRef.observe(FIRDataEventType.childRemoved){ (snapshot: FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                
                if let name = data[Constants.NAME] as? String {
                    
                    if name == self.user {
                        self.delegate?.carpoolCanceled()
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func cancelCarpoolForDriver(){
        
        DBProvider.Instance.requestAcceptedRef.child(uid).removeValue()
        
    }
    
    func carpoolAccepted(lat:Double, long:Double){
        
        let username = FIRAuth.auth()?.currentUser
        
        let ref = FIRDatabase.database().reference()
        
        print("uid: \(FIRAuth.auth()?.currentUser?.uid)")
        
        //                    self.performSegue(withIdentifier: "homeView", sender: self);
        
        ref.child("users").child((username!.uid)).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as! NSDictionary
            
            let usernamef = value["name"] as! String
            
            CarpoolDriverHandler.instace.user = usernamef
            
            let data : Dictionary<String, Any> = [Constants.NAME: self.user, Constants.LATITUDE: lat , Constants.LONGITUDE: long]
            
            DBProvider.Instance.requestAcceptedRef.childByAutoId().setValue(data)
            
        })
        
    }
    
    func updateDriverLocation(lat:Double,long:Double){
        DBProvider.Instance.requestAcceptedRef.child(uid).updateChildValues([Constants.LATITUDE:lat , Constants.LONGITUDE:long])
    }
    
    
}
