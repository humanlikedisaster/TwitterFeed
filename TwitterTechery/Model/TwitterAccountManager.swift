//
//  TwitterAccountManager.swift
//  TwitterTechery
//
//  Created by hereiam on 29.07.16.
//  Copyright © 2016 Techery. All rights reserved.
//

import UIKit
import Accounts
import ReactiveCocoa

class TwitterAccountManager: NSObject {
    static let sharedInstance = TwitterAccountManager()
    var twitterAccount: ACAccount?
    var logined = MutableProperty(false)

    override init ()
    {
        super.init()
        self.login()
    }

    func login()
    {
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)

        // Prompt the user for permission to their twitter account stored in the phone's settings
        accountStore.requestAccessToAccountsWithType(accountType, options: nil)
        {
            granted, error in
            if granted {
                let twitterAccounts = accountStore.accountsWithAccountType(accountType)
                if twitterAccounts?.count == 0
                {
                }
                else
                {
                    self.twitterAccount = twitterAccounts[0] as? ACAccount
                    self.logined.value = self.twitterAccount != nil
                }
            }
            else
            {
            }

        }
    }

    func login(Name: String, Password: String)
    {
    }
}
