//
//  TwitterManagedObject.swift
//  TwitterTechery
//
//  Created by hereiam on 09.08.16.
//  Copyright © 2016 Techery. All rights reserved.
//

import Foundation
import CoreData


class TwitterManagedObject: NSManagedObject {

    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("TwitterManagedObject", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
      }

    func setupWithTweetViewModel(tweetViewModel: TweetViewModel) {
        id = tweetViewModel.entity.id
        created_at = tweetViewModel.entity.createdAt
        follows = tweetViewModel.entity.favoriteCount
        retweets = tweetViewModel.entity.retweetCount
        text = tweetViewModel.entity.text
        userName = tweetViewModel.entity.userName
        userScreenName = tweetViewModel.entity.userScreenName
    }
}
