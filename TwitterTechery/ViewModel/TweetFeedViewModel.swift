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

class TweetFeedViewModel
{
    let twitterFeedManager: TwitterFeedManager
    var tweetFeed: MutableProperty<[TweetViewModel]>

    init()
    {
        twitterFeedManager = TwitterFeedManager()
        tweetFeed = MutableProperty([])
        twitterFeedManager.tweetFeedViewModel = self
    }

    func getLastHomeFeed()
    {
        twitterFeedManager.getLastHomeFeed()
    }

    func fetchOldHomeFeed()
    {
        twitterFeedManager.getOldHomeFeed()
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
        }

        tweetFeed.value = tweetArray
    }
}
