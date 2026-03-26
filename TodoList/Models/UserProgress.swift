import Foundation
import SwiftData

@Model
final class UserProgress {
    @Attribute(.unique) var id: String
    var level: Int
    var currentXP: Int
    var totalXP: Int
    var unlockedRewardIDs: [String]
    var selectedThemeId: String
    var selectedXPStyleId: String
    var selectedSoundId: String
    var selectedEffectId: String

    init(
        id: String = "singleton",
        level: Int = 1,
        currentXP: Int = 0,
        totalXP: Int = 0,
        unlockedRewardIDs: [String] = AppConstants.defaultUnlockedRewardIDs,
        selectedThemeId: String = AppConstants.defaultThemeID,
        selectedXPStyleId: String = AppConstants.defaultXPStyleID,
        selectedSoundId: String = AppConstants.defaultSoundID,
        selectedEffectId: String = AppConstants.defaultEffectID
    ) {
        self.id = id
        self.level = level
        self.currentXP = currentXP
        self.totalXP = totalXP
        self.unlockedRewardIDs = unlockedRewardIDs
        self.selectedThemeId = selectedThemeId
        self.selectedXPStyleId = selectedXPStyleId
        self.selectedSoundId = selectedSoundId
        self.selectedEffectId = selectedEffectId
    }
}
