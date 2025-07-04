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
    @State private var showPastDateAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add New Task")
                    .font(.title2)
                    .fontWeight(.semibold)

                TextField("Enter task title...", text: $viewModel.newTaskTitle)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)

                TextField("Enter task description ", text: $viewModel.newTaskDescription)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)

                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    
                    DatePicker("", selection: $viewModel.newTaskDate, displayedComponents: .date)
                        .labelsHidden()
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)

                Toggle("Set Time", isOn: $viewModel.isTimeSet)
                    .padding(.horizontal)

                if viewModel.isTimeSet {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                        
                        DatePicker("", selection: $viewModel.newTaskDate, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }

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
                        let now = Date()
                        
                        if viewModel.isTimeSet {
                            if viewModel.newTaskDate <= now {
                                showPastDateAlert = true
                                return
                            }
                        } else {
                            let selectedDate = Calendar.current.startOfDay(for: viewModel.newTaskDate)
                            let today = Calendar.current.startOfDay(for: now)

                            if selectedDate < today {
                                showPastDateAlert = true
                                return
                            }
                        }

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
            .alert(isPresented: $showPastDateAlert) {
                Alert(
                    title: Text("Invalid Date"),
                    message: Text("Please select a future date and time for the task."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AddTaskView(viewModel: TaskViewModel(context: PersistenceController.preview.container.viewContext))
}
