//
//  ViewController.swift
//  TwitterTechery
//
//  Created by hereiam on 27.07.16.
//  Copyright © 2016 Techery. All rights reserved.
//

import UIKit
import ReactiveCocoa

class TwitterViewController: UITableViewController {
    let twitterViewModel: TweetFeedViewModel
    
    required init?(coder aDecoder: NSCoder) {
        twitterViewModel = TweetFeedViewModel()
        super.init(coder: aDecoder)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.registerNib(UINib.init(nibName: "TweetViewCell", bundle: nil), forCellReuseIdentifier: "TweetViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100

        self.twitterViewModel.tweetFeed.signal.observeOn(UIScheduler())
            .observeNext( {
                (tweetFeed) in
                self.tableView.reloadData()
            })
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(animated: Bool)
    {
        self.tableView.reloadData()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return twitterViewModel.tweetFeed.value.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetViewCell") as! TweetViewCell
        let viewModel = twitterViewModel.tweetFeed.value[indexPath.row]
        viewModel.getPreviewImage()
            .takeUntil(cell.racutil_prepareForReuseProducer)
            .on( next:
            { (image) in
                if let indexPathCell = tableView.indexPathForCell(cell) where
                    nil != image
                {
                    tableView.beginUpdates()
                    tableView.reloadRowsAtIndexPaths([indexPathCell], withRowAnimation: .Automatic)
                    tableView.endUpdates()
                }
            }).start()

        cell.setViewModel(viewModel)
        return cell
    }
}

