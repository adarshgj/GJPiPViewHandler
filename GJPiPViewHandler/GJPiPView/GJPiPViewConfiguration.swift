//
//  GJPiPViewConfiguration.swift
//  GJPiPViewHandler
//
//  Created by Adarsh GJ on 28/08/17.
//  Copyright © 2017 Adarsh. All rights reserved.
//

import UIKit

class GJPiPViewConfiguration: NSObject {
    var draggable = true
    var rotatable = true
    var autoplay = true
    var currentVideoTitle = ""
    
    override init() {
        super.init()
        currentVideoTitle = ""
        
    }
    let hiddenOrigin: CGPoint = {
        let appDelegate  = UIApplication.shared.delegate
        let rootController = appDelegate?.window!?.rootViewController
        var heightAdjust : CGFloat = 0.0
        if rootController is UITabBarController {
            //do something if it's an instance of that class
            heightAdjust = (rootController as! UITabBarController).tabBar.frame.size.height
        }
        
        let y = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * 9 / 32)-heightAdjust
        let x = UIScreen.main.bounds.width
        let coordinate = CGPoint.init(x: x, y: y)
        return coordinate
    }()
    let minimizedOrigin: CGPoint = {
        let appDelegate  = UIApplication.shared.delegate
        let rootController = appDelegate?.window!?.rootViewController
        var heightAdjust : CGFloat = 0.0
        
        var sideInset : CGFloat = 5.0
        
        if rootController is UITabBarController {
            //do something if it's an instance of that class
            heightAdjust = (rootController as! UITabBarController).tabBar.frame.size.height
        }
        
        let x = UIScreen.main.bounds.width/2 - sideInset
        let y = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * 9 / 32) - heightAdjust - sideInset
        /*
         let widthContraint = Utils.isIpad() ? CGFloat(2.0) : CGFloat(2.0)
         let x = UIScreen.main.bounds.width - (UIScreen.main.bounds.width/widthContraint)
         let y = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * 9 / CGFloat(16*widthContraint)) - CGFloat(heightAdjust)
         */
        let coordinate = CGPoint.init(x: x, y: y)
        return coordinate
    }()
    let fullScreenOrigin = CGPoint.init(x: 0, y: 0)
    
    let screenWidth : CGFloat = {
        return UIScreen.main.bounds.width
    }()
    let screenHeight : CGFloat = {
        var heightAdjust : CGFloat = 0.0
        let appDelegate  = UIApplication.shared.delegate
        let rootController = appDelegate?.window!?.rootViewController
        if rootController is UITabBarController {
            //do something if it's an instance of that class
            heightAdjust = (rootController as! UITabBarController).tabBar.frame.size.height
        }
        return UIScreen.main.bounds.height - heightAdjust
    }()

}
