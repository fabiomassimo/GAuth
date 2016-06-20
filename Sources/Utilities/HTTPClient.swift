//
// HTTP.swift
//
// Copyright (c) 2016 Damien (http://delba.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
import Result

typealias JSON = [String: AnyObject]

public let HTTPErrorDomain = "HTTPErrorDomain"

internal enum HTTPErrorCode: Int {
    case NoDataFound = 1
    case JSONDeserializationError = 2
}

internal struct HTTP {
    static func POST(URL: NSURL, parameters: [String: String], completion: Result<JSON, NSError> -> Void) {
        let request = NSMutableURLRequest(URL: URL)
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        request.HTTPMethod = "POST"
        
        request.HTTPBody = parameters.map { "\($0)=\($1)" }
            .joinWithSeparator("&")
            .dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                completion(.Failure(error))
                return
            }
            
            guard let data = data else {
                let userInfo = [ NSLocalizedDescriptionKey : "No data found" ]
                let error = NSError(domain: HTTPErrorDomain, code: HTTPErrorCode.NoDataFound.rawValue, userInfo: userInfo)
                completion(.Failure(error))
                return
            }
            
            do {
                let object = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                if let dictionary = object as? JSON {
                    completion(.Success(dictionary))
                } else {
                    let userInfo = [ NSLocalizedDescriptionKey : "Cannot parse response" ]
                    let error = NSError(domain: HTTPErrorDomain, code: HTTPErrorCode.JSONDeserializationError.rawValue, userInfo: userInfo)
                    completion(.Failure(error))
                }
            } catch {
                completion(.Failure(error as NSError))
            }
        }
        
        task.resume()
    }
}