//
//  ContentView.swift
//  ToDo
//
//  Created by Vera Nur on 3.07.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: TaskViewModel
    @State private var showSheet = false
    @State private var selectedTask: Item? = nil
    @State private var showDetailView = false
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: TaskViewModel(context: context))
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                HStack {
                    Text("My Tasks")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                }
                .padding()
                
                if viewModel.items.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                        Text("No tasks yet!")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    let calendar = Calendar.current
                    let today = calendar.startOfDay(for: Date())

                    let activeTodayTasks = viewModel.items.filter {
                        !$0.is_completed &&
                        ($0.task_date != nil && calendar.isDate($0.task_date!, inSameDayAs: today))
                    }

                    let activeFutureTasks = viewModel.items.filter {
                        !$0.is_completed &&
                        ($0.task_date != nil && $0.task_date! > today && !calendar.isDate($0.task_date!, inSameDayAs: today))
                    }

                    let completedTasks = viewModel.items.filter {
                        $0.is_completed && ($0.completed_date != nil && calendar.isDate($0.completed_date!, inSameDayAs: today))
                    }
                    
                    let completedTodayCount = completedTasks.count
                    let totalTodayCount = activeTodayTasks.count + completedTodayCount
                    let progress = totalTodayCount > 0 ? Double(completedTodayCount) / Double(totalTodayCount) : 0.0

                    List {
                        Section {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Today's Progress")
                                    .font(.headline)
                                ProgressView(value: progress)
                                    .tint(.green)
                            }
                            .padding(.vertical, 5)
                        }
                        
                        Section(header: Text("Today")) {
                            ForEach(activeTodayTasks, id: \.objectID) { item in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Button(action: {
                                            viewModel.toggleCompleted(for: item)
                                        }) {
                                            Image(systemName: item.is_completed ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 20))
                                                .foregroundColor(item.is_completed ? .green : .gray)
                                        }

                                        if let title = item.task_title, let taskDate = item.task_date {
                                            let now = Date()
                                            let calendar = Calendar.current
                                            let taskComponents = calendar.dateComponents([.hour, .minute], from: taskDate)
                                            let isToday = calendar.isDate(taskDate, inSameDayAs: now)
                                            let isTimeSet = (taskComponents.hour ?? 0) != 0 || (taskComponents.minute ?? 0) != 0
                                            let isPast = taskDate < now
                                            
                                            let textColor: Color = item.is_completed ? .gray : (isTimeSet && isToday && isPast ? .red : .primary)

                                            Text(title)
                                                .strikethrough(item.is_completed, color: .gray)
                                                .foregroundColor(textColor)
                                                .font(.body)
                                        }

                                        Spacer()
                                    }

                                    if let date = item.task_date {
                                        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                                        
                                        let formattedDate: String? = {
                                            let formatter = DateFormatter()
                                            if Calendar.current.isDateInToday(date) {
                                                if let hour = components.hour, let minute = components.minute, (hour != 0 || minute != 0) {
                                                    formatter.dateFormat = "HH:mm"
                                                    return formatter.string(from: date)
                                                } else {
                                                    return nil
                                                }
                                            } else {
                                                formatter.dateFormat = "MM/dd"
                                                return formatter.string(from: date)
                                            }
                                        }()
                                        
                                        if let formattedDate = formattedDate {
                                            Text(formattedDate)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .padding(.leading, 30)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                                .onTapGesture {
                                        selectedTask = item
                                        showDetailView = true
                                    }
                            }
                            .onDelete(perform: viewModel.deleteItem)
                        }

                        if !activeFutureTasks.isEmpty {
                            Section(header: Text("Upcoming")) {
                                ForEach(activeFutureTasks, id: \.objectID) { item in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Button(action: {
                                                viewModel.toggleCompleted(for: item)
                                            }) {
                                                Image(systemName: "circle")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(.gray)
                                            }

                                            if let title = item.task_title {
                                                Text(title)
                                                    .foregroundColor(.primary)
                                                    .font(.body)
                                            }

                                            Spacer()
                                        }

                                        if let date = item.task_date {
                                            let formattedDate: String = {
                                                let formatter = DateFormatter()
                                                formatter.dateFormat = "MM/dd"
                                                return formatter.string(from: date)
                                            }()
                                            
                                            Text(formattedDate)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .padding(.leading, 30)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                    .onTapGesture {
                                        selectedTask = item
                                        showDetailView = true
                                    }
                                }
                                .onDelete(perform: viewModel.deleteItem)
                            }
                        }

                        if !completedTasks.isEmpty {
                            Section(header: Text("Completed Today")) {
                                ForEach(completedTasks, id: \.objectID) { item in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Button(action: {
                                                viewModel.toggleCompleted(for: item)
                                            }) {
                                                Image(systemName: item.is_completed ? "checkmark.circle.fill" : "circle")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(.green)
                                            }

                                            if let title = item.task_title {
                                                Text(title)
                                                    .strikethrough(true, color: .gray)
                                                    .foregroundColor(.gray)
                                                    .font(.body)
                                            }

                                            Spacer()
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                                .onDelete(perform: viewModel.deleteItem)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .onAppear {
                viewModel.requestNotificationPermissionIfNeeded()
            }
            .padding(.top)
            .background(Color(.systemGray6))
            
            Button(action: {
                showSheet = true
            }) {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.system(size: 24))
                    .padding()
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding()
            .sheet(isPresented: $showSheet) {
                AddTaskView(viewModel: viewModel)
                    .presentationDetents([.medium,.large])
                    .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $showDetailView) {
            if let selectedTask = selectedTask {
                TaskDetailView(
                    viewModel: viewModel,
                    task: Binding(get: {
                        selectedTask
                    }, set: { updated in
                        self.selectedTask = updated
                    })
                )
            }
        }
    }
}


#Preview {
    ContentView(context: PersistenceController.preview.container.viewContext)
}
