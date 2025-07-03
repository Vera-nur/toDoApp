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
    @Published var items: [Item] = []

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
        newItem.is_completed = false
        newItem.task_id = UUID()

        save()
        newTaskTitle = ""
    }

    func deleteItem(at offsets: IndexSet) {
        guard !offsets.isEmpty else { return }

        offsets.forEach { index in
            if items.indices.contains(index) {
                viewContext.delete(items[index])
            }
        }

        save()
    }

    func toggleCompleted(for item: Item) {
        item.is_completed.toggle()
        save()
    }

    private func save() {
        do {
            try viewContext.save()
            fetchItems()
        } catch {
            print("Save error: \(error)")
        }
    }
}
