import Foundation
import SwiftData

struct TaskCompletionOutcome: Equatable {
    let gainedXP: Int
    let didLevelUp: Bool
    let newLevel: Int
    let unlockedRewards: [String]
}

enum ProgressService {
    @MainActor
    static func fetchProgress(context: ModelContext) throws -> UserProgress {
        let descriptor = FetchDescriptor<UserProgress>()
        if let progress = try context.fetch(descriptor).first {
            return progress
        }

        let progress = UserProgress()
        context.insert(progress)
        return progress
    }

    static func applyTaskCompletion(progress: UserProgress, rewards: [RewardStyle]) -> TaskCompletionOutcome {
        progress.totalXP += AppConstants.xpPerTask
        progress.currentXP += AppConstants.xpPerTask

        var didLevelUp = false
        while progress.currentXP >= AppConstants.xpPerLevel {
            progress.currentXP -= AppConstants.xpPerLevel
            progress.level += 1
            didLevelUp = true
        }

        let unlockedRewards = RewardService.unlockRewards(for: progress.level, rewards: rewards)
        RewardService.ensureSelectedRewards(progress: progress, rewards: rewards)

        return TaskCompletionOutcome(
            gainedXP: AppConstants.xpPerTask,
            didLevelUp: didLevelUp,
            newLevel: progress.level,
            unlockedRewards: unlockedRewards
        )
    }
}
