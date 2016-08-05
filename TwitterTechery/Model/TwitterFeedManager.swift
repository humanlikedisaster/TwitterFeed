//
//  TwitterFeed.swift
//  TwitterTechery
//
//  Created by hereiam on 27.07.16.
//  Copyright © 2016 Techery. All rights reserved.
//

import UIKit
import Social
import CoreData
import Accounts
import ReactiveCocoa
import Alamofire

class TwitterFeedManager: NSObject {
    var sinceId: [Int]!
    var maxId: Int
    weak var tweetFeedViewModel: TweetFeedViewModel?
    var posts = [NSManagedObject]()

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
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        let parameters : NSDictionary = ["count": "20"]
        let twitterRequest : SLRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: url, parameters: parameters as [NSObject : AnyObject])
        twitterRequest.account = TwitterAccountManager.sharedInstance.twitterAccount
        twitterRequest.performRequestWithHandler(
            { (responseData : NSData?, urlResponse : NSHTTPURLResponse?, error : NSError?) -> Void in
                if error != nil
                {
                }
                else
                {
                    if let response = responseData
                    {
                    var postFeed = NSArray()
                        do
                        {
                            postFeed = try! NSJSONSerialization.JSONObjectWithData(response, options: .MutableContainers) as! NSArray
                            self.updatePostFeed(postFeed)
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

    func updatePostFeed(Feed: NSArray!)
    {
        let lastTweet = Feed.lastObject as! NSDictionary
        let firstTweet = Feed.firstObject as! NSDictionary
        if lastTweet["id"]!.integerValue < self.maxId
        {
            self.maxId = lastTweet["id"] as! Int
        }
        self.sinceId.append(firstTweet["id"] as! Int)

        var tweetArray: [TweetViewModel] = []

        for Tweet in Feed as! [NSDictionary]
        {
            let UserInfo = Tweet["user"]! as! NSDictionary

            let id = Tweet["id_str"] as! String
            let text = Tweet["text"] as! String
            let userScreenName = UserInfo["screen_name"] as! String
            let userName = UserInfo["name"] as! String
            let favoriteCount =  Tweet["favorite_count"] as! Int
            let retweetCount = Tweet["retweet_count"] as! Int
            let createdAt = Tweet["created_at"] as! String
            let imageURL = UserInfo["profile_image_url_https"] as! String
            let entity = TweetEntity(id: id, userName: userName, userScreenName: userScreenName, favoriteCount: favoriteCount, retweetCount: retweetCount, createdAt: createdAt, text: text, previewImage: imageURL)
            let tweet = TweetViewModel(entity: entity, manager: self)
            tweetArray.append(tweet)
        }
        tweetFeedViewModel?.syncTweetsModel(tweetArray)
    }

    func wakeUpOldPosts()
    {
        posts = CoreDataManager.sharedInstance.getAllSavedPost()
    }
}
