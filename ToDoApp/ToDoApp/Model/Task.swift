//
//  Task.swift
//  ToDoApp
//
//  Created by Vera Nur on 3.07.2025.
//

import Foundation

struct Task: Identifiable {
    var id = UUID()
    var title: String
    var isCompleted: Bool
}
