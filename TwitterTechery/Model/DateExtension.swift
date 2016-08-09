//
//  DateExtension.swift
//  TwitterTechery
//
//  Created by hereiam on 09.08.16.
//  Copyright © 2016 Techery. All rights reserved.
//

import Foundation

extension NSDateFormatter {
    convenience init(dateStyle: NSDateFormatterStyle) {
        self.init()
        self.dateStyle = dateStyle
    }

    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
}

extension NSDate {
    struct Formatter {
        static let twitterDate = NSDateFormatter(dateFormat: "EEE MMM dd HH:mm:ss Z yyyy")
    }
    var twitterDateString: String {
        let dateFormatter = Formatter.twitterDate
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")

        return dateFormatter.stringFromDate(self)
    }
}

extension String {
    struct Formatter {
        static let twitterDate = NSDateFormatter(dateFormat: "EEE MMM dd HH:mm:ss Z yyyy")
    }
    var twitterDate: NSDate {
        let dateFormatter = Formatter.twitterDate
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")

        let dateFromString : NSDate = dateFormatter.dateFromString(self)!

        return dateFromString
    }
}