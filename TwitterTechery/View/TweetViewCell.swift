//
//  TweetViewCell.swift
//  TwitterTechery
//
//  Created by hereiam on 01.08.16.
//  Copyright © 2016 Techery. All rights reserved.
//

import UIKit

class TweetViewCell: UITableViewCell {


    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userScreenNameLabel: UILabel!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var followLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var previewImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setViewModel(viewModel: TweetViewModel)
    {
        userNameLabel.text = viewModel.entity.userName
        userScreenNameLabel.text = "@" + viewModel.entity.userScreenName
        retweetLabel.text = String(viewModel.entity.retweetCount)
        followLabel.text = String(viewModel.entity.favoriteCount)
        tweetTextLabel.text = viewModel.entity.text
        viewModel.getPreviewImage()
                    .takeUntil(self.racutil_prepareForReuseProducer)
                    .on(next:
                        {
                            self.previewImageView.image = $0
                        })
                    .start()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
