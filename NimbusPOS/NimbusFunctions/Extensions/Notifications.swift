//
//  Notifications.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-06-09.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let onResultsFromDocumentIdListCall = Notification.Name("on-Results-From-Document-Id-List-Call")
    static let onBatchSaveToCoreDataCompleted = Notification.Name("on-Batch-Save-To-Core-Data-Completed")
    static let onResultsFromLoginAttempt = Notification.Name("on-Results-From-Login-Attempt")
    static let onAppAuthenticationAttempt = Notification.Name("on-App-Authentication-Attemp")
}

struct notificationDocumentListSyncObject {
    let totalDocuments: Int
    let currentDocumentProgress: Int
    let collectionName: String
    let syncComplete: Bool
    let message: String
}

struct notificationBatchSaveToCoreDataCompleted {
    let entityName: String
    let syncComplete: Bool
    let message: String
}

struct notificationLoginAttempt {
    let loginSuccessful: Bool
    let message: String
}

struct notificationAppAuthenticationAttempt {
    let appAuthenticationSuccessful: Bool
    let message: String
}


