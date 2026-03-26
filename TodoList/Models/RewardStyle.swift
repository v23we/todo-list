import Foundation
import SwiftData

enum RewardType: String, Codable, CaseIterable, Identifiable {
    case theme = "主题"
    case xpStyle = "XP 样式"
    case sound = "音效"
    case effect = "完成动效"

    var id: String { rawValue }
}

@Model
final class RewardStyle {
    @Attribute(.unique) var id: String
    var name: String
    var typeRawValue: String
    var unlockLevel: Int
    var symbolName: String
    var themeKey: String
    var isUnlocked: Bool

    init(
        id: String,
        name: String,
        type: RewardType,
        unlockLevel: Int,
        symbolName: String,
        themeKey: String = "",
        isUnlocked: Bool = false
    ) {
        self.id = id
        self.name = name
        self.typeRawValue = type.rawValue
        self.unlockLevel = unlockLevel
        self.symbolName = symbolName
        self.themeKey = themeKey
        self.isUnlocked = isUnlocked
    }
}

extension RewardStyle {
    var type: RewardType {
        RewardType(rawValue: typeRawValue) ?? .theme
    }
}
