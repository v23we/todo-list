import Foundation

struct TasksViewModel {
    let tasks: [TodoTask]

    var currentTasks: [TodoTask] {
        tasks.filter { !$0.isCompleted && $0.isCurrent && $0.section == .pending }
    }

    var pendingTasks: [TodoTask] {
        tasks.filter { !$0.isCompleted && !$0.isCurrent && $0.section == .pending }
    }

    var laterTasks: [TodoTask] {
        tasks.filter { !$0.isCompleted && $0.section == .later }
    }

    var completedTasks: [TodoTask] {
        tasks.filter(\.isCompleted)
            .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
    }
}
