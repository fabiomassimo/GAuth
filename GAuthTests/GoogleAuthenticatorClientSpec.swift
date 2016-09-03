//
//  GoogleAuthenticatorClientSpec.swift
//  GoogleAuthenticatorSpec
//
//  Created by Fabio Milano on 13/06/16.
//  Copyright © 2016 Touchwonders. All rights reserved.
//

import Nimble
import Quick
import OHHTTPStubs
import Result

@testable import GAuth

class GoogleAuthenticatorClientSpec: QuickSpec {
    
    let bundle = NSBundle(forClass: GoogleAuthenticatorClient<OAuthMockClient>.self)
    
    override func spec(){
        describe("-authenticateRequest") {
            context("when successfully authenticate a NSURLRequest") {
                var authenticator: GoogleAuthenticatorClient<OAuthMockClient>?
                
                it("the request gets properly authenticated with valid access token") {
                    authenticator = GoogleAuthenticatorClient<OAuthMockClient>(oauthClient: OAuthMockClient(tokenFeatures: TokenFeatures.Valid))
                    
                    let originalRequest = NSURLRequest(URL: NSURL(string: "http://googleauthenticator.touchwonders.com")!)
                    
                    waitUntil(action: { done in
                        authenticator!.authenticateRequest(originalRequest, completion: { (result) in
                            switch result {
                            case .Success(let authenticatedRequest):
                                expect(originalRequest.HTTPMethod).to(equal(authenticatedRequest.HTTPMethod))
                                expect(originalRequest.HTTPBody).to(beNil())
                                expect(originalRequest.cachePolicy).to(equal(authenticatedRequest.cachePolicy))
                                expect(originalRequest.HTTPShouldHandleCookies).to(equal(authenticatedRequest.HTTPShouldHandleCookies))
                                expect(originalRequest.HTTPBodyStream).to(beNil())
                                expect(originalRequest.URL).to(equal(authenticatedRequest.URL))
                                expect(authenticatedRequest.valueForHTTPHeaderField("Authorization")).toNot(beNil())
                            case .Failure(let error):
                                switch error {
                                default:
                                    fail("Impossible to authorize the request")
                                }
                            }
                            
                            done()
                        })
                    })
                }
                
                it("the request get properly authenticated by first refreshing an expired token"){
                    authenticator = GoogleAuthenticatorClient<OAuthMockClient>(oauthClient: OAuthMockClient(tokenFeatures: TokenFeatures.Expired))
                    
                    let originalRequest = NSURLRequest(URL: NSURL(string: "http://googleauthenticator.touchwonders.com")!)
                    
                    waitUntil(action: { (done) in
                        authenticator!.authenticateRequest(originalRequest, completion: { (result) in
                            switch result {
                            case .Success(let authenticatedRequest):
                                expect(originalRequest.HTTPMethod).to(equal(authenticatedRequest.HTTPMethod))
                                expect(originalRequest.HTTPBody).to(beNil())
                                expect(originalRequest.cachePolicy).to(equal(authenticatedRequest.cachePolicy))
                                expect(originalRequest.HTTPShouldHandleCookies).to(equal(authenticatedRequest.HTTPShouldHandleCookies))
                                expect(originalRequest.HTTPBodyStream).to(beNil())
                                expect(originalRequest.URL).to(equal(authenticatedRequest.URL))
                                expect(authenticatedRequest.valueForHTTPHeaderField("Authorization")).toNot(beNil())
                            case .Failure(let error):
                                switch error {
                                default:
                                    fail("Impossible to authorize the request")
                                }
                            }
                            
                            done()
                        })
                    })
                }
                
            }
        }
        
        describe("-pollAccessToken") {
            context("when successfully retrieve a new access token") {
                let authenticator = GoogleAuthenticatorClient<OAuthMockClient>(oauthClient: OAuthMockClient(tokenFeatures: TokenFeatures.Valid))
                
                
                it("authorizes the user") {
                    waitUntil(action: { done in
                        authenticator.pollAccessToken("DEVICE_TOKEN", retryInterval: 0.5, completion: { result in
                            switch result {
                            case .Success( _):
                                done()
                            case .Failure(let error):
                                fail("Impossible to authorize user: \(error)")
                            }
                        })
                    })
                }
                
                it("authorizes the user after one retry") {
                    // Make sure first request will fail with an authorization pending error
                    authenticator.invalidateClientNextRequestWithError(GoogleAuthenticatorError.AuthorizationPending)
                    
                    waitUntil(timeout: 2.0, action: { done in
                        authenticator.pollAccessToken("DEVICE_TOKEN", retryInterval: 0.5, completion: { result in
                            switch result {
                            case .Success( _):
                                done()
                            case .Failure(let error):
                                fail("Impossible to authorize user: \(error)")
                            }
                        })
                    })
                }
            }
        }
        
        describe("Helpers") {
            context("parameters") {
                let authenticator = GoogleAuthenticatorClient<OAuthMockClient>(oauthClient: OAuthMockClient(tokenFeatures: TokenFeatures.Valid))
                
                it("for device verification request") {
                    let parameters = authenticator.parametersForDeviceVerification()
                    expect(parameters["client_id"]).to(equal("CLIENT_ID"))
                    expect(parameters["scope"]).to(equal("test_scope"))
                }
                it("for device authorization request") {
                    let parameters = authenticator.parametersForDeviceAuthorization("TEST_CODE")
                    expect(parameters["client_id"]).to(equal("CLIENT_ID"))
                    expect(parameters["client_secret"]).to(equal("CLIENT_SECRET"))
                    expect(parameters["code"]).to(equal("TEST_CODE"))
                    expect(parameters["grant_type"]).to(equal("http://oauth.net/grant_type/device/1.0"))
                }
            }
        }
    }
}
