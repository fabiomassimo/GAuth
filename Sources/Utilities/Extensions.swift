//
//  Extensions.swift
//  GoogleAuthenticator
//
//  Created by Fabio Milano on 12/06/16.
//  Copyright © 2016 Touchwonders. All rights reserved.
//

import Foundation

extension NSMutableURLRequest {
    public func setAccessToken(accessToken: String) -> Void {
        self.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    }
}