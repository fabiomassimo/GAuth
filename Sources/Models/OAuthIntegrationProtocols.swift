//
//  OAuthIntegrationProtocol.swift
//  GoogleAuthenticator
//
//  Created by Fabio Milano on 13/06/16.
//  Copyright © 2016 Touchwonders. All rights reserved.
//


import Foundation
import Result

/**
 *  Defines the requirements for any type that represents an Access Token, such that it can be used by the `GoogleAuthenticatorClient`
 */
public protocol AuthorizedToken {
    
    /// The access token.
    var accessToken: String { get }
    
    /// The refresh token.
    var refreshToken: String? { get }
    
    /// The expiration time for current access token in seconds.
    var expiresIn: NSTimeInterval? { get }
    
    /// Convenience getter to know if current token has expired.
    var isExpired: Bool { get }
}

/**
 *  Defines the requirements for an error type to be processable by the `GoogleAuthenticatorClient`
 */
public protocol GoogleAuthenticatorErrorAdapter: ErrorType {
    /// The representation of the error as GoogleAuthenticatorError type.
    var googleAuthenticatorError: GoogleAuthenticatorError { get }
}

/**
 *  Defines the requirements for an OAuth client type to be used to initialize a `GoogleAuthenticatorClient`
 */
public protocol GoogleAuthenticatorOAuthClient {
    /// The type for the OAuth Client that the authenticator requires to handle OAuth requests and specifications
    associatedtype OAuthClientType
    
    /// The type used to represent a token retrieved via the OAuth Client
    associatedtype TokenType: AuthorizedToken
    
    /// The failure type that is used by the OAuth Client. Additionally, this type, must conform to the protocol needed to evaluate the error in the Google Authenticator implementation.
    associatedtype Failure: GoogleAuthenticatorErrorAdapter
    
    /// The client ID.
    var clientID: String { get }
    
    /// The client secret.
    var clientSecret: String { get }
    
    /// The authorize URL.
    var authorizeURL: NSURL { get }
    
    /// The token URL.
    var tokenURL: NSURL? { get }
    
    /// The redirect URL.
    var redirectURL: NSURL? { get }
    
    /// The token structure used by the OAuth client
    var token: TokenType? { get }
    
    /// The requested scopes.
    var scopes: [String] { get }
    
    /**
     The designated initializer for the OAuth Client encapsulate by the Google Authenticator Client
     
     - Parameters:
         - clientID: a.k.a. The consumer id
         - clientSecret: a.k.a. The consumer secret
         - bundleIdentifier: The bundle identifier of the app is used to build the proper callback via deep linking to the app
         - scope: The scope to authorize. Complete list available at `https://developers.google.com/identity/protocols/googlescopes`
     */
    static func Google(clientID clientID: String, clientSecret: String, bundleIdentifier: String, scope: GoogleServiceScope) -> OAuthClientType
    
    #if os(iOS)
    /**
     Request access token.
     This method is called by the authenticator to kick off the OAuth 2.0 authentication process with its OAuthClient.
     
     - Parameters:
         - completion: The completion block. Takes a Result as parameter.
             - Success: Takes just issued access token as value
             - Failure: The encountered failure.
     */
    func googleAuthenticatorAuthorize(completion: Result<TokenType, Failure> -> Void)
    #endif
    
    /**
     Refresh the available access token.
     This method is called by the authenticator when the access token provided by the OAuth client has expired and requires to be refreshed.
     
     - Parameters:
         - completion: The completion block. Takes a `Result` as parameter.
            - Success: Takes the a `refreshed` access token as value
            - Failure: The encountered failure.
     */
    func googleAuthenticatorRefreshToken(completion: Result<TokenType, Failure> -> Void)
    
    /**
     Request an access token via device code. For more details see `https://developers.google.com/identity/protocols/OAuth2ForDevices`
     This method is called by the authenticator when the access token is requested from device with limited capabilities.
     
     - Parameters:
         - completion: The completion block. Takes a `Result` as parameter.
             - Success: Takes the access token as value
             - Failure: The encountered failure.
     */
    func googleAuthenticatorAuthorizeDeviceCode(deviceCode: String, completion: Result<TokenType, Failure> -> Void)
}

/**
 Struct constant required to handle the authentication process with Google
 
 - AuthorizeUrl:   The authorization URL used when requesting the authorization code (used to retrieve the oauth tokens)
 - AccessTokensUrl: The access token URL used to retrieve the OAuth tokens: access_token and refresh_token
 - CallbackPostfix: The string to append to the bundle identiifier to compose the callback URL used in the OAuth 2.0 authentication process.
 - DeviceVerificationUrl: The endpoint to use to kickoff the OAuth 2.0 authorization via devices with limited capabilities.
 */
public enum AuthenticationConstants: String {
    case AuthorizeUrl = "https://accounts.google.com/o/oauth2/auth"
    case AccessTokensUrl = "https://www.googleapis.com/oauth2/v4/token"
    case CallbackPostfix = ":/urn:ietf:wg:oauth:2.0:oob"
    case DeviceVerificationUrl = "https://accounts.google.com/o/oauth2/device/code"
    
    /// A convenience getter to retrienve the URL representation for every enum value. 
    public var URL: NSURL {
        return NSURL(string: self.rawValue)!
    }
}