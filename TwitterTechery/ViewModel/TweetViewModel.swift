//
//  TweetViewModel.swift
//  TwitterTechery
//
//  Created by hereiam on 31.07.16.
//  Copyright © 2016 Techery. All rights reserved.
//

import UIKit
import ReactiveCocoa

public struct TweetEntity {
    var id: String
    var userName: String
    var userScreenName: String
    var favoriteCount: Int
    var retweetCount: Int
    var createdAt: String
    var text: String
    var previewImageURL: String

    init(id: String, userName: String, userScreenName: String, favoriteCount: Int, retweetCount: Int, createdAt: String, text: String, previewImage: String)
    {
        self.id = id
        self.userName = userName
        self.userScreenName = userScreenName
        self.favoriteCount = favoriteCount
        self.retweetCount = retweetCount
        self.createdAt = createdAt
        self.text = text
        self.previewImageURL = previewImage
    }
}

func == (left: TweetEntity, right: TweetEntity) -> Bool
{
    return (left.id == right.id) &&
        (left.userName == right.userName) &&
        (left.userScreenName == right.userScreenName) &&
        (left.favoriteCount == right.favoriteCount) &&
        (left.retweetCount == right.retweetCount) &&
        (left.createdAt == right.createdAt) &&
        (left.text == right.text)
}

class TweetViewModel: NSObject  {
    var entity: TweetEntity
    unowned var manager: TwitterFeedManager
    var previewImage: UIImage?

    init(entity: TweetEntity, manager: TwitterFeedManager)
    {
        self.entity = entity
        self.manager = manager
    }

    func getPreviewImage() -> SignalProducer<UIImage?, NSError> {
        if let previewImage = self.previewImage {
            return SignalProducer(value: previewImage).observeOn(UIScheduler())
        }
        else {
            let imageProducer = manager.requestImage(entity.previewImageURL)
                .takeUntil(self.racutil_willDeallocProducer)
                .on(next: { self.previewImage = $0 })
                .map { $0 as UIImage? }
                .flatMapError { _ in SignalProducer<UIImage?, NSError>(value: nil) }

            return SignalProducer(value: nil)
                .concat(imageProducer)
                .observeOn(UIScheduler())
        }
    }
}
