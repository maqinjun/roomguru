//
//  Defines.swift
//  Roomguru
//
//  Created by Radoslaw Szeja on 12/03/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON

// MARK: Types
// MARK: - Closures

typealias VoidBlock = Void -> Void
typealias ResponseBlock = (response: JSON?) -> Void
typealias ListResponseBlock = (response: [AnyObject]?) -> Void
typealias ErrorBlock = (error: NSError) -> Void

// MARK: - Data types

typealias QueryParameters = [String: AnyObject]


// MARK: Notifications

let RoomguruGooglePlusAuthenticationDidFinishNotification = "RoomguruGooglePlusAuthenticationDidFinishNotification"

// MARK: Reuse identifiers

let UITableViewCellReuseIdentifier = "RegularTableViewCellReuseIdentifier"