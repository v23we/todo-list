import Foundation

struct RewardSeed {
    let id: String
    let name: String
    let type: RewardType
    let unlockLevel: Int
    let symbolName: String
    let themeKey: String
}

enum AppConstants {
    static let appName = "TodoList"
    static let xpPerTask = 20
    static let xpPerLevel = 100

    static let defaultThemeID = "theme_meadow"
    static let defaultXPStyleID = "xp_bolt"
    static let defaultSoundID = "sound_soft"
    static let defaultEffectID = "effect_glow"

    static let defaultUnlockedRewardIDs = [
        defaultThemeID,
        defaultXPStyleID,
        defaultSoundID,
        defaultEffectID
    ]

    static let rewardCatalog: [RewardSeed] = [
        RewardSeed(id: "theme_meadow", name: "暖青草地", type: .theme, unlockLevel: 1, symbolName: "leaf.fill", themeKey: "theme_meadow"),
        RewardSeed(id: "theme_sky", name: "晨雾浅蓝", type: .theme, unlockLevel: 2, symbolName: "cloud.fill", themeKey: "theme_sky"),
        RewardSeed(id: "theme_dawn", name: "清晨暖光", type: .theme, unlockLevel: 3, symbolName: "sun.max.fill", themeKey: "theme_dawn"),
        RewardSeed(id: "xp_bolt", name: "小闪电", type: .xpStyle, unlockLevel: 1, symbolName: "bolt.fill", themeKey: ""),
        RewardSeed(id: "xp_drop", name: "小液滴", type: .xpStyle, unlockLevel: 2, symbolName: "drop.fill", themeKey: ""),
        RewardSeed(id: "xp_bean", name: "小咖啡豆", type: .xpStyle, unlockLevel: 3, symbolName: "capsule.portrait.fill", themeKey: ""),
        RewardSeed(id: "sound_soft", name: "轻提示", type: .sound, unlockLevel: 1, symbolName: "speaker.wave.2.fill", themeKey: ""),
        RewardSeed(id: "sound_bell", name: "清亮铃声", type: .sound, unlockLevel: 4, symbolName: "bell.fill", themeKey: ""),
        RewardSeed(id: "effect_glow", name: "柔光反馈", type: .effect, unlockLevel: 1, symbolName: "circle.hexagongrid.fill", themeKey: ""),
        RewardSeed(id: "effect_ripple", name: "轻波纹", type: .effect, unlockLevel: 5, symbolName: "water.waves", themeKey: "")
    ]
}
