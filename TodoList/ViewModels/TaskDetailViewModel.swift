import Foundation

struct TaskDetailViewModel {
    let task: TodoTask

    var progressText: String {
        task.progressText ?? "暂无子任务"
    }

    var displayNextStep: String? {
        task.displayNextStep
    }

    var displayNextStepPlaceholder: String {
        task.displayNextStepPlaceholder
    }

    var shouldShowNextStepField: Bool {
        !task.hasSubtasks
    }

    var nextStepHelperText: String? {
        task.hasSubtasks ? task.subtasksNextStepHint : nil
    }

    var subtaskSummaryText: String {
        guard task.hasSubtasks else { return "暂无子任务" }
        return "已完成 \(task.completedSubtaskCount) / 共 \(task.sortedSubtasks.count) 项"
    }

    var subtaskHintText: String {
        task.subtasksNextStepHint
    }

    var sortedSubtasks: [Subtask] {
        task.sortedSubtasks
    }
}
