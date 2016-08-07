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
import Gloss

class TwitterFeedManager: NSObject {
    var sinceId: [Int]!
    var currentSinceId: Int = 0
    var maxId: Int = 0
    weak var tweetFeedViewModel: TweetFeedViewModel?

    private let imageQueue = dispatch_queue_create(
        "TwitterTechery.Image.Queu", DISPATCH_QUEUE_SERIAL)

    override init()
    {
        self.sinceId = [];
        self.maxId = Int.max
        super.init()

        TwitterAccountManager.sharedInstance.logined.signal.observeNext
        { (logined) in
            if logined
            {
                self.getLastHomeFeed()
            }
        }
    }

    func getLastHomeFeed ()
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
            performTwitterRequest(twitterRequest)
        }
    }

    func getOldHomeFeed ()
    {
        if TwitterAccountManager.sharedInstance.logined.value
        {
            let url = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
            let parameters : NSDictionary = ["count": "20", "max_id": String(maxId - 1)]
            let twitterRequest : SLRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: url, parameters: parameters as [NSObject : AnyObject])
            twitterRequest.account = TwitterAccountManager.sharedInstance.twitterAccount
            performTwitterRequest(twitterRequest)
        }
    }

    private func performTwitterRequest(twitterRequest: SLRequest)
    {
        twitterRequest.performRequestWithHandler(
        { (responseData : NSData?, urlResponse : NSHTTPURLResponse?, error : NSError?) -> Void in
            if error != nil
            {
                print("Error with network: " + error!.description)
            }
            else
            {
                if let response = responseData
                {
                    do
                    {
                        if let postFeed = try NSJSONSerialization.JSONObjectWithData(response, options: .MutableContainers) as? [[String: AnyObject]]
                        {
                            self.updatePostFeed(postFeed)
                        }
                        else
                        {
                            let errorDict = NSString(data: response, encoding: NSUTF8StringEncoding)
                            print(errorDict)
                        }
                    }
                    catch _
                    {
                        print("Error with parse.")
                    }
                }
            }
        })
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

    func updatePostFeed(feed: [[String: AnyObject]])
    {
        if let lastTweetId = feed.last?["id_str"]?.integerValue where lastTweetId < self.maxId
        {
            maxId = lastTweetId
        }
        
        if let firstTweetId = feed.first?["id_str"]?.integerValue where firstTweetId > currentSinceId
        {
            currentSinceId = firstTweetId
        }

        var tweetArray: [TweetViewModel] = []

        for tweet in feed
        {
            let entity = TweetEntity(json: tweet)
            let tweet = TweetViewModel(entity: entity!, manager: self)
            tweetArray.append(tweet)
        }
        tweetFeedViewModel?.syncTweetsModel(tweetArray)
    }
}
