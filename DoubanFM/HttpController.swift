//
//  HttpController.swift
//  DoubanFM
//
//  Created by DJ on 14/10/16.
//  Copyright (c) 2014年 DJ. All rights reserved.
//

import Foundation

protocol HttpProtocol {
    func didReceiveResults(results: NSDictionary)
}

class HttpController: NSObject {
    
    var delegate:HttpProtocol?
    
    func onSearchWithUrl(url: String) {
        var nsUrl = NSURL(string: url)
        var request = NSURLRequest(URL: nsUrl!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
//            let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary
            if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
                println(nsUrl)
                self.delegate?.didReceiveResults(jsonResult)
            }
        })
    }
}
