//
//  isItUpApp.swift
//  isItUp
//
//  Created by Paul van Woensel on 5/29/22.
//

import SwiftUI

@main
struct isItUpApp: App {
    let persistenceController = PersistenceController.shared
     var body: some Scene {
         MenuBarExtra("Status Check", image: "isUp") {
             ContentView().environment(\.managedObjectContext, persistenceController.container.viewContext)
         }
         .menuBarExtraStyle(.window)
    }
}
