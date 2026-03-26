import Foundation

struct HomeViewModel {
    let tasks: [TodoTask]
    let progress: UserProgress
    let rewards: [RewardStyle]

    var currentTask: TodoTask? {
        tasks.first(where: { !$0.isCompleted && $0.isCurrent && $0.section == .pending })
    }

    var alternativeTasks: [TodoTask] {
        TaskService.orderedPendingTasks(from: tasks, excluding: currentTask.map { [$0.id] } ?? [])
            .prefix(2)
            .map { $0 }
    }

    var isEmpty: Bool {
        currentTask == nil && alternativeTasks.isEmpty
    }

    var currentXPText: String {
        "\(progress.currentXP)/\(AppConstants.xpPerLevel)"
    }

    var levelText: String {
        "Lv.\(progress.level)"
    }

    var xpStyleID: String {
        RewardService.selectedReward(for: .xpStyle, progress: progress, rewards: rewards)?.id ?? AppConstants.defaultXPStyleID
    }

    var effectStyleID: String {
        RewardService.selectedReward(for: .effect, progress: progress, rewards: rewards)?.id ?? AppConstants.defaultEffectID
    }

    var completedTodayCount: Int {
        let calendar = Calendar.current
        return tasks.filter { task in
            guard task.isCompleted, let completedAt = task.completedAt else { return false }
            return calendar.isDateInToday(completedAt)
        }.count
    }

    var gainedXPToday: Int {
        completedTodayCount * AppConstants.xpPerTask
    }

    var nextUnlockText: String {
        guard let nextReward = rewards
            .filter({ $0.unlockLevel > progress.level })
            .sorted(by: {
                if $0.unlockLevel == $1.unlockLevel {
                    return $0.name < $1.name
                }
                return $0.unlockLevel < $1.unlockLevel
            })
            .first
        else {
            return "当前奖励已全部解锁"
        }

        return "Lv.\(nextReward.unlockLevel) 解锁 \(nextReward.name)"
    }

    var emptyStateTitle: String {
        "先做这一个"
    }

    var emptyStateDescription: String {
        "新建一个小任务，把注意力放回当前这一步。"
    }
}
