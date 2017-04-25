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
    var uid_test = ""
    
    var statusArrived = true
    
    let username = FIRAuth.auth()?.currentUser
    
    static var instace: CarpoolHandler {
        return instance
    }
    
    func requestCarpool(latitude: Double , longitude: Double,no:Int ,whereto:String ,rate:Double){
        
        
        
//        let ref = FIRDatabase.database().reference()
        
        print("uid: \(FIRAuth.auth()?.currentUser?.uid)")
        
        //                    self.performSegue(withIdentifier: "homeView", sender: self);
        
        DBProvider.Instance.userRef.child((username!.uid)).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as! NSDictionary
            
            let usernamef = value["name"] as! String
            
            CarpoolHandler.instace.user = usernamef
            
            let data : Dictionary<String, Any> = [Constants.NAME: self.user, Constants.LATITUDE: latitude , Constants.LONGITUDE: longitude,Constants.NO: no,Constants.WHERETO:whereto,Constants.STATUS_CARPOOL:"wait",Constants.ARRIVED:false,Constants.DRIVER:"",Constants.RATE:rate]
            
//            DBProvider.Instance.requestRef.childByAutoId().setValue(data)
            DBProvider.Instance.requestRef.child(self.user).setValue(data)
            
        })
        
//        statusRequest(status: "wait")
        
        
        
    }
    
    func observeMessageForPassenger(){
        
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childAdded){ (snapshot: FIRDataSnapshot) in
        
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.user {
                        self.uid_req = snapshot.key
                        self.setuidReq(uid: "\(self.uid_req)")
                        print("The value is \(self.uid_req)!")
                        self.delegate?.canCallCarpool(delegateCalled: true)
                        
                        self.statusArrived = (data[Constants.ARRIVED] as? Bool)!
                        print(self.statusArrived)
                    }
                }
            }
            
        }
        
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childRemoved){ (snapshot: FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.DRIVER] as? String {
//                    if name == self.user {
                        
                        
                        self.delegate?.driverAcceptedRequest(requestAccepted: false, drivername: name)
                        
                        
//                    }
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
        
//        print("test value \(uid_req)")
        DBProvider.Instance.requestRef.child(uid_req).removeValue()
        
    }
    
    func updatePassengerLocation(lat:Double , long:Double){
        DBProvider.Instance.requestRef.child(uid_req).updateChildValues([Constants.LATITUDE:lat , Constants.LONGITUDE:long])
    }
    
//    func statusRequest(status:String){
//        DBProvider.Instance.requestRef.observe(FIRDataEventType.childAdded){ (snapshot: FIRDataSnapshot) in
//            
//            self.uid_req = snapshot.key
//            
//            print("uid_req test \(self.uid_req)")
//            print("uid_test \(self.uid_test)")
//            if(self.uid_test == self.uid_req){
//                
//            DBProvider.Instance.requestRef.child((self.uid_req)).observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//                print("uid_req test2 \(self.uid_req)")
//                
//                let value = snapshot.value as! NSDictionary
//            
//                let usernamef = value[Constants.NAME] as! String
//                let lat = value[Constants.LATITUDE] as! Double
//                let long = value[Constants.LONGITUDE] as! Double
//                let no = value[Constants.NO] as! NSNumber
//                let whereto = value[Constants.WHERETO] as! String
//            
//                let data : Dictionary<String, Any> = [Constants.NAME: usernamef, Constants.LATITUDE: lat , Constants.LONGITUDE: long,Constants.NO: no,Constants.WHERETO:whereto,Constants.STATUS_CARPOOL:status]
//            
//                DBProvider.Instance.requestRef.child(self.uid_req).setValue(data)
//                
//            
//            })
//            }
//            
//            
//        }
//        
//    }
    
    func setuidReq(uid:String){
        uid_test = uid
    }
    
//    func statusRequert() -> String {
//        
//        let status : String?
//        DBProvider.Instance.requestRef.child((username!.uid)).observeSingleEvent(of: .value, with: { (snapshot) in
//            
//            let value = snapshot.value as! NSDictionary
//            status = value[Constants.STATUS] as! String
//            
////            return status
//        })
//        
//        return status
//    }
    
}


















