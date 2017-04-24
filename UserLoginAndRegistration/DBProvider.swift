//
//  DBProvider.swift
//  UserLoginAndRegistration
//
//  Created by Mark on 2/4/17.
//  Copyright © 2017 Sergey Kargopolov. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseCore
import FirebaseAuth
import FirebaseAnalytics
import FirebaseInstanceID

class DBProvider {
    
    private static let instance = DBProvider()
    
    let username = FIRAuth.auth()?.currentUser
    
    static var Instance : DBProvider{
        return instance
    }
    
    var ref : FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }
    
    var userRef : FIRDatabaseReference{
        return ref.child(Constants.USER)
    }
    
    var carpoolRef : FIRDatabaseReference {
        return ref.child(Constants.CARPOOL)
    }
    
    var requestRef: FIRDatabaseReference {
        return ref.child(Constants.REQUEST)
    }
    
    var requestAcceptedRef: FIRDatabaseReference{
        return ref.child(Constants.ACCEPTED)
    }
    
    var eventRef: FIRDatabaseReference{
        return ref.child(Constants.EVENT)
    }
    
    var locationRef: FIRDatabaseReference{
        return ref.child(Constants.LOCATION)
    }
    
    var driverRef: FIRDatabaseReference{
        return ref.child(Constants.DRIVER)
    }
    
    var passengerRef: FIRDatabaseReference{
        return ref.child(Constants.PASSENGER)
    }
    
    func saveUser(ID:String, email:String, password: String, name:String){
//        let data: Dictionary<String, Any> = [Constants.EMAIL:email,Constants.PASSWORD:password,Constants.NAME:name, Constants.STATUS : "None"]
        
        let data: Dictionary<String, Any> = [Constants.NAME:name, Constants.STATUS : "None"]
        
        carpoolRef.child(ID).child(Constants.DATA).setValue(data)
    }
    
    func statusCarpool(status:String){
        
        if let user = FIRAuth.auth()?.currentUser {
            
            //read data firebase
            carpoolRef.child(user.uid).child(Constants.DATA).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as! NSDictionary
                
                let usernamef = value["name"] as! String
                
//                let status = value["status"] as! String
                
                let data : Dictionary<String, Any> = [Constants.NAME:usernamef , Constants.STATUS:status]
                
                self.carpoolRef.child(user.uid).child(Constants.DATA).setValue(data)
                
//                self.nameText.text = usernamef
                
                
                // ...
            })
            
            
            //update data
//            let post = ["Password": self.passText.text!,
//                        "email": self.emailText.text!,
//                        "name": self.nameText.text! ]
//            let childUpdates = ["/users/\(user.uid)/": post ]
//            self.ref.updateChildValues(childUpdates)
        }
        
    }
    
    
    
}
