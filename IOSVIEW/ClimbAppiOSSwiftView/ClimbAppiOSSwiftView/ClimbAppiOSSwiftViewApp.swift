//
//  ClimbAppiOSSwiftViewApp.swift
//  ClimbAppiOSSwiftView
//
//  Created by Vincent Duong on 1/20/24.
//

import SwiftUI

@main
struct ClimbAppiOSSwiftViewApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ImageUploadView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
