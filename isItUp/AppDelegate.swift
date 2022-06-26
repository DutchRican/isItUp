//
//  AppDelegate.swift
//  isItUp
//
//  Created by Paul van Woensel on 5/29/22.
//

import AppKit
import SwiftUI
import CoreData

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    var statusBarItem: NSStatusItem!
    private var popover: NSPopover!
    
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
        
        let statusBar = NSStatusBar.system
        
        self.statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        if let statusButton = statusBarItem.button {
            statusButton.image = NSImage(named: "isUp")
            statusButton.image?.size = NSSize(width: 20.0, height: 20.0)
            statusButton.image?.isTemplate = true
            statusButton.action = #selector(togglePopover)
            //            statusButton.action = #selector(showIt)
        }
        
        self.popover = NSPopover()
        self.popover.animates = true
        self.popover.contentViewController?.view.window?.makeKey()
        self.popover.contentSize = NSSize(width: 300, height: 400)
        self.popover.contentViewController = NSHostingController(rootView: ContentView().environmentObject(self).environment(\.managedObjectContext, persistentContainer.viewContext))
        
        do {
            let fetchRequest = Endpoint.fetchRequest()
            let endpoints = try persistentContainer.viewContext.fetch(fetchRequest)
            
            let timer = CheckTimer.shared
            Task {
                await timer.setItems(endpoints, moc: persistentContainer.viewContext)
                await timer.startTimer()
            }
        } catch {
            print("Could not fetch: \(error)")
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "isItUpDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //    @objc func showIt() {
    //        isShowing.toggle();
    //    }
    @objc func togglePopover(_ sender: AnyObject) {
        if let button = statusBarItem.button {
            if popover.isShown {
                self.popover.contentViewController?.dismiss(sender)
                self.popover.performClose(sender)
                
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
    
}


//    .onReceive(timer) { time in
//        print("timer called! \(time)")
//    }
