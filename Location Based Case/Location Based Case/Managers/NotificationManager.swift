//
//  NotificationManager.swift
//  Location Based Case
//
//  Created by Said Ozsoy on 20.04.2025.
//

import Foundation

protocol NotificationUserInfo {
    init?(notification: NSNotification)
    
    func toDictionary() -> [AnyHashable : Any]
}

class NotificationManager {
    static func post(_ name: Notification.Name, userInfo: NotificationUserInfo? = nil) {
        NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo?.toDictionary())
    }
    
    static func listen(_ observer: Any, selector: Selector, name: Notification.Name) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: nil)
    }
    
    static func removeObserver(_ observer: Any, name: Notification.Name) {
        NotificationCenter.default.removeObserver(observer, name: name, object: nil)
    }
}
