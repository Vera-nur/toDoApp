//
//  TaskDetailView.swift
//  ToDo
//
//  Created by Vera Nur on 4.07.2025.
//

import SwiftUI

struct TaskDetailView: View {
    @ObservedObject var viewModel: TaskViewModel
    @Binding var task: Item
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Task Title", text: Binding(
                        get: { task.task_title ?? "" },
                        set: { task.task_title = $0 }
                    ))
                }

                Section(header: Text("Description")) {
                    TextField("Task Description", text: Binding(
                        get: { task.task_description ?? "" },
                        set: { task.task_description = $0 }
                    ))
                }

                Section(header: Text("Date")) {
                    DatePicker("Task Date", selection: Binding(
                        get: { task.task_date ?? Date() },
                        set: { task.task_date = $0 }
                    ), displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.rollbackChanges()
                        dismiss()
                    }
                }
            }
        }
    }
}

