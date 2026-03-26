import Foundation

struct TaskDetailViewModel {
    let task: TodoTask

    var progressText: String {
        task.progressText ?? "暂无子任务"
    }

    var nextStepText: String {
        task.nextStepText
    }

    var nextStepFieldTitle: String {
        task.hasSubtasks ? "下一步（已由子任务自动生成）" : "下一步（可选）"
    }

    var nextStepHelperText: String? {
        task.hasSubtasks ? "当前首页展示的“下一步”会自动取第一个未完成子任务。" : nil
    }

    var subtaskSummaryText: String {
        guard task.hasSubtasks else { return "暂无子任务" }
        return "已完成 \(task.completedSubtaskCount) / 共 \(task.sortedSubtasks.count) 项"
    }

    var sortedSubtasks: [Subtask] {
        task.sortedSubtasks
    }
}
