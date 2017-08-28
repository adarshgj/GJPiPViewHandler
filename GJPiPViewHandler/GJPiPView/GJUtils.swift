//
//  GJUtils.swift
//  GJPiPViewHandler
//
//  Created by Adarsh GJ on 28/08/17.
//  Copyright © 2017 Adarsh. All rights reserved.
//

import UIKit

class GJUtils: NSObject {
    /// Check device is iPhone /iPad
    /// - Returns: if device is iPad will return true otherwise false.
    class func isIpad() -> Bool {
        return (UIDevice.current.userInterfaceIdiom == .pad)
    }

}
