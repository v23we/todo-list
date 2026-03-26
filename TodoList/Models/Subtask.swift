import Foundation
import SwiftData

@Model
final class Subtask {
    @Attribute(.unique) var id: UUID
    var title: String
    var isCompleted: Bool
    var orderIndex: Int
    var createdAt: Date
    var parentTask: TodoTask?

    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        orderIndex: Int,
        createdAt: Date = .now,
        parentTask: TodoTask? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.orderIndex = orderIndex
        self.createdAt = createdAt
        self.parentTask = parentTask
    }
}
