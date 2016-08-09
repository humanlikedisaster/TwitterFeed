//
//  TwitterFeed.swift
//  TwitterTechery
//
//  Created by hereiam on 27.07.16.
//  Copyright © 2016 Techery. All rights reserved.
//

import UIKit
import Social
import Accounts
import ReactiveCocoa
import Alamofire
import Result

class TwitterNetworkManager: NSObject {
    var sinceId: [Int]!
    var currentSinceId: Int = 0
    var maxId: Int = 0

    private let imageQueue = dispatch_queue_create(
        "TwitterTechery.Image.Queu", DISPATCH_QUEUE_SERIAL)

    override init()
    {
        self.sinceId = [];
        self.maxId = Int.max
        super.init()
    }

    func getLastHomeFeed () -> SignalProducer<[[String: AnyObject]]?, NoError>
    {
        if TwitterAccountManager.sharedInstance.logined.value
        {
            let url = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
            var parameters : [String: AnyObject] = ["count": "20"]
            if currentSinceId > 0
            {
                parameters["since_id"] = String(currentSinceId + 1)
            }

            let twitterRequest : SLRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: url, parameters: parameters)
            twitterRequest.account = TwitterAccountManager.sharedInstance.twitterAccount
            return performTwitterRequest(twitterRequest)
        }
        else
        {
            return SignalProducer.init(value: nil)
        }
    }

    func getOldHomeFeed () -> SignalProducer<[[String: AnyObject]]?, NoError>
    {
        if TwitterAccountManager.sharedInstance.logined.value
        {
            let url = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
            let parameters : NSDictionary = ["count": "20", "max_id": String(maxId - 1)]
            let twitterRequest : SLRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: url, parameters: parameters as [NSObject : AnyObject])
            twitterRequest.account = TwitterAccountManager.sharedInstance.twitterAccount
            return  performTwitterRequest(twitterRequest)
        }
        else
        {
            return SignalProducer.init(value: nil)
        }
    }

    private func performTwitterRequest(twitterRequest: SLRequest) -> SignalProducer<[[String: AnyObject]]?, NoError>
    {
        return SignalProducer { observer, disposable in
            twitterRequest.performRequestWithHandler(
            { (responseData : NSData?, urlResponse : NSHTTPURLResponse?, error : NSError?) -> Void in
                if error != nil
                {
                    print("Error with network: " + error!.description)
                    observer.sendNext(nil)
                    observer.sendCompleted()
                }
                else
                {
                    if let response = responseData
                    {
                        do
                        {
                            if let postFeed = try NSJSONSerialization.JSONObjectWithData(response, options: .MutableContainers) as? [[String: AnyObject]]
                            {
                                self.updateRangeFromFeed(postFeed)
                                observer.sendNext(postFeed)
                                observer.sendCompleted()
                            }
                            else
                            {
                                let errorDict = NSString(data: response, encoding: NSUTF8StringEncoding)
                                print(errorDict)
                                observer.sendNext(nil)
                                observer.sendCompleted()
                            }
                        }
                        catch _
                        {
                            print("Error with parse.")
                            observer.sendNext(nil)
                            observer.sendCompleted()
                        }
                    }
                }
            })
        }
    }

    func requestImage(url: String) -> SignalProducer<UIImage?, NSError>
    {
        return SignalProducer { observer, disposable in
            let serializer = Alamofire.Request.dataResponseSerializer()
            Alamofire.request(.GET, NSURL(string: url)!)
                .response(queue: self.imageQueue, responseSerializer: serializer) {
                    response in
                    switch response.result {
                    case .Success(let data):
                        guard let image = UIImage(data: data) else {
                            observer.sendFailed(NSError(domain: "Image.Parse", code: 100, userInfo: nil))
                            return
                        }
                        observer.sendNext(image)
                        observer.sendCompleted()
                    case .Failure(let error):
                        observer.sendFailed(error)
                    }
            }
        }
    }

    func updateRangeFromFeed(feed: [[String: AnyObject]])
    {
        if let lastTweetId = feed.last?["id_str"]?.integerValue where lastTweetId < self.maxId
        {
            maxId = lastTweetId
        }
        
        if let firstTweetId = feed.first?["id_str"]?.integerValue where firstTweetId > currentSinceId
        {
            currentSinceId = firstTweetId
        }
    }
}
