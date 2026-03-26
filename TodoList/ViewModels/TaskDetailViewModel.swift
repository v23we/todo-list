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
        task.hasSubtasks ? "已添加子任务，下一步将自动取第一个未完成子任务。" : nil
    }

    var subtaskSummaryText: String {
        guard task.hasSubtasks else { return "暂无子任务" }
        return "已完成 \(task.completedSubtaskCount) / 共 \(task.sortedSubtasks.count) 项"
    }

    var sortedSubtasks: [Subtask] {
        task.sortedSubtasks
    }
}
