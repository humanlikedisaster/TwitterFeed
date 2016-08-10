//
//  TweetFeedViewModel.swift
//  TwitterTechery
//
//  Created by hereiam on 31.07.16.
//  Copyright © 2016 Techery. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result
import CoreData

class TweetFeedViewModel
{
    let twitterNetworkFeed: TwitterNetworkManager
    var tweetFeed: MutableProperty<[TweetViewModel]>
    
    init()
    {
        twitterNetworkFeed = TwitterNetworkManager()
        tweetFeed = MutableProperty([])
        TwitterAccountManager.sharedInstance.logined.signal.observeNext
        { (logined) in
            if logined
            {
                self.getLastHomeFeed()
            }
        }
    }

    func getLastHomeFeed()
    {
        twitterNetworkFeed.getLastHomeFeed().on(next:
        {
            self.updateFromNetworkFeed($0)
        }).start()
    }

    func fetchOldHomeFeed()
    {
        twitterNetworkFeed.getOldHomeFeed().on(next:
        {
            self.updateFromNetworkFeed($0)
        }).start()
    }

    func updateFromNetworkFeed(feed: [[String: AnyObject]]?)
    {
        if let feedArray = feed
        {
            var tweetArray: [TweetViewModel] = []

            for tweet in feedArray
            {
                let tweet = TweetViewModel(entity: TweetEntity(json: tweet)!, manager: twitterNetworkFeed)
                tweetArray.append(tweet)
            }

            syncTweetsModel(tweetArray)
        }
        else
        {
            self.updateFromCoreData()
        }
    }

    func updateFromCoreData()
    {
        var tweetArray: [TweetViewModel] = []

        for managedObject in CoreDataManager.sharedInstance.posts
        {
            let tweet = TweetViewModel(model: managedObject, manager: twitterNetworkFeed)
            tweetArray.append(tweet)
        }

        syncTweetsModel(tweetArray)
    }

    func syncTweetsModel(tweets:[TweetViewModel])
    {
        var tweetArray = tweetFeed.value
        
        for tweet in tweets
        {
            if !tweetArray.contains(tweet)
            {
                tweetArray.append(tweet)
                tweet.loadImage()
            }
            else
            {
                tweet.previewImage = tweetArray[tweetArray.indexOf(tweet)!].previewImage
                tweet.previewImageSignalProducer = tweetArray[tweetArray.indexOf(tweet)!].previewImageSignalProducer
                tweetArray[tweetArray.indexOf(tweet)!] = tweet
            }
            CoreDataManager.sharedInstance.syncTweet(tweet)
        }
        tweetArray = tweetArray.sort { $0.entity.createdAt.compare($1.entity.createdAt) == NSComparisonResult.OrderedDescending }

        tweetFeed.value = tweetArray
    }
}
