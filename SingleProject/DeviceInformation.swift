//
//  DeviceInformation.swift
//  LACoreAPI
//
//  Created by yana mulyana on 05/09/19.
//  Copyright © 2019 yana mulyana. All rights reserved.
//

import UIKit

class DeviceInformation{
    
    private static var deviceInstance: DeviceInformation =  DeviceInformation()
    
    class func sharedInstance() -> DeviceInformation {
        return deviceInstance
    }
    
    static func osName() -> String{
        return "iOS"
    }
    
    static func osVersion() -> String{
        return UIDevice.current.systemVersion
    }
    
}
