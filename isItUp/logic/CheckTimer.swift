//
//  File.swift
//  isItUp
//
//  Created by Paul van Woensel on 6/24/22.
//

import Foundation
import SwiftUI
import UserNotifications

class DownItems: ObservableObject {
    @Published var hasDownItems = false
}

@MainActor
class CheckTimer {
    static let shared = CheckTimer()
    
    var timer: Timer?
    var moc: NSManagedObjectContext?
    var itemsToCheck: [Endpoint] = []
    
    
    public func setItems(_ items: [Endpoint], moc: NSManagedObjectContext) {
        self.moc = moc
        self.itemsToCheck = items
        if items.isEmpty {
            self.timer?.invalidate()
        } else {
            self.startTimer()
        }
        
    }
    
    public func startTimer() {
        let un = UNUserNotificationCenter.current()
        @ObservedObject var downItems = DownItems()
        var interval = UserDefaults.standard.integer(forKey: "timeout")
        if interval < 30 { interval = 120 }
        self.timer?.invalidate()
        if self.itemsToCheck.isEmpty { return }
        self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true) { _ in
            for item in self.itemsToCheck {
                Task {
                    if let isUp = try? await checkUrl(for: item) {
                        item.isUp = false
                        if isUp {
                            item.lastUp = Date()
                            item.isUp = true
                        } else {
                            downItems.hasDownItems = true
                        }
                    }
                }
            }
            try? self.moc?.save()
            if downItems.hasDownItems {
                Task {
                    try? await un.requestAuthorization(options: [.alert, .sound])
                }
                un.getNotificationSettings { (settings) in
                    if settings.authorizationStatus == .authorized {
                        let content = UNMutableNotificationContent()
                        content.title = "Some Endpoints seem to be down"
                        content.body = "Please check the agent for more details"
                        content.sound = .default
                        
                        let request = UNNotificationRequest(identifier: "IsItUp", content: content , trigger: nil)
                        un.add(request)
                        
                    }
                }
            }
            downItems.hasDownItems = false
        }
    }
}
