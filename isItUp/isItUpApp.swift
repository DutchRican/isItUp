//
//  isItUpApp.swift
//  isItUp
//
//  Created by Paul van Woensel on 5/29/22.
//

import SwiftUI

@main
struct isItUpApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.managedObjectContext) private var moc
     var body: some Scene {
        // Not sure if this is the best way, height 0 but we can still copy&paste and all the good stuff
        Settings { EmptyView().frame(height: nil)}
            .commands {
            TextEditingCommands()
            }
    }
}
