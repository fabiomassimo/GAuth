//
//  UserCode.swift
//  GoogleAuthenticator
//
//  Created by Fabio Milano on 12/06/16.
//  Copyright © 2016 Touchwonders. All rights reserved.
//

import Foundation

// EXAMPLE
//{
//    "device_code" : "THE DEVICE CODE",
//    "user_code" : "THE USER CODE",
//    "verification_url" : "https://www.google.com/device",
//    "expires_in" : 1800,
//    "interval" : 5
//}

/**
 *  A DeviceAuthorizationToken struct represents the response object when starting an authentication via device token.
 */
internal struct DeviceAuthorizationToken {
    
    /// The device code related to the authorization request.
    let deviceCode: String
    
    /// The user code. This should be shown to the user to complete the authorization process.
    let userCode: String
    
    /// The verification URL to which the user should connect to in order to complete the authorization process.
    let verificationUrl: NSURL
    
    /// Expiration of the user code expressend in NSTimeInterval
    let expiresIn: NSTimeInterval
    
    /// The retry interval to use when polling the authorization against Google
    let retryInterval: NSTimeInterval
    
    init?(json: [String: AnyObject]) {
        guard let deviceCode = json[UserCodeJSONKey.DeviceCode.rawValue] as? String,
                verificationUrl = json[UserCodeJSONKey.VerificationUrl.rawValue] as? String,
                userCode = json[UserCodeJSONKey.UserCode.rawValue] as? String,
                expiresIn = json[UserCodeJSONKey.ExpiresIn.rawValue] as? NSTimeInterval,
            retryInterval = json[UserCodeJSONKey.RetryInterval.rawValue] as? NSTimeInterval else {
                return nil
        }
        
        self.deviceCode = deviceCode
        self.userCode = userCode
        self.verificationUrl = NSURL(string: verificationUrl)!
        self.expiresIn = expiresIn
        self.retryInterval = retryInterval
    }
}

private enum UserCodeJSONKey: String {
    case DeviceCode = "device_code"
    case VerificationUrl = "verification_url"
    case UserCode = "user_code"
    case ExpiresIn = "expires_in"
    case RetryInterval = "interval"
}