//
//  GoogleAuthenticator.swift
//  GoogleAnalyticsReader
//
//  Created by Fabio Milano on 05/02/16.
//  Copyright © 2016 Touchwonders. All rights reserved.
//

import Foundation
import Result

/// The Google Authenticator Client is responsible to provide an easy integration with Google authentication process for you.
public final class GoogleAuthenticatorClient<T: GoogleAuthenticatorOAuthClient> {
    
    /// The client ID used to initialize the authenticator
    public var clientID: String {
        return oauthClient.clientID
    }
    
    /// The client secret used to initialize the authenticator
    public var clientSecret: String {
        return oauthClient.clientSecret
    }
    
    /// The currently available token
    public var token: AuthorizedToken? {
        get {
            return oauthClient.token
        }
    }
    
    public var scope: GoogleServiceScope {
        return GoogleServiceScope(scopes: oauthClient.scopes)
    }
    
    /// The OAuth Client used to support the OAuth 2.0 specifications and requirements.
    internal let oauthClient: T
    
    /**
     Convenience initializer
     
     - parameter oauthClient: The OAuth Client inistantiation to use to complete the initialization.
     
     - returns: A fully equipped Google Authenticator Client ready to use.
     */
    public required init(oauthClient: T) {
        self.oauthClient = oauthClient
    }
    
    /**
     The designated initializer.
     
     - parameter consumerKey:      The consumer key.
     - parameter consumerSecret:   The consumer secret.
     - parameter bundleIdentifier: The bundler identifier used to register you app on Goolge Developer console.
     - parameter scope:            The Google Scopes required to initiailize the authentication with Google Services.
     
     - returns: A fully equipped Google Authenticator Client ready for action.
     */
    public convenience init(consumerKey: String, consumerSecret: String, bundleIdentifier: String, scope:GoogleServiceScope) {
        let oauthClient = T.Google(clientID: consumerKey, clientSecret: consumerSecret, bundleIdentifier: bundleIdentifier, scope: scope) as! T
        self.init(oauthClient: oauthClient)
    }

    // MARK: Public methods
    
    public func authorizeDevice(verify:(verificationUrl: NSURL, userCode: String) -> Void, completion: Result<Void, GoogleAuthenticatorError> -> Void) {
        let params = parametersForDeviceVerification()
        
        HTTP.POST(AuthenticationConstants.DeviceVerificationUrl.URL, parameters: params) { [weak self] resultJSON in
            guard let _ = self else {
                return
            }
            
            switch resultJSON {
            case .Success(let json):
                guard let deviceAuthorizationToken = DeviceAuthorizationToken(json: json) else {
                    completion(.Failure(GoogleAuthenticatorError.InvalidAccessToken))
                    return
                }
                
                dispatch_async(dispatch_get_main_queue(), { 
                    verify(verificationUrl: deviceAuthorizationToken.verificationUrl, userCode: deviceAuthorizationToken.userCode)
                })
                
                self!.pollAccessToken(deviceAuthorizationToken.deviceCode, retryInterval:deviceAuthorizationToken.retryInterval, completion:{ (result) in
                    switch result {
                    case .Success():
                        completion(.Success())
                    case .Failure(let error):
                        completion(.Failure(error))
                    }
                })
            case .Failure(let error):
                if let description = error.userInfo[NSLocalizedDescriptionKey] as? String {
                    completion(.Failure(GoogleAuthenticatorError.DeviceVerificationFailed(description)))
                }
            }
        }
    }
    
    #if os(iOS)
    /**
    Every Google Authenticator needs to be authorized in order to make signed request.
    If no available tokens have been stored before, the hostViewController is used to present a standard WebView which guides the user to insert his credentials in order to kickoff the OAuth 2 dance to finally retrieve the required tokens.
    Otherwise, the authorization is skipped and available tokens are used to sign the requests.
    - parameter hostViewController: The host view controller used to present the credentials input.
    */
    public func authorize(completion: Result<Void, GoogleAuthenticatorError> -> Void) {
        
        oauthClient.googleAuthenticatorAuthorize { (result) in
            switch result {
            case .Success( _):
                completion(.Success())
            case .Failure(let error):
                completion(.Failure(error.googleAuthenticatorError))
            }
        }
    }
    #endif
    
    // MARK: client methods
    
    /**
    - returns: `true` if current authenticator is already authorized (access_token and refresh_token available). `false` otherwise.
    */
    public func isAuthorized() -> Bool {
        guard let token = oauthClient.token else {
            return false
        }
        
        return !token.isExpired && !token.accessToken.isEmpty
    }
    
    /// Alters the given request by adding authentication, if possible.
    ///
    /// In case of an expired access token and the presence of a refresh token,
    /// automatically tries to refresh the access token. If refreshing the
    /// access token fails, the access token is cleared.
    ///
    /// **Note:** If the access token must be refreshed, network I/O is
    ///     performed.
    ///
    /// **Note:** The completion closure may be invoked on any thread.
    ///
    /// - parameter request: An unauthenticated NSURLRequest.
    /// - parameter completion: A callback to invoke with the authenticated request.
    public func authenticateRequest(request: NSURLRequest, completion: Result<NSURLRequest, GoogleAuthenticatorError> -> ()) {
        if let token = token {
            if token.isExpired {
                // Expired token. Let's refresh it.
                oauthClient.googleAuthenticatorRefreshToken({ [weak self] result in
                    switch result {
                    case .Success( _):
                        self?.authenticateRequest(request, completion: completion)
                    case .Failure(let error):
                        completion(Result.Failure(error.googleAuthenticatorError))
                    }
                })
            } else {
                let mutableRequest = request.mutableCopy() as! NSMutableURLRequest
                mutableRequest.setAccessToken(token.accessToken)
                completion(Result.Success(mutableRequest))
            }
        } else {
            // No token available. The client must start an authentication process properly through -authorize method
            completion(Result.Failure(GoogleAuthenticatorError.InvalidAccessToken))
        }
    }
}

extension GoogleAuthenticatorClient {
    func parametersForDeviceVerification() -> [String: String] {
        return ["client_id": clientID, "scope": scope.string() ]
    }
    
    func parametersForDeviceAuthorization(userCode: String) -> [String: String] {
        return ["client_id": clientID, "client_secret": clientSecret, "code": userCode, "grant_type": "http://oauth.net/grant_type/device/1.0"]
    }
    
    func pollAccessToken(deviceCode: String, retryInterval: NSTimeInterval, completion: Result<Void, GoogleAuthenticatorError> -> Void) -> Void {
        oauthClient.googleAuthenticatorAuthorizeDeviceCode(deviceCode, completion: { (result) in
            switch result {
            case .Success( _):
                completion(.Success())
            case .Failure (let error):
                
                switch error.googleAuthenticatorError {
                case .AuthorizationPending:
                    delay(retryInterval, closure: { [weak self] in
                        guard let _ = self else {
                            return
                        }
                        
                        self!.pollAccessToken(deviceCode, retryInterval: retryInterval, completion: completion)
                    })
                default:
                    completion(.Failure(error.googleAuthenticatorError))
                }
            }
        })
    }
}

/** List of all available Google scopes supported by the Google Authenticator
     Get full scopes list at: https://developers.google.com/identity/protocols/googlescopes
 
    - GoogleAnalyticsRead: View your Google Analytics data.
    - Custom(String): Define a custom scope.
    - Collection([String]): Define a collection of scopes as an array of `String`
*/
public enum GoogleServiceScope {
    case GoogleAnalyticsRead
    case Custom(String)
    case Collection([String])
    
    public func string() -> String {
        switch self {
        case .GoogleAnalyticsRead:
            return "https://www.googleapis.com/auth/analytics.readonly"
        case Custom(let scopeString):
            return scopeString
        case Collection(let scopeCollection):
            return scopeCollection.joinWithSeparator(" ")
        }
    }
    
    init(scopeString: String) {
        switch scopeString {
        case "https://www.googleapis.com/auth/analytics.readonly":
            self = .GoogleAnalyticsRead
        default:
            self = .Custom(scopeString)
        }
    }
    
    init(scopes: [String]) {
        self = .Collection(scopes)
    }
    
    public func isEqualToScope(scope: GoogleServiceScope) -> Bool {
        return self.string() == scope.string()
    }
}