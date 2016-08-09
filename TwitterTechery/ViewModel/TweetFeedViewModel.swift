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
            if let feed = $0
            {
                self.updateFromNetworkFeed(feed)
            }
        }).start()
    }

    func fetchOldHomeFeed()
    {
        twitterNetworkFeed.getOldHomeFeed().on(next:
        {
            if let feed = $0
            {
                self.updateFromNetworkFeed(feed)
            }
        }).start()
    }

    func updateFromNetworkFeed(feed: [[String: AnyObject]])
    {
        var tweetArray: [TweetViewModel] = []

        for tweet in feed
        {
            let tweet = TweetViewModel(entity: TweetEntity(json: tweet)!, manager: twitterNetworkFeed)
            tweetArray.append(tweet)
        }

        syncTweetsModel(tweetArray)
    }

    func updateFromCoreData()
    {
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

        tweetFeed.value = tweetArray
    }
}
