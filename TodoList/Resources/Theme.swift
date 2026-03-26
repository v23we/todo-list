import SwiftUI

struct ThemePalette: Equatable {
    let id: String
    let name: String
    let background: Color
    let surface: Color
    let surfaceStrong: Color
    let accent: Color
    let accentSoft: Color
    let secondaryAccent: Color
    let textPrimary: Color
    let textSecondary: Color
    let border: Color

    static let meadow = ThemePalette(
        id: "theme_meadow",
        name: "暖青草地",
        background: Color(red: 0.97, green: 0.96, blue: 0.92),
        surface: Color(red: 0.99, green: 0.98, blue: 0.95),
        surfaceStrong: Color(red: 0.94, green: 0.97, blue: 0.89),
        accent: Color(red: 0.65, green: 0.73, blue: 0.28),
        accentSoft: Color(red: 0.84, green: 0.90, blue: 0.63),
        secondaryAccent: Color(red: 0.54, green: 0.70, blue: 0.65),
        textPrimary: Color(red: 0.18, green: 0.20, blue: 0.15),
        textSecondary: Color(red: 0.37, green: 0.39, blue: 0.31),
        border: Color(red: 0.87, green: 0.86, blue: 0.78)
    )

    static let sky = ThemePalette(
        id: "theme_sky",
        name: "晨雾浅蓝",
        background: Color(red: 0.95, green: 0.97, blue: 0.99),
        surface: Color(red: 0.99, green: 0.99, blue: 1.00),
        surfaceStrong: Color(red: 0.89, green: 0.94, blue: 0.99),
        accent: Color(red: 0.38, green: 0.61, blue: 0.83),
        accentSoft: Color(red: 0.73, green: 0.86, blue: 0.96),
        secondaryAccent: Color(red: 0.54, green: 0.76, blue: 0.79),
        textPrimary: Color(red: 0.18, green: 0.23, blue: 0.29),
        textSecondary: Color(red: 0.36, green: 0.45, blue: 0.54),
        border: Color(red: 0.82, green: 0.88, blue: 0.93)
    )

    static let dawn = ThemePalette(
        id: "theme_dawn",
        name: "清晨暖光",
        background: Color(red: 0.99, green: 0.95, blue: 0.92),
        surface: Color(red: 1.00, green: 0.98, blue: 0.96),
        surfaceStrong: Color(red: 0.98, green: 0.90, blue: 0.82),
        accent: Color(red: 0.87, green: 0.63, blue: 0.31),
        accentSoft: Color(red: 0.97, green: 0.84, blue: 0.64),
        secondaryAccent: Color(red: 0.84, green: 0.69, blue: 0.54),
        textPrimary: Color(red: 0.28, green: 0.18, blue: 0.14),
        textSecondary: Color(red: 0.49, green: 0.33, blue: 0.28),
        border: Color(red: 0.93, green: 0.83, blue: 0.74)
    )

    static func palette(for id: String) -> ThemePalette {
        switch id {
        case sky.id:
            return .sky
        case dawn.id:
            return .dawn
        default:
            return .meadow
        }
    }
}
