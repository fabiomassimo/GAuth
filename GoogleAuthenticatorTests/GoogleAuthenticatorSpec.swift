//
//  GoogleAuthenticatorSpec.swift
//  GoogleAuthenticator
//
//  Created by Fabio Milano on 14/06/16.
//  Copyright © 2016 Touchwonders. All rights reserved.
//

import Foundation
import Result

@testable import GoogleAuthenticator

public struct TokenMock {
    public let accessToken: String
    
    public let refreshToken: String?
    
    public let expiresIn: NSTimeInterval?
    
    public let isExpired: Bool
    
    public let isValid: Bool
    
    public let scopes: [String]?
    
    static func expiredToken() -> TokenMock {
        return TokenMock(accessToken: "ACCESS_TOKEN", refreshToken: "REFRESH_TOKEN", expiresIn: 3600, isExpired: true, isValid: false, scopes: ["test_scope"])
    }
    
    static func validToken() -> TokenMock {
        return TokenMock(accessToken: "ACCESS_TOKEN", refreshToken: "REFRESH_TOKEN", expiresIn: 3600, isExpired: false, isValid: true, scopes: ["test_scope"])
    }
}

enum TokenFeatures {
    case Valid
    case Expired
}

public class OAuthMockClient {
    
    /// The client ID.
    public let clientID: String
    
    /// The client secret.
    public let clientSecret: String
    
    /// The authorize URL.
    public let authorizeURL: NSURL
    
    /// The token URL.
    public let tokenURL: NSURL?
    
    /// The redirect URL.
    public let redirectURL: NSURL?
    
    public let scopes: [String]
    
    public var token: TokenMock?
    
    init(tokenFeatures: TokenFeatures, clientID: String = "CLIENT_ID", clientSecret: String = "CLIENT_SECRET",
         authorizeURL: NSURL = NSURL(string: "http://authorizeurl.touchwonders.com")!, tokenURL: NSURL = NSURL(string: "http://tokenurl.touchwonders.com")!,
         redirectURL: NSURL = NSURL(string: "http://redirecturl.touchwonders.com")!,
         scopes: [String] = ["test_scope"]) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.authorizeURL = authorizeURL
        self.tokenURL = tokenURL
        self.redirectURL = redirectURL
        self.scopes = scopes
        
        switch tokenFeatures {
        case .Valid:
            self.token = TokenMock.validToken()
        case .Expired:
            self.token = TokenMock.expiredToken()
        }
    }
    
    var nextOAuthClientError: GoogleAuthenticatorError?
}

extension TokenMock: AuthorizedToken { }

extension GoogleAuthenticatorError: GoogleAuthenticatorErrorAdapter {
    public var googleAuthenticatorError: GoogleAuthenticatorError {
        return self
    }
}

extension GoogleAuthenticatorClient {
    public func invalidateClientNextRequestWithError(error: GoogleAuthenticatorError) -> Void {
        let client = oauthClient as! OAuthMockClient
        client.nextOAuthClientError = GoogleAuthenticatorError.AuthorizationPending
    }
}

extension OAuthMockClient: GoogleAuthenticatorOAuthClient {
    public typealias OAuthClientType = OAuthMockClient
    public typealias TokenType = TokenMock
    public typealias Failure = GoogleAuthenticatorError
    
    public static func Google(clientID clientID: String, clientSecret: String, bundleIdentifier: String, scope: GoogleServiceScope) -> OAuthMockClient {
        return OAuthMockClient(tokenFeatures: TokenFeatures.Valid)
    }
    
    public func googleAuthenticatorRefreshToken(completion: Result<TokenType, GoogleAuthenticatorError> -> Void) {
        
        if let nextOAuthClientError = nextOAuthClientError {
            self.nextOAuthClientError = nil
            completion(.Failure(nextOAuthClientError))
            return
        }
        
        self.token = TokenMock.validToken()
        completion(.Success(token!))
    }
    
    public func googleAuthenticatorAuthorize(completion: Result<TokenType, GoogleAuthenticatorError> -> Void) {
        
        if let nextOAuthClientError = nextOAuthClientError {
            self.nextOAuthClientError = nil
            completion(.Failure(nextOAuthClientError))
            return
        }
        
        completion(.Success(token!))
    }
    
    public func googleAuthenticatorAuthorizeDeviceCode(deviceCode: String, completion: Result<TokenType, GoogleAuthenticatorError> -> Void) {
        
        if let nextOAuthClientError = nextOAuthClientError {
            self.nextOAuthClientError = nil
            completion(.Failure(nextOAuthClientError))
            return
        }
        
        completion(.Success(token!))
    }
}