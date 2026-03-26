import Foundation
import SwiftData

@Model
final class AppSettings {
    @Attribute(.unique) var id: String
    var soundEnabled: Bool
    var hapticsEnabled: Bool
    var reduceMotionEnabled: Bool

    init(
        id: String = "singleton",
        soundEnabled: Bool = true,
        hapticsEnabled: Bool = true,
        reduceMotionEnabled: Bool = false
    ) {
        self.id = id
        self.soundEnabled = soundEnabled
        self.hapticsEnabled = hapticsEnabled
        self.reduceMotionEnabled = reduceMotionEnabled
    }
}
