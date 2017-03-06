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
    func acceptCarpool(lat:Double,long:Double,no:Int,whereto:String)
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
    var uid_req = ""
    var uid_test = ""
    var status = true
    
    static var instace: CarpoolDriverHandler {
        return instance
    }
    
    
    func observeMessagesForDriver() {
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childAdded){ (snapshot: FIRDataSnapshot) in
            self.uid_req = snapshot.key
            print("driver uid_req \(self.uid_req)")
            if let data = snapshot.value as? NSDictionary {
                if let latitude = data[Constants.LATITUDE] as? Double {
                    if let longitude = data[Constants.LONGITUDE] as? Double {
                        if let no = data[Constants.NO] as? Int{
                            if let whereto = data[Constants.WHERETO] as? String{
                                self.delegate?.acceptCarpool(lat: latitude, long: longitude, no:no,whereto: whereto)
                                print("lognaja")
                                self.setuidReq(uid: self.uid_req)
                            }
                        }
//                        self.delegate?.acceptCarpool(lat: latitude, long: longitude)
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
    
//    func statusCarpool(){
//        DBProvider.Instance.requestRef.observeSingleEvent(of: .value, with: { (snapshot) in
//            
//            let value = snapshot.value as! NSDictionary
//            
//            
//            
//        })
//    }
    
    func updateDriverLocation(lat:Double,long:Double){
        DBProvider.Instance.requestAcceptedRef.child(uid).updateChildValues([Constants.LATITUDE:lat , Constants.LONGITUDE:long])
    }
    
    func statusRequest(status:String){
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childAdded){ (snapshot: FIRDataSnapshot) in
            
            self.uid_req = snapshot.key
            
            print("driver uid_req test \(self.uid_req)")
            print("driver uid_test \(self.uid_test)")
            if(self.uid_test == self.uid_req){
                
                DBProvider.Instance.requestRef.child((self.uid_req)).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    print("uid_req test2 \(self.uid_req)")
                    
                    let value = snapshot.value as! NSDictionary
                    
                    let usernamef = value[Constants.NAME] as! String
                    let lat = value[Constants.LATITUDE] as! Double
                    let long = value[Constants.LONGITUDE] as! Double
                    let no = value[Constants.NO] as! NSNumber
                    let whereto = value[Constants.WHERETO] as! String
                    
                    let data : Dictionary<String, Any> = [Constants.NAME: usernamef, Constants.LATITUDE: lat , Constants.LONGITUDE: long,Constants.NO: no,Constants.WHERETO:whereto,Constants.STATUS_CARPOOL:status]
                    
                    DBProvider.Instance.requestRef.child(self.uid_req).setValue(data)
                    
                    
                })
            }
            
            
        }
        
    }
    
    func getStatus() -> Bool {
        
        return self.status
    }
    
//    func check() {
//        DBProvider.Instance.requestRef.observe(FIRDataEventType.childAdded){ (snapshot: FIRDataSnapshot) in
//            
//            self.uid_req = snapshot.key
//            
//            self.setuidReq(uid: snapshot.key)
//            if(self.uid_test == self.uid_req){
//                
//                DBProvider.Instance.requestRef.child((self.uid_req)).observeSingleEvent(of: .value, with: { (snapshot) in
//                    
//                    
//                    let value = snapshot.value as! NSDictionary
//                    
//                    let status = value[Constants.STATUS_CARPOOL] as! String
////                    let status = "busy"
//                    print(status)
//                    if(status == "wait"){
//                        self.setStatus(s:true)
//                        print(self.status)
//                    }else{
//                        self.setStatus(s:false)
//                        print(self.status)
//                    }
//                    
//                    
//                })
//            }
////             self.checkTest()
//            
//        }
//    }
//    
//    func checkTest(){
//        
//        print("uid_test \(uid_test)  uid_req \(uid_req)")
//        
//        if(self.uid_test == self.uid_req){
//            
//            DBProvider.Instance.requestRef.child((self.uid_req)).observeSingleEvent(of: .value, with: { (snapshot) in
//                
//                
//                let value = snapshot.value as! NSDictionary
//                
//                let status = value[Constants.STATUS_CARPOOL] as! String
//                //                    let status = "busy"
//                print(status)
//                if(status == "wait"){
//                    self.setStatus(s:true)
//                    print(self.status)
//                }else{
//                    self.setStatus(s:false)
//                    print(self.status)
//                }
//                
//                
//            })
//        }
//
//    }
    
    func setuidReq(uid:String){
        uid_test = uid
    }
    
    func setuis(uid:String){
        uid_req = uid
    }
    
    func setStatus(s:Bool){
        self.status = s
    }

    
    
}
