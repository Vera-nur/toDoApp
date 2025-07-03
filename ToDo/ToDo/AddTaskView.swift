//
//  AddTaskView.swift
//  ToDo
//
//  Created by Vera Nur on 3.07.2025.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TaskViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add New Task")
                    .font(.title)
                    .fontWeight(.semibold)

                TextField("Enter task title...", text: $viewModel.newTaskTitle)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)

                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }

                    Button(action: {
                        viewModel.addItem()
                        dismiss()
                    }) {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray.opacity(0.4) : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(viewModel.newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AddTaskView(viewModel: TaskViewModel(context: PersistenceController.preview.container.viewContext))
}
