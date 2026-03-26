import Foundation
import SwiftData

enum TaskSection: String, Codable, CaseIterable, Identifiable {
    case pending = "待处理"
    case later = "稍后"
    case completed = "已完成"

    var id: String { rawValue }
}

@Model
final class TodoTask {
    @Attribute(.unique) var id: UUID
    var title: String
    var note: String
    var manualNextStep: String
    var isCompleted: Bool
    var isCurrent: Bool
    var sectionRawValue: String
    var createdAt: Date
    var completedAt: Date?
    var sortOrder: Double

    @Relationship(deleteRule: .cascade, inverse: \Subtask.parentTask)
    var subtasks: [Subtask]

    init(
        id: UUID = UUID(),
        title: String,
        note: String = "",
        manualNextStep: String = "",
        isCompleted: Bool = false,
        isCurrent: Bool = false,
        section: TaskSection = .pending,
        createdAt: Date = .now,
        completedAt: Date? = nil,
        sortOrder: Double = Date.now.timeIntervalSince1970,
        subtasks: [Subtask] = []
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.manualNextStep = manualNextStep
        self.isCompleted = isCompleted
        self.isCurrent = isCurrent
        self.sectionRawValue = section.rawValue
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.sortOrder = sortOrder
        self.subtasks = subtasks
    }
}

extension TodoTask {
    var hasSubtasks: Bool {
        !sortedSubtasks.isEmpty
    }

    var trimmedManualNextStep: String {
        manualNextStep.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var nextIncompleteSubtask: Subtask? {
        sortedSubtasks.first(where: { !$0.isCompleted })
    }

    var displayNextStep: String? {
        if let nextIncompleteSubtask {
            let title = nextIncompleteSubtask.title.trimmingCharacters(in: .whitespacesAndNewlines)
            return title.isEmpty ? nil : title
        }

        return trimmedManualNextStep.isEmpty ? nil : trimmedManualNextStep
    }

    var displayNextStepPlaceholder: String {
        "从这一步开始"
    }

    var allSubtasksCompleted: Bool {
        hasSubtasks && completedSubtaskCount == sortedSubtasks.count
    }

    var section: TaskSection {
        get { TaskSection(rawValue: sectionRawValue) ?? .pending }
        set { sectionRawValue = newValue.rawValue }
    }

    var sortedSubtasks: [Subtask] {
        subtasks.sorted {
            if $0.orderIndex == $1.orderIndex {
                return $0.createdAt < $1.createdAt
            }
            return $0.orderIndex < $1.orderIndex
        }
    }

    var completedSubtaskCount: Int {
        sortedSubtasks.filter(\.isCompleted).count
    }

    var progressText: String? {
        guard hasSubtasks else { return nil }
        return "\(completedSubtaskCount)/\(subtasks.count)"
    }

    var nextStepText: String {
        displayNextStep ?? displayNextStepPlaceholder
    }

    var primaryActionTitle: String {
        hasSubtasks ? "完成下一步" : "做完了"
    }

    var primaryActionDetailTitle: String {
        hasSubtasks ? "完成这一步" : "完成这个任务"
    }
}
