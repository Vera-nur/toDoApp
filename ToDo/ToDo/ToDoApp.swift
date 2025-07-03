//
//  ToDoApp.swift
//  ToDo
//
//  Created by Vera Nur on 3.07.2025.
//

import SwiftUI

@main
struct ToDoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(context: persistenceController.container.viewContext)
        }
    }
}
