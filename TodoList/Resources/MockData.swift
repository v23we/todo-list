import Foundation

enum MockData {
    static func sampleTask(title: String, current: Bool = false) -> TodoTask {
        let task = TodoTask(
            title: title,
            note: "把任务拆成最小一步，先推进一点点。",
            manualNextStep: "打开资料并看 5 分钟",
            isCurrent: current,
            section: .pending
        )
        task.subtasks = [
            Subtask(title: "打开资料", orderIndex: 0, parentTask: task),
            Subtask(title: "划出第一段重点", orderIndex: 1, parentTask: task)
        ]
        return task
    }
}
