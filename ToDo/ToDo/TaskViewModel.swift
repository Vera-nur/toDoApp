//
//  TaskViewModel.swift
//  ToDo
//
//  Created by Vera Nur on 3.07.2025.
//

import Foundation
import CoreData
import SwiftUI

class TaskViewModel: ObservableObject {
    private let viewContext: NSManagedObjectContext

    @Published var newTaskTitle: String = ""
    @Published var newTaskDescription: String = ""
    @Published var items: [Item] = []
    @Published var newTaskDate: Date = Calendar.current.date(byAdding: .minute, value: 1, to: Date()) ?? Date()
    @Published var isTimeSet: Bool = false
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchItems()
    }

    func fetchItems() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.task_title, ascending: true)]

        do {
            items = try viewContext.fetch(request)
        } catch {
            print("Fetch error: \(error)")
        }
    }

    func addItem() {
        guard !newTaskTitle.isEmpty else { return }

        let newItem = Item(context: viewContext)
        newItem.task_title = newTaskTitle
        newItem.task_description = newTaskDescription
        newItem.is_completed = false
        newItem.task_id = UUID()
        if isTimeSet {
                newItem.task_date = newTaskDate
            } else {
                let components = Calendar.current.dateComponents([.year, .month, .day], from: newTaskDate)
                newItem.task_date = Calendar.current.date(from: components)
            }

        save()
        scheduleNotification(for: newItem)
        newTaskTitle = ""
        newTaskDate = Date()
        newTaskDescription = ""
    }

    func deleteItem(at offsets: IndexSet) {
        guard !offsets.isEmpty else { return }

        offsets.forEach { index in
            if items.indices.contains(index) {
                let item = items[index]

                if let id = item.task_id?.uuidString {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                }
                viewContext.delete(item)
            }
        }

        save()
    }

    func toggleCompleted(for item: Item) {
        item.is_completed.toggle()
        
        if item.is_completed {
            item.completed_date = Date()
        } else {
            item.completed_date = nil
        }

        save()
    }

    func save() {
        do {
            try viewContext.save()
            fetchItems()
        } catch {
            print("Save error: \(error)")
        }
    }
    
    func requestNotificationPermissionIfNeeded() {
        let hasAsked = UserDefaults.standard.bool(forKey: "hasAskedNotificationPermission")

        if !hasAsked {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if granted {
                    print("Bildirim izni verildi.")
                } else if let error = error {
                    print("Bildirim izni hatası: \(error.localizedDescription)")
                }
            }

            UserDefaults.standard.set(true, forKey: "hasAskedNotificationPermission")
        }
    }
    
    func scheduleNotification(for item: Item) {
        guard let date = item.task_date else { return }

        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = item.task_title ?? "You have a task to complete!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(date.timeIntervalSinceNow, 1), repeats: false)

        let request = UNNotificationRequest(identifier: item.task_id?.uuidString ?? UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification scheduling error: \(error.localizedDescription)")
            }
        }
    }

    
}
