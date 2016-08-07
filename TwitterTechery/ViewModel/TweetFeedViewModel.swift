//
//  TweetFeedViewModel.swift
//  TwitterTechery
//
//  Created by hereiam on 31.07.16.
//  Copyright © 2016 Techery. All rights reserved.
//

import UIKit
import ReactiveCocoa

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

    func syncTweetsModel(tweets:[TweetViewModel])
    {
        for tweet in tweets
        {
            let tweetArray = tweetFeed.value
            var newArray = tweetArray.map({$0.entity.id == tweet.entity.id ? tweet : $0})

            if newArray == tweetArray && !newArray.contains(tweet)
            {
                newArray.append(tweet)
            }

            if newArray != tweetArray
            {
                tweetFeed.value = newArray
            }
        }
    }
}
