//
//  MyAnnotationView.swift
//  UserLoginAndRegistration
//
//  Created by Mark on 3/8/17.
//  Copyright © 2017 Sergey Kargopolov. All rights reserved.
//

import UIKit
import MapKit

class MyAnnotationView: MKAnnotationView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(annotation:MKAnnotation?, reuseIdentifier:String?) {
        super.init(
            annotation: annotation, reuseIdentifier: reuseIdentifier)
        let im = UIImage(named:"map-icon")!
        self.frame = CGRect(x:0, y:0, width:im.size.width / 3.0 + 5, height:im.size.height / 3.0 + 5)
        self.centerOffset = CGPoint(x:0,y:-20)
        self.isOpaque = false
    }
    
//    override init(frame: CGRect) {
//        super.init(frame:frame)
//    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    override func draw(_ rect: CGRect) {
        let im = UIImage(named:"clipartdirtbike.gif")!
        im.draw(in: self.bounds.insetBy(dx: 5, dy: 5))
    }


}
