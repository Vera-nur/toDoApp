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
        .background(Color(.systemGroupedBackground))
    }
}


#Preview {
    ContentView(context: PersistenceController.preview.container.viewContext)
}
