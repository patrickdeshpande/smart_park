//
//  EZHttp.swift
//  NetworkTests
//
//  Created by Patrick Deshpande on 6/17/16.
//  Copyright © 2016 Patrick Deshpande. All rights reserved.
//

import Foundation

class EZHttp {
    init(inurl:String, inparam:String?, inmethod:String?, completion: ((NSData?, NSURLResponse?, NSError?) -> Void)!){
        url = inurl
        if inparam != nil {
            parameters = inparam
        }
        if inmethod != nil {
            method = inmethod!
        }
        dataRequest(completion)
    }
    var url: String!
    var parameters: String!
    var method = "POST"
    
    func dataRequest(completion: ((NSData?, NSURLResponse?, NSError?) -> Void)!){
        NSOperationQueue.mainQueue().addOperationWithBlock{
            let request = NSMutableURLRequest(URL: NSURL(string: self.url)!)
            request.HTTPMethod = self.method
            if self.parameters != nil {
                request.HTTPBody = self.parameters.dataUsingEncoding(NSUTF8StringEncoding)
            }
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: completion)
            task.resume()
        }
    }
}