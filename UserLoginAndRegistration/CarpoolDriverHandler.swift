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
    func acceptCarpool(lat:Double,long:Double,no:Int,whereto:String,name:String,rate:Double,ratepass:Double)
    func passengerCanceledCarpool(name:String)
    func carpoolCanceled()
    func updatePassengerLocation(lat:Double,long:Double)
    func arrived(name:String)
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
    
    var no = 0
    
    static var instace: CarpoolDriverHandler {
        return instance
    }
    
    func observeMessagesForDriver() {
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childAdded){ (snapshot: FIRDataSnapshot) in
//            self.uid_req = snapshot.key
//            print("driver uid_req \(self.uid_req)")
            if let data = snapshot.value as? NSDictionary {
                print(data)
                let name = data[Constants.NAME] as! String
                let rate = data[Constants.RATE] as! Double
                if let latitude = data[Constants.LATITUDE] as? Double {
                    if let longitude = data[Constants.LONGITUDE] as? Double {
                        if let no = data[Constants.NO] as? Int{
                            self.setNumberOfSeatPassenger(seat: no)
                            if let whereto = data[Constants.WHERETO] as? String{
                                if let status = data[Constants.STATUS_CARPOOL] as? String{
                                    if status == "wait"{
                                        DBProvider.Instance.passengerRef.child(name).observeSingleEvent(of: .value, with: { snapshot in
                                            
                                            let value = snapshot.value as! NSDictionary
                                            
                                            var rateavg = value[Constants.RATEAVG] as! Double
                                            
                                            self.delegate?.acceptCarpool(lat: latitude, long: longitude, no:no,whereto: whereto, name:name, rate:rate, ratepass:rateavg)
                                            print("lognaja")
                                            print(whereto)
                                            self.setuidReq(uid: snapshot.key)
                                            
                                        })
//                                        self.delegate?.acceptCarpool(lat: latitude, long: longitude, no:no,whereto: whereto, name:name, rate:rate)
//                                        print("lognaja")
//                                        print(whereto)
//                                        self.setuidReq(uid: snapshot.key)
                                    }
                                }
//                                self.delegate?.acceptCarpool(lat: latitude, long: longitude, no:no,whereto: whereto)
//                                print("lognaja")
//                                self.setuidReq(uid: self.uid_req)
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
                    let ar = data[Constants.ARRIVED] as! Bool
                    let name = data[Constants.NAME] as! String
                    if ar {
                        
                        
                        self.delegate?.carpoolCanceled()
                        
                        self.delegate?.arrived(name: name)
                        
                        
                    } else{
                        if let name = data[Constants.NAME] as? String{
                            if name == self.passenger{
                                self.passenger = ""
                                self.delegate?.passengerCanceledCarpool(name:name)
                            }
                        }
                    }
//                    if let name = data[Constants.NAME] as? String{
//                        if name == self.passenger{
//                            self.passenger = ""
//                            self.delegate?.passengerCanceledCarpool()
//                        }
//                    }
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
        
//        DBProvider.Instance.locationRef.observe(FIRDataEventType.childChanged) { (snapshot:FIRDataSnapshot) in
//            
//            if let data = snapshot.value as? NSDictionary{
//                if let lat = data[Constants.LATITUDE] as? Double {
//                    if let long = data[Constants.LONGITUDE] as? Double {
//                        self.delegate?.updatePassengerLocation(lat: lat, long: long)
//                    }
//                }
//            }
//            
//        }
        
        DBProvider.Instance.requestAcceptedRef.observe(FIRDataEventType.childAdded){ (snapshot: FIRDataSnapshot) in
            print(snapshot.key)
//            self.setuidAccept(uid: snapshot.key)
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
    
    func cancelCarpoolForDriver(name:String){
        
//        DBProvider.Instance.requestAcceptedRef.child(/*uid*/user).removeValue()
        
        DBProvider.Instance.requestRef.child((self.uid_test)).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as! NSDictionary
            
            let seat = value[Constants.NO] as! Int
            
            self.updateSeat(seat: seat)
            
//            DBProvider.Instance.requestRef.child(name).updateChildValues([Constants.ARRIVED:true])
//            DBProvider.Instance.requestRef.child(name).removeValue()
            
        })
        
        
    }
    
    func carpoolAccepted(lat:Double, long:Double){
        
//        print(uid)
        
//        statusRequest(status: "busy")
        
        let username = FIRAuth.auth()?.currentUser
        
        let ref = FIRDatabase.database().reference()
        
        print("uid: \(FIRAuth.auth()?.currentUser?.uid)")
        
        //                    self.performSegue(withIdentifier: "homeView", sender: self);
        
        ref.child("users").child((username!.uid)).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as! NSDictionary
            
            let usernamef = value["name"] as! String
            
            self.user = usernamef
            
            print(self.user)
            
            DBProvider.Instance.requestAcceptedRef.child(self.user).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.childrenCount != 0 {
                let value = snapshot.value as! NSDictionary
                let no = value["seat"] as! Int
                
                var totalseat = self.no + no
                
                if totalseat <= 4 {
                let data : Dictionary<String, Any> = [Constants.NAME: self.user, Constants.LATITUDE: lat , Constants.LONGITUDE: long,Constants.SEAT: totalseat]
                DBProvider.Instance.requestAcceptedRef.child(self.user).setValue(data)
                print(self.user)
                DBProvider.Instance.requestRef.child(self.uid_test).updateChildValues([Constants.DRIVER:self.user])
//                    self.statusRequest(status: "busy")
                    
                }
                }
                else{
                    let data : Dictionary<String, Any> = [Constants.NAME: self.user, Constants.LATITUDE: lat , Constants.LONGITUDE: long,Constants.SEAT: self.no]
                    DBProvider.Instance.requestAcceptedRef.child(self.user).setValue(data)
                }
            })
            
//            let data : Dictionary<String, Any> = [Constants.NAME: self.user, Constants.LATITUDE: lat , Constants.LONGITUDE: long,Constants.SEAT: self.no]
//            
////            DBProvider.Instance.requestAcceptedRef.childByAutoId().setValue(data)
//            DBProvider.Instance.requestAcceptedRef.child(self.user).setValue(data)
            
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
        DBProvider.Instance.requestAcceptedRef.child(/*uid*/user).updateChildValues([Constants.LATITUDE:lat , Constants.LONGITUDE:long])
    }
    
    func updateSeat(seat:Int){
        print(uid)
        DBProvider.Instance.requestAcceptedRef.child(self.user).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.childrenCount != 0 {
                    let value = snapshot.value as! NSDictionary
                    let no = value["seat"] as! Int
                    
                    var totalseat = no - seat
                    
                    DBProvider.Instance.requestAcceptedRef.child(self.user).updateChildValues([Constants.SEAT:totalseat])
            }
        })

        
//        DBProvider.Instance.requestAcceptedRef.child(uid).updateChildValues([Constants.SEAT:""])
    }
    
    func arrived(name:String){
//        DBProvider.Instance.requestRef.child(self.uid_test).removeValue()
        
//        DBProvider.Instance.requestRef.observe(FIRDataEventType.childAdded){ (snapshot: FIRDataSnapshot) in
//            
//            self.uid_req = snapshot.key
//            
//            //            print("st c \(self.uid_req)")
//            
//            print("driver uid_req test \(self.uid_req)")
//            print("driver uid_test \(self.uid_test)")
//            if(self.uid_test == self.uid_req){
        
                DBProvider.Instance.requestRef.child((self.uid_test)).observeSingleEvent(of: .value, with: { (snapshot) in
//                    // Get user value
//                    print("uid_req test2 \(self.uid_test)")
//                    
                    let value = snapshot.value as! NSDictionary
                    
                    let seat = value[Constants.NO] as! Int
                    
                    self.updateSeat(seat: seat)
        
                    DBProvider.Instance.requestRef.child(name).updateChildValues([Constants.ARRIVED:true])
                    DBProvider.Instance.requestRef.child(name).removeValue()
                    
                })
//            }
//            
//            
//        }
        
    }
    
    func statusRequest(status:String,arrived:Bool){
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childAdded){ (snapshot: FIRDataSnapshot) in
            
            self.uid_req = snapshot.key
            
//            print("st c \(self.uid_req)")
            
            print("driver uid_req test \(self.uid_req)")
            print("driver uid_test \(self.uid_test)")
            if(self.uid_test == self.uid_req){
                
                DBProvider.Instance.requestRef.child((self.uid_test)).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    print("uid_req test2 \(self.uid_test)")
                    
                    let value = snapshot.value as! NSDictionary
                    
                    let usernamef = value[Constants.NAME] as! String
                    let lat = value[Constants.LATITUDE] as! Double
                    let long = value[Constants.LONGITUDE] as! Double
                    let no = value[Constants.NO] as! NSNumber
                    let whereto = value[Constants.WHERETO] as! String
                    
                    let data : Dictionary<String, Any> = [Constants.NAME: usernamef, Constants.LATITUDE: lat , Constants.LONGITUDE: long,Constants.NO: no,Constants.WHERETO:whereto,Constants.STATUS_CARPOOL:status]
                    
                    print("test user naja \(self.user)")
                    
                    DBProvider.Instance.requestRef.child(self.uid_test).updateChildValues([Constants.STATUS_CARPOOL:status,Constants.ARRIVED:arrived,Constants.DRIVER:self.uid_req])
                    
                    
                })
            }
            
            
        }
        
    }
    
    func statusRequest(status:String,arrived:Bool,name:String){
        DBProvider.Instance.requestRef.child(name).updateChildValues([Constants.STATUS_CARPOOL:status,Constants.ARRIVED:arrived,Constants.DRIVER:""])
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
        print(uid_test)
    }
    
    func setuis(uid:String){
        uid_req = uid
    }
    
    func setStatus(s:Bool){
        self.status = s
    }
    
    func setNumberOfSeatPassenger(seat:Int){
        self.no = seat
    }
    
//    func setuidAccept(uid:String){
//        self.uid = uid
//    }

    
    
}
