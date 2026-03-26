import SwiftUI

struct XPStyleIconView: View {
    let styleID: String
    let accent: Color
    let size: CGFloat

    var body: some View {
        Group {
            switch styleID {
            case "xp_drop":
                Image(systemName: "drop.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(accent)
                    .frame(width: size * 0.8, height: size)
            case "xp_bean":
                ZStack {
                    Capsule(style: .continuous)
                        .fill(accent)
                        .frame(width: size * 0.76, height: size * 0.94)
                        .rotationEffect(.degrees(-22))

                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.55), lineWidth: max(size * 0.08, 1))
                        .frame(width: size * 0.24, height: size * 0.72)
                        .rotationEffect(.degrees(18))
                }
            default:
                Image(systemName: "bolt.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(accent)
                    .frame(width: size * 0.72, height: size)
            }
        }
        .frame(width: size, height: size)
    }
}

struct XPBarView: View {
    let progress: UserProgress
    let theme: ThemePalette
    let xpStyleID: String
    let effectStyleID: String
    let animationTrigger: Int
    let latestOutcome: TaskCompletionOutcome?
    let completedTodayCount: Int
    let gainedXPToday: Int
    let nextUnlockText: String

    @State private var showBurst = false
    @State private var particlesVisible = false
    @State private var ringVisible = false

    private var progressRatio: Double {
        min(Double(progress.currentXP) / Double(AppConstants.xpPerLevel), 1.0)
    }

    var body: some View {
        ZStack(alignment: .top) {
            stackedPeekCard(
                title: "下一级奖励",
                value: nextUnlockText,
                offsetY: 30,
                fill: theme.surface.opacity(0.55)
            )

            stackedPeekCard(
                title: "今日获得经验",
                value: "+\(gainedXPToday) XP",
                offsetY: 14,
                fill: theme.surfaceStrong.opacity(0.92)
            )

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("等级 \(progress.level)")
                            .font(.headline)
                            .foregroundStyle(theme.textPrimary)
                        Text("当前经验 \(progress.currentXP)/\(AppConstants.xpPerLevel)")
                            .font(.footnote)
                            .foregroundStyle(theme.textSecondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 8) {
                        XPStyleIconView(styleID: xpStyleID, accent: theme.accent, size: 24)
                        Text("今日完成 \(completedTodayCount) 项")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(theme.textSecondary)
                    }
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(theme.surface)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [theme.accentSoft, theme.accent],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: proxy.size.width * progressRatio)

                        if ringVisible {
                            effectOverlay
                                .offset(x: max(proxy.size.width * progressRatio - 42, 6), y: -26)
                        }

                        if particlesVisible {
                            particleTrail
                                .offset(x: max(proxy.size.width * progressRatio - 78, 6), y: -34)
                                .transition(.opacity.combined(with: .scale))
                        }

                        if showBurst {
                            HStack(spacing: 8) {
                                XPStyleIconView(styleID: xpStyleID, accent: .white, size: 14)
                                Text("+\(latestOutcome?.gainedXP ?? AppConstants.xpPerTask)")
                                    .font(.caption.bold())
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(theme.accent, in: Capsule())
                            .offset(x: max(proxy.size.width * progressRatio - 46, 6), y: -18)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .frame(height: 20)

                HStack(spacing: 12) {
                    infoPill(title: "今日完成", value: "\(completedTodayCount) 项")
                    infoPill(title: "今日经验", value: "+\(gainedXPToday)")
                }

                if let latestOutcome {
                    Text(statusText(for: latestOutcome))
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(latestOutcome.didLevelUp ? theme.accent : theme.textSecondary)
                } else {
                    Text(nextUnlockText)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(theme.textSecondary)
                }
            }
            .padding(20)
            .padding(.bottom, 36)
            .background(theme.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(theme.border, lineWidth: 1)
            )
            .shadow(color: theme.accent.opacity(0.08), radius: 14, y: 8)
        }
        .padding(.bottom, 34)
        .onChange(of: animationTrigger) { _, _ in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                showBurst = true
                particlesVisible = true
                ringVisible = true
            }

            Task {
                try? await Task.sleep(for: .milliseconds(900))
                await MainActor.run {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showBurst = false
                        particlesVisible = false
                    }
                }
            }

            Task {
                try? await Task.sleep(for: .milliseconds(650))
                await MainActor.run {
                    withAnimation(.easeOut(duration: 0.3)) {
                        ringVisible = false
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var effectOverlay: some View {
        if effectStyleID == "effect_ripple" {
            Circle()
                .stroke(theme.accent.opacity(0.35), lineWidth: 2)
                .frame(width: 34, height: 34)
                .scaleEffect(ringVisible ? 1.2 : 0.6)
                .opacity(ringVisible ? 1 : 0)
        } else {
            Circle()
                .fill(theme.accent.opacity(0.18))
                .frame(width: 34, height: 34)
                .blur(radius: 2)
                .overlay(
                    Circle()
                        .fill(theme.accent.opacity(0.1))
                        .frame(width: 48, height: 48)
                )
        }
    }

    private var particleTrail: some View {
        HStack(spacing: 8) {
            XPStyleIconView(styleID: xpStyleID, accent: theme.accent.opacity(0.45), size: 10)
                .offset(y: 8)
            XPStyleIconView(styleID: xpStyleID, accent: theme.accent.opacity(0.7), size: 12)
                .offset(y: -2)
            XPStyleIconView(styleID: xpStyleID, accent: theme.accent, size: 15)
                .offset(y: -10)
        }
    }

    private func infoPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(theme.textSecondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.surfaceStrong, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func stackedPeekCard(title: String, value: String, offsetY: CGFloat, fill: Color) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.textPrimary.opacity(0.85))
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.top, 20)
        .frame(maxWidth: .infinity)
        .frame(height: 110)
        .background(fill, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(theme.border.opacity(0.7), lineWidth: 1)
        )
        .offset(y: offsetY)
    }

    private func statusText(for outcome: TaskCompletionOutcome) -> String {
        if outcome.didLevelUp, !outcome.unlockedRewards.isEmpty {
            return "升级到 Lv.\(outcome.newLevel)，并解锁了 \(outcome.unlockedRewards.joined(separator: "、"))"
        }
        if outcome.didLevelUp {
            return "升级到 Lv.\(outcome.newLevel)"
        }
        return "刚刚获得了 +\(outcome.gainedXP) XP"
    }
}
