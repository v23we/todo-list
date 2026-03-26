import SwiftUI

struct CurrentTaskCard: View {
    let task: TodoTask
    let theme: ThemePalette
    let onOpen: () -> Void
    let onComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(task.title)
                        .font(.title3.bold())
                        .foregroundStyle(theme.textPrimary)

                    Text("下一步：\(task.nextStepText)")
                        .font(.body)
                        .foregroundStyle(theme.textSecondary)
                        .lineLimit(2)

                    if let progressText = task.progressText {
                        Label(progressText, systemImage: "list.bullet.rectangle.portrait")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(theme.secondaryAccent)
                    }
                }

                Spacer()

                Text("+\(AppConstants.xpPerTask) XP")
                    .font(.footnote.bold())
                    .foregroundStyle(theme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(theme.surface, in: Capsule())
            }

            HStack(spacing: 12) {
                Button(action: onOpen) {
                    Text("查看详情")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(theme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                Button(action: onComplete) {
                    Label(task.primaryActionTitle, systemImage: "checkmark.circle.fill")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(theme.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [theme.surfaceStrong, theme.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(theme.border, lineWidth: 1)
        )
        .shadow(color: theme.accent.opacity(0.12), radius: 12, y: 6)
    }
}
