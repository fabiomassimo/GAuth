//
//  GoogleAuthenticatorError.swift
//  GoogleAuthenticator
//
//  Created by Fabio Milano on 11/06/16.
//  Copyright © 2016 Touchwonders. All rights reserved.
//

import Foundation

/**
 *  The designated representation for an error
 */
public enum GoogleAuthenticatorError: ErrorType {
    /// Error caused during the authorization flow
    case AuthorizationError(String)
    
    /// The current token is invalid. The user should rissue another autorization process.
    case InvalidAccessToken
    
    /// The authorization process is pending user input.
    case AuthorizationPending
    
    /// The device verification flow failed. Retry is adviced.
    case DeviceVerificationFailed(String)
}