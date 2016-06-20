//
//  ViewController.swift
//  GoogleAuthenticatorTV Example
//
//  Created by Fabio Milano on 13/06/16.
//  Copyright © 2016 Touchwonders. All rights reserved.
//

import UIKit
import GAuth
import Result

class ViewController: UIViewController {
    @IBOutlet weak var accessTokenLabel: UILabel!
    @IBOutlet weak var deviceCodeLabel: UILabel!
    @IBOutlet weak var verificationUrlLabel: UILabel!

    private var authenticator = GoogleAuthenticatorClient<OAuth2SwiftGoogleAuthenticator>(consumerKey: "***CONSUMER KEY***", consumerSecret:"***CONSUMER SECRET***", bundleIdentifier: NSBundle.mainBundle().bundleIdentifier!, scope: GoogleServiceScope.GoogleAnalyticsRead)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accessTokenLabel.text = ""
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        authenticator.authorizeDevice({ [unowned self] (verificationUrl, userCode) in
            self.verificationUrlLabel.text = verificationUrl.absoluteString
            self.deviceCodeLabel.text = userCode
        }) { [unowned self] (result) in
            switch result {
            case .Success():
                self.accessTokenLabel.textColor = UIColor.greenColor()
                self.accessTokenLabel.text = "Authorized"
            case .Failure(let error):
                self.accessTokenLabel.textColor = UIColor.redColor()
                switch error{
                case .DeviceVerificationFailed(let description):
                    self.accessTokenLabel.text = description
                case .AuthorizationError(let description):
                    self.accessTokenLabel.text = description
                case .InvalidAccessToken:
                    self.accessTokenLabel.text = "Invalid access token"
                default:
                    self.accessTokenLabel.text = "Loading..."
                }
                
            }
        }
        accessTokenLabel.text = "Loading..."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

import OAuthSwift

extension OAuthSwiftCredential: AuthorizedToken {
    public var accessToken: String {
        return self.oauth_token
    }
    
    public var refreshToken: String? {
        return self.oauth_refresh_token
    }
    
    public var expiresIn: NSTimeInterval? {
        return self.expiresIn
    }
    
    public var isExpired: Bool {
        return self.isTokenExpired()
    }
    
    public var scopes: [String]? {
        return nil
    }
}

extension NSError: GoogleAuthenticatorErrorAdapter {
    public var googleAuthenticatorError: GoogleAuthenticatorError {
        switch self.code {
        case OAuthSwiftErrorCode.GeneralError.rawValue:
            return GoogleAuthenticatorError.AuthorizationError(self.localizedDescription)
        case OAuthSwiftErrorCode.TokenExpiredError.rawValue:
            return GoogleAuthenticatorError.AuthorizationError(self.localizedDescription)
        case OAuthSwiftErrorCode.MissingStateError.rawValue:
            return GoogleAuthenticatorError.AuthorizationError(self.localizedDescription)
        case OAuthSwiftErrorCode.StateNotEqualError.rawValue:
            return GoogleAuthenticatorError.AuthorizationError(self.localizedDescription)
        case OAuthSwiftErrorCode.ServerError.rawValue:
            return GoogleAuthenticatorError.AuthorizationError(self.localizedDescription)
        case OAuthSwiftErrorCode.EncodingError.rawValue:
            return GoogleAuthenticatorError.AuthorizationError(self.localizedDescription)
        case OAuthSwiftErrorCode.AuthorizationPending.rawValue:
            return GoogleAuthenticatorError.AuthorizationPending
        default:
            return GoogleAuthenticatorError.AuthorizationError(self.localizedDescription)
        }
    }
}

struct OAuth2SwiftGoogleAuthenticator: GoogleAuthenticatorOAuthClient {
    typealias OAuthClientType = OAuth2SwiftGoogleAuthenticator
    typealias TokenType = OAuthSwiftCredential
    typealias Failure = NSError
    
    let oauthClient: OAuth2Swift
    
    /// The client ID.
    let clientID: String
    
    /// The client secret.
    let clientSecret: String
    
    /// The authorize URL.
    let authorizeURL: NSURL
    
    /// The token URL.
    let tokenURL: NSURL?
    
    /// The redirect URL.
    let redirectURL: NSURL?
    
    /// The token
    let token: TokenType?
    
    /// The scopes.
    let scopes: [String]
    
    static func Google(clientID clientID: String, clientSecret: String, bundleIdentifier: String, scope: GoogleServiceScope) -> OAuth2SwiftGoogleAuthenticator {
        let oauthClient = OAuth2Swift(consumerKey: clientID, consumerSecret: clientSecret, authorizeUrl: AuthenticationConstants.AuthorizeUrl.rawValue, accessTokenUrl: AuthenticationConstants.AccessTokensUrl.rawValue, responseType: "http://oauth.net/grant_type/device/1.0")
        
        return OAuth2SwiftGoogleAuthenticator(oauthClient: oauthClient, clientID: clientID, clientSecret: clientSecret, authorizeURL: AuthenticationConstants.AuthorizeUrl.URL, tokenURL: AuthenticationConstants.AccessTokensUrl.URL, redirectURL:nil, token: nil, scopes: [ scope.string() ] )
    }
    
    func googleAuthenticatorRefreshToken(completion: Result<TokenType, Failure> -> Void) {
        oauthClient.refreshToken { result in
            completion(result)
        }
    }
    
    func googleAuthenticatorAuthorizeDeviceCode(deviceCode: String, completion: Result<TokenType, Failure> -> Void) {
        oauthClient.authorizeDeviceCode(deviceCode) { result in
            completion(result)
        }
    }
}

extension OAuth2Swift {
    public func refreshToken(completion: Result<OAuthSwiftCredential, NSError> -> Void) {
        // Due to lack of a public function to renew the token we ask to authorize a dummy request in order to retrieve a renewed token from the `onTokenRenewal` closure.
        startAuthorizedRequest("http://requestToRefreshToken", method: OAuthSwiftHTTPRequest.Method.GET, parameters: [:], headers: nil, onTokenRenewal: { credential in
            completion(.Success(credential))
            }, success: { (data, response) in
                // completion block already called in previous onTokenRenewal closure.
            }) { error in
                completion(.Failure(error))
        }
    }
    
    public func authorizeDeviceCode(deviceCode: String, completion: Result<OAuthSwiftCredential, NSError> -> Void) {
        authorizeDeviceToken(deviceCode, success: { credential in
            completion(.Success(credential))
            }) { error in
                completion(.Failure(error))
        }
    }
}
