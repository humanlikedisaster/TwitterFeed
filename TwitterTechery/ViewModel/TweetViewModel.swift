//
//  TweetViewModel.swift
//  TwitterTechery
//
//  Created by hereiam on 31.07.16.
//  Copyright © 2016 Techery. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Gloss

internal struct TweetEntity: Decodable {
    let id: String
    let userName: String
    let userScreenName: String
    let favoriteCount: Int
    let retweetCount: Int
    let createdAt: NSDate
    let text: String
    let previewImageURL: String?

    internal init?(managedObject: TwitterManagedObject)
    {
        self.id = managedObject.id!
        self.favoriteCount = managedObject.follows!.integerValue
        self.retweetCount = managedObject.retweets!.integerValue
        self.text = managedObject.text!
        self.userName = managedObject.userName!
        self.userScreenName = managedObject.userScreenName!
        self.createdAt = managedObject.created_at!
        self.previewImageURL = managedObject.imageURL
    }

    internal init?(json: JSON) {
        self.id = ("id_str" <~~ json)!
        self.text = ("text" <~~ json)!
        self.favoriteCount = ("favorite_count" <~~ json)!
        self.retweetCount = ("retweet_count" <~~ json)!

        guard let createdAtString: String = "created_at" <~~ json
            else { return nil }
        self.createdAt = createdAtString.twitterDate

        guard let user: JSON = "user" <~~ json,
            entities: JSON = "entities" <~~ json
            else {return nil}

        guard let userScreenName: String = "screen_name" <~~ user,
            userName: String = "name" <~~ user
            else { return nil }

        let media: [JSON]? = "media" <~~ entities
        if let mediaJSON = media?.first
        {
            let media_url_https: String? = "media_url_https" <~~ mediaJSON
            self.previewImageURL = media_url_https
        }
        else
        {
            self.previewImageURL = nil
        }

        self.userName = userName
        self.userScreenName = userScreenName
    }
}

func == (left: TweetEntity, right: TweetEntity) -> Bool
{
    return (left.id == right.id)
}

func == (left: TweetViewModel, right: TweetViewModel) -> Bool
{
    return (left.entity == right.entity)
}

class TweetViewModel: NSObject  {
    var entity: TweetEntity
    unowned var manager: TwitterNetworkManager
    var previewImage: UIImage?
    var previewImageSignalProducer: SignalProducer<UIImage?, NSError>?

    init(entity: TweetEntity, manager: TwitterNetworkManager)
    {
        self.entity = entity
        self.manager = manager
    }

    convenience init(model: TwitterManagedObject, manager: TwitterNetworkManager)
    {
        self.init(entity: TweetEntity(managedObject: model)!, manager: manager)
    }

    func loadImage()
    {
        if let previewImageURL = entity.previewImageURL
        {
            self.previewImageSignalProducer = manager.requestImage(previewImageURL)
                        .on(next:
                        {
                            self.previewImage = $0
                        })
                        .map { $0 as UIImage? }
                        .flatMapError { _ in SignalProducer<UIImage?, NSError>(value: nil) }

             self.previewImageSignalProducer!.start()
        }
    }

    func getPreviewImage() -> SignalProducer<UIImage?, NSError> {
        if nil != entity.previewImageURL
        {
            if let previewImage = self.previewImage {
                return SignalProducer(value: previewImage).observeOn(UIScheduler())
            }
            else {
                let signalProducer = SignalProducer(value: nil)
                    .concat(self.previewImageSignalProducer!)
                    .observeOn(UIScheduler())

                return signalProducer
            }
        }
        else
        {
            return SignalProducer(value: nil).observeOn(UIScheduler())
        }
    }
}
