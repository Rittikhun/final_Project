//
//  menuSetting.swift
//  UserLoginAndRegistration
//
//  Created by iOS Dev on 11/3/2559 BE.
//  Copyright © 2559 Sergey Kargopolov. All rights reserved.
//

import UIKit

class menuSetting: NSObject {
    
    let collectionView: UICollectionView = {
        
    let layout = UICollectionViewFlowLayout()
        
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
    return cv
        
    }()
    
    override init() {
        
        super.init()
        
        
    }

    let blackView = UIView()
    
    func showSetting() {
        
        if let window = UIApplication.shared.keyWindow {
            
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlerDismiss)))
            
            window.addSubview(blackView)
            window.addSubview(collectionView)
            
            let height: CGFloat = 200
            
            let y = window.frame.height - height
            
            collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width,height: 200)
            
            
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.blackView.alpha = 1
                
                self.collectionView.frame = CGRect(x: 0, y: y, width: self.collectionView.frame.width,height: self.collectionView.frame.height)
                
            })
            
            
        }
        
    }
    
    func handlerDismiss() {
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.blackView.alpha = 0
            
            
            
        })
        
    }

    
}
