import Foundation

struct RewardsViewModel {
    let rewards: [RewardStyle]
    let progress: UserProgress

    func rewards(for type: RewardType) -> [RewardStyle] {
        rewards
            .filter { $0.type == type }
            .sorted {
                if $0.unlockLevel == $1.unlockLevel {
                    return $0.name < $1.name
                }
                return $0.unlockLevel < $1.unlockLevel
            }
    }

    func isSelected(_ reward: RewardStyle) -> Bool {
        switch reward.type {
        case .theme:
            return progress.selectedThemeId == reward.id
        case .xpStyle:
            return progress.selectedXPStyleId == reward.id
        case .sound:
            return progress.selectedSoundId == reward.id
        case .effect:
            return progress.selectedEffectId == reward.id
        }
    }
}
