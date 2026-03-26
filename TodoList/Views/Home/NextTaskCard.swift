import SwiftUI

struct NextTaskCard: View {
    let task: TodoTask
    let theme: ThemePalette
    let onOpen: () -> Void
    let onMakeCurrent: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)
                    .lineLimit(2)

                Text("+\(AppConstants.xpPerTask) XP")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(theme.textSecondary)
            }

            Spacer()

            Button("改做这个", action: onMakeCurrent)
                .font(.footnote.bold())
                .foregroundStyle(theme.accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(theme.surfaceStrong, in: Capsule())
        }
        .padding(16)
        .background(theme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(theme.border, lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onTapGesture(perform: onOpen)
    }
}
