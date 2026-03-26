import SwiftUI

struct RewardItemCard: View {
    let reward: RewardStyle
    let isSelected: Bool
    let theme: ThemePalette
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    if reward.type == .xpStyle {
                        XPStyleIconView(
                            styleID: reward.id,
                            accent: reward.isUnlocked ? theme.accent : theme.textSecondary,
                            size: 24
                        )
                    } else {
                        Image(systemName: reward.symbolName)
                            .font(.title2)
                            .foregroundStyle(reward.isUnlocked ? theme.accent : theme.textSecondary)
                    }
                    Spacer()
                    if isSelected {
                        Text("使用中")
                            .font(.caption.bold())
                            .foregroundStyle(theme.accent)
                    } else if !reward.isUnlocked {
                        Text("Lv.\(reward.unlockLevel)")
                            .font(.caption.bold())
                            .foregroundStyle(theme.textSecondary)
                    }
                }

                Text(reward.name)
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)

                Text(reward.isUnlocked ? "已解锁，可切换使用" : "升级到 Lv.\(reward.unlockLevel) 后解锁")
                    .font(.footnote)
                    .foregroundStyle(theme.textSecondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                (isSelected ? theme.surfaceStrong : theme.surface),
                in: RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(isSelected ? theme.accent : theme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(!reward.isUnlocked)
        .opacity(reward.isUnlocked ? 1 : 0.78)
    }
}
