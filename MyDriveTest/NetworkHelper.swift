//
//  NetworkHelper.swift
//  MyDriveTest
//
//  Created by galmarom on 13/11/2016.
//  Copyright © 2016 galmarom. All rights reserved.
//

import UIKit

public typealias URLRequestClosure = ((Data?,URLResponse?,Error?) -> Void)

extension Dictionary {
    //Builds a string representation from the keys and value of the dictionary in the form of: k1=v1&k2=v2
    func convertToHttpParamsString() -> String {
        let parameterArray = self.map {
            return "\(String(describing: $0))=\(String(describing: $1))"
        }
        return parameterArray.joined(separator:"&")
    }
}

class NetworkHelper : NSObject {
    
    static let sharedInstance = NetworkHelper()
    
    //Dynamic vars
    lazy var baseURL : String = {
        return Bundle.main.object(forInfoDictionaryKey: "JSON source URL") as! String
    }()
    
    /**
     Sending a url request
     
     - parameter url: The request url
     - parameter parameters: A parameters' dictionary that will be chaind to the URL base
     - parameter completionHandler:  ((Data?,URLResponse?,Error?) -> Void) closure that will be invoked upon request's completion
     */
    class func sendRequest(url urlAsString: String, parameters: [String: AnyObject]?, withCompletionHandler completionHandler: @escaping URLRequestClosure) {
        var urlStringWithParams = urlAsString
        if let parameters = parameters {
            urlStringWithParams += "?\(parameters.convertToHttpParamsString())"
        }
        let requestURL = URL(string:urlStringWithParams)
        if requestURL != nil {
            let task = URLSession.shared.dataTask(with: requestURL!, completionHandler: completionHandler)
            task.resume()
        }
    }
}




