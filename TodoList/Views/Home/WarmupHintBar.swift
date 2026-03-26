import SwiftUI

struct WarmupHintBar: View {
    let theme: ThemePalette
    let hasCurrentTask: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "timer")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(theme.accent)
            
            if hasCurrentTask {
                Text("预计 5 分钟 · 轻量任务 · +\(AppConstants.xpPerTask)经验")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(theme.textSecondary)
            } else {
                Text("从一个 5 分钟小任务开始")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(theme.textSecondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(theme.accent.opacity(0.08)) // A very light tint of the accent to act as a transition tape
        )
    }
}