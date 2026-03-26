import SwiftUI
import SwiftData

struct RewardsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var progressList: [UserProgress]
    @Query(sort: [SortDescriptor(\RewardStyle.unlockLevel), SortDescriptor(\RewardStyle.name)]) private var rewards: [RewardStyle]

    let theme: ThemePalette

    private var progress: UserProgress? { progressList.first }

    private var viewModel: RewardsViewModel? {
        guard let progress else { return nil }
        return RewardsViewModel(rewards: rewards, progress: progress)
    }

    var body: some View {
        ScrollView {
            if let progress, let viewModel {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Lv.\(progress.level)")
                            .font(.largeTitle.bold())
                            .foregroundStyle(theme.textPrimary)
                        Text("成长不会丢失，奖励会一直留下来。")
                            .font(.body)
                            .foregroundStyle(theme.textSecondary)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(theme.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(theme.border, lineWidth: 1)
                    )

                    rewardSection(title: "主题", type: .theme, viewModel: viewModel, progress: progress)
                    rewardSection(title: "XP 样式", type: .xpStyle, viewModel: viewModel, progress: progress)
                    rewardSection(title: "音效", type: .sound, viewModel: viewModel, progress: progress)
                    rewardSection(title: "完成动效", type: .effect, viewModel: viewModel, progress: progress)
                }
                .padding(20)
            } else {
                ProgressView("正在加载奖励…")
                    .tint(theme.accent)
            }
        }
        .background(theme.background)
        .navigationTitle("奖励")
    }

    @ViewBuilder
    private func rewardSection(title: String, type: RewardType, viewModel: RewardsViewModel, progress: UserProgress) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(theme.textPrimary)

            ForEach(viewModel.rewards(for: type), id: \.id) { reward in
                RewardItemCard(
                    reward: reward,
                    isSelected: viewModel.isSelected(reward),
                    theme: theme,
                    onSelect: {
                        RewardService.applySelection(reward: reward, to: progress)
                        try? modelContext.save()
                    }
                )
            }
        }
    }
}
