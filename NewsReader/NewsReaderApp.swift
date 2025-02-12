//
//  NewsReaderApp.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

import SwiftUI

@main
struct NewsReaderApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
