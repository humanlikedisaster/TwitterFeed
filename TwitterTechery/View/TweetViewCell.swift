//
//  TweetViewCell.swift
//  TwitterTechery
//
//  Created by hereiam on 01.08.16.
//  Copyright © 2016 Techery. All rights reserved.
//

import UIKit
import ReactiveCocoa

class TweetViewCell: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userScreenNameLabel: UILabel!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var followLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var aspectRationContstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setViewModel(viewModel: TweetViewModel)
    {
        userNameLabel.text = viewModel.entity.userName
        userScreenNameLabel.text = "@" + viewModel.entity.userScreenName
        retweetLabel.text = "Retweets: " + String(viewModel.entity.retweetCount)
        followLabel.text = "Follow: " + String(viewModel.entity.favoriteCount)
        tweetTextLabel.text = viewModel.entity.text
        self.previewImageView.image = viewModel.previewImage
        if let image = previewImageView.image
        {
            let allWidth = UIScreen.mainScreen().bounds.size.width
            let ratio = allWidth / image.size.width
            let heightDiffers = allWidth - image.size.height * ratio
            aspectRationContstraint.constant = heightDiffers
        }

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
