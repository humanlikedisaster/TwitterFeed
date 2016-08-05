//
//  ViewController.swift
//  TwitterTechery
//
//  Created by hereiam on 27.07.16.
//  Copyright © 2016 Techery. All rights reserved.
//

import UIKit

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

        self.twitterViewModel.tweetFeed.signal.observeNext(
        {
            (tweetFeed) in
            dispatch_async(dispatch_get_main_queue(),
            {
                self.tableView.reloadData()
            })
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
        cell.setViewModel(twitterViewModel.tweetFeed.value[indexPath.row])
        return cell
    }
}

