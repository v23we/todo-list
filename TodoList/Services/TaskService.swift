import Foundation
import SwiftData

struct TaskDraft {
    var title: String
    var note: String
    var nextStep: String
    var section: TaskSection
    var shouldSetCurrent: Bool
    var subtasks: [String]
}

enum TaskService {
    @MainActor
    static func fetchTasks(context: ModelContext) throws -> [TodoTask] {
        let descriptor = FetchDescriptor<TodoTask>(sortBy: [
            SortDescriptor(\TodoTask.sortOrder),
            SortDescriptor(\TodoTask.createdAt)
        ])
        return try context.fetch(descriptor)
    }

    static func orderedPendingTasks(from tasks: [TodoTask], excluding excludedIDs: Set<UUID> = []) -> [TodoTask] {
        tasks
            .filter { !$0.isCompleted && !$0.isCurrent && $0.section == .pending && !excludedIDs.contains($0.id) }
            .sorted {
                if $0.sortOrder == $1.sortOrder {
                    return $0.createdAt < $1.createdAt
                }
                return $0.sortOrder < $1.sortOrder
            }
    }

    static func orderedCurrentCandidates(from tasks: [TodoTask], excluding excludedIDs: Set<UUID> = []) -> [TodoTask] {
        tasks
            .filter { !$0.isCompleted && $0.section == .pending && !excludedIDs.contains($0.id) }
            .sorted {
                if $0.sortOrder == $1.sortOrder {
                    return $0.createdAt < $1.createdAt
                }
                return $0.sortOrder < $1.sortOrder
            }
    }

    @MainActor
    static func normalizeCurrentTask(context: ModelContext) throws {
        let tasks = try fetchTasks(context: context)
        var activeCurrent = orderedCurrentCandidates(from: tasks).filter(\.isCurrent)

        for task in tasks where task.isCurrent && (task.isCompleted || task.section != .pending) {
            task.isCurrent = false
        }

        activeCurrent = orderedCurrentCandidates(from: tasks).filter(\.isCurrent)
        if activeCurrent.count > 1 {
            let keep = activeCurrent.removeFirst()
            for task in activeCurrent where task.id != keep.id {
                task.isCurrent = false
            }
        }

        if orderedCurrentCandidates(from: tasks).allSatisfy({ !$0.isCurrent }),
           let next = orderedCurrentCandidates(from: tasks).first {
            next.isCurrent = true
        }

        if context.hasChanges {
            try context.save()
        }
    }

    @MainActor
    static func createTask(from draft: TaskDraft, context: ModelContext) throws -> TodoTask {
        let trimmedTitle = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw NSError(domain: AppConstants.appName, code: 1, userInfo: [NSLocalizedDescriptionKey: "任务标题不能为空"])
        }

        let task = TodoTask(
            title: trimmedTitle,
            note: draft.note,
            manualNextStep: draft.nextStep,
            section: draft.section,
            sortOrder: Date.now.timeIntervalSince1970
        )

        context.insert(task)

        for (index, title) in draft.subtasks
            .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            .filter({ !$0.isEmpty })
            .enumerated() {
            let subtask = Subtask(title: title, orderIndex: index, parentTask: task)
            task.subtasks.append(subtask)
            context.insert(subtask)
        }

        if draft.shouldSetCurrent && draft.section == .pending {
            try setCurrentTask(task, context: context)
        } else {
            try normalizeCurrentTask(context: context)
        }

        if context.hasChanges {
            try context.save()
        }

        return task
    }

    @MainActor
    static func setCurrentTask(_ task: TodoTask, context: ModelContext) throws {
        let tasks = try fetchTasks(context: context)
        for item in tasks where item.isCurrent && item.id != task.id {
            item.isCurrent = false
        }

        task.section = .pending
        task.isCurrent = true

        if context.hasChanges {
            try context.save()
        }
    }

    @MainActor
    static func clearCurrentTask(_ task: TodoTask, context: ModelContext) throws {
        task.isCurrent = false
        task.section = .pending

        let tasks = try fetchTasks(context: context)
        let nextCurrent = orderedCurrentCandidates(from: tasks, excluding: [task.id]).first
        nextCurrent?.isCurrent = true

        if context.hasChanges {
            try context.save()
        }
    }

    @MainActor
    static func moveTask(_ task: TodoTask, to section: TaskSection, context: ModelContext) throws {
        task.section = section
        if section != .pending {
            task.isCurrent = false
        }
        if section == .completed {
            task.isCompleted = true
            task.completedAt = task.completedAt ?? .now
        } else if task.isCompleted {
            task.isCompleted = false
            task.completedAt = nil
        }

        try normalizeCurrentTask(context: context)
        if context.hasChanges {
            try context.save()
        }
    }

    @MainActor
    static func performPrimaryAction(for task: TodoTask, context: ModelContext) throws -> TaskCompletionOutcome? {
        if task.hasSubtasks {
            return try completeNextSubtask(in: task, context: context)
        }
        return try completeTask(task, context: context)
    }

    @MainActor
    static func setSubtask(
        _ subtask: Subtask,
        isCompleted: Bool,
        in task: TodoTask,
        context: ModelContext
    ) throws -> TaskCompletionOutcome? {
        guard task.subtasks.contains(where: { $0.id == subtask.id }) else { return nil }
        guard task.isCompleted == false else { return nil }

        if subtask.isCompleted == isCompleted {
            return nil
        }

        subtask.isCompleted = isCompleted

        if isCompleted, task.allSubtasksCompleted {
            return try finalizeTaskCompletion(task, context: context)
        }

        if context.hasChanges {
            try context.save()
        }

        return nil
    }

    @MainActor
    static func completeNextSubtask(in task: TodoTask, context: ModelContext) throws -> TaskCompletionOutcome? {
        guard let nextSubtask = task.nextIncompleteSubtask else {
            if task.allSubtasksCompleted {
                return try finalizeTaskCompletion(task, context: context)
            }
            return nil
        }

        nextSubtask.isCompleted = true

        if task.allSubtasksCompleted {
            return try finalizeTaskCompletion(task, context: context)
        }

        if context.hasChanges {
            try context.save()
        }

        return nil
    }

    @MainActor
    static func completeTask(_ task: TodoTask, context: ModelContext) throws -> TaskCompletionOutcome {
        if task.hasSubtasks && !task.allSubtasksCompleted {
            throw NSError(
                domain: AppConstants.appName,
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "有子任务时，需先完成全部子任务，父任务才会完成"]
            )
        }

        return try finalizeTaskCompletion(task, context: context)
    }

    @MainActor
    private static func finalizeTaskCompletion(_ task: TodoTask, context: ModelContext) throws -> TaskCompletionOutcome {
        let wasCurrent = task.isCurrent

        task.isCompleted = true
        task.isCurrent = false
        task.section = .completed
        task.completedAt = .now

        let progress = try ProgressService.fetchProgress(context: context)
        let rewards = try RewardService.fetchRewards(context: context)
        let outcome = ProgressService.applyTaskCompletion(progress: progress, rewards: rewards)

        if wasCurrent {
            let tasks = try fetchTasks(context: context)
            if let nextCurrent = orderedCurrentCandidates(from: tasks).first {
                nextCurrent.isCurrent = true
            }
        } else {
            try normalizeCurrentTask(context: context)
        }

        if context.hasChanges {
            try context.save()
        }

        return outcome
    }
}
