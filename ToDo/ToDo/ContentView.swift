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
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: TaskViewModel(context: context))
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("My Tasks")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Button(action: {
                    showSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                }
                .sheet(isPresented: $showSheet) {
                    AddTaskView(viewModel: viewModel)
                }
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
                let completedCount = viewModel.items.filter { $0.is_completed }.count
                let totalCount = viewModel.items.count
                let progress = totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0.0
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Progress")
                        .font(.headline)
                    ProgressView(value: progress)
                        .tint(.green)
                }
                .padding(.horizontal)
                
                List {
                    ForEach(viewModel.items.filter { !($0.task_title?.isEmpty ?? true) }, id: \.objectID) { item in
                        HStack {
                            Button(action: {
                                viewModel.toggleCompleted(for: item)
                            }) {
                                Image(systemName: item.is_completed ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(item.is_completed ? .green : .gray)
                            }
                            
                            if let title = item.task_title {
                                Text(title)
                                    .strikethrough(item.is_completed, color: .gray)
                                    .foregroundColor(item.is_completed ? .gray : .primary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .onDelete(perform: viewModel.deleteItem)
                }
                .listStyle(.plain)
            }
        }
        .onAppear {
            viewModel.requestNotificationPermissionIfNeeded()
        }
        .padding(.top)
        .background(Color(.systemGroupedBackground))
    }
}


#Preview {
    ContentView(context: PersistenceController.preview.container.viewContext)
}
