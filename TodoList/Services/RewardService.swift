import Foundation
import SwiftData

enum RewardService {
    @MainActor
    static func fetchRewards(context: ModelContext) throws -> [RewardStyle] {
        let descriptor = FetchDescriptor<RewardStyle>(sortBy: [
            SortDescriptor(\RewardStyle.unlockLevel),
            SortDescriptor(\RewardStyle.name)
        ])
        return try context.fetch(descriptor)
    }

    @MainActor
    static func bootstrapRewards(context: ModelContext, progress: UserProgress) throws {
        if progress.selectedXPStyleId == "xp_spark" {
            progress.selectedXPStyleId = "xp_bean"
        }

        var existingRewards = try fetchRewards(context: context)

        if let legacyCoffeeStyle = existingRewards.first(where: { $0.id == "xp_spark" }),
           existingRewards.contains(where: { $0.id == "xp_bean" }) == false {
            legacyCoffeeStyle.id = "xp_bean"
            legacyCoffeeStyle.name = "小咖啡豆"
            legacyCoffeeStyle.symbolName = "capsule.portrait.fill"
        }

        let existingIDs = Set(existingRewards.map(\.id))
        for seed in AppConstants.rewardCatalog where !existingIDs.contains(seed.id) {
            let reward = RewardStyle(
                id: seed.id,
                name: seed.name,
                type: seed.type,
                unlockLevel: seed.unlockLevel,
                symbolName: seed.symbolName,
                themeKey: seed.themeKey,
                isUnlocked: seed.unlockLevel <= progress.level
            )
            context.insert(reward)
        }

        if context.hasChanges || existingRewards.isEmpty {
            existingRewards = try fetchRewards(context: context)
        }

        let unlockedNames = unlockRewards(for: progress.level, rewards: existingRewards)
        if !unlockedNames.isEmpty {
            progress.unlockedRewardIDs = Array(Set(progress.unlockedRewardIDs).union(existingRewards.filter(\.isUnlocked).map(\.id))).sorted()
        }
        ensureSelectedRewards(progress: progress, rewards: existingRewards)
    }

    @discardableResult
    static func unlockRewards(for level: Int, rewards: [RewardStyle]) -> [String] {
        var unlockedNames: [String] = []

        for reward in rewards where reward.unlockLevel <= level && !reward.isUnlocked {
            reward.isUnlocked = true
            unlockedNames.append(reward.name)
        }

        return unlockedNames
    }

    static func ensureSelectedRewards(progress: UserProgress, rewards: [RewardStyle]) {
        let unlockedIDs = Set(rewards.filter(\.isUnlocked).map(\.id))
        progress.unlockedRewardIDs = Array(unlockedIDs).sorted()

        if !unlockedIDs.contains(progress.selectedThemeId) {
            progress.selectedThemeId = AppConstants.defaultThemeID
        }
        if !unlockedIDs.contains(progress.selectedXPStyleId) {
            progress.selectedXPStyleId = AppConstants.defaultXPStyleID
        }
        if !unlockedIDs.contains(progress.selectedSoundId) {
            progress.selectedSoundId = AppConstants.defaultSoundID
        }
        if !unlockedIDs.contains(progress.selectedEffectId) {
            progress.selectedEffectId = AppConstants.defaultEffectID
        }
    }

    static func applySelection(reward: RewardStyle, to progress: UserProgress) {
        guard reward.isUnlocked else { return }

        switch reward.type {
        case .theme:
            progress.selectedThemeId = reward.id
        case .xpStyle:
            progress.selectedXPStyleId = reward.id
        case .sound:
            progress.selectedSoundId = reward.id
        case .effect:
            progress.selectedEffectId = reward.id
        }
    }

    static func selectedReward(for type: RewardType, progress: UserProgress, rewards: [RewardStyle]) -> RewardStyle? {
        let selectedID: String
        switch type {
        case .theme:
            selectedID = progress.selectedThemeId
        case .xpStyle:
            selectedID = progress.selectedXPStyleId
        case .sound:
            selectedID = progress.selectedSoundId
        case .effect:
            selectedID = progress.selectedEffectId
        }

        return rewards.first(where: { $0.id == selectedID })
    }
}
