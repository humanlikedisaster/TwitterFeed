//
//  RACUtils.swift
//  TwitterTechery
//
//  Created by hereiam on 04.08.16.
//  Copyright © 2016 Techery. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

internal extension NSObject {
    internal var racutil_willDeallocProducer: SignalProducer<(), NoError>  {
        return self.rac_willDeallocSignal()
            .toSignalProducer()
            .map { _ in }
            .flatMapError { _ in SignalProducer(value: ()) }
    }
}

internal extension UITableViewCell {
    internal var racutil_prepareForReuseProducer: SignalProducer<(), NoError>  {
        return self.rac_prepareForReuseSignal
            .toSignalProducer()
            .map { _ in }
            .flatMapError { _ in SignalProducer(value: ()) }
    }
}