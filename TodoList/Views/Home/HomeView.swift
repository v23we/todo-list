import SwiftUI
import SwiftData
import AudioToolbox
import UIKit

private struct WarmupHintBar: View {
    let theme: ThemePalette
    let hasCurrentTask: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "timer")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(theme.accent)

            if hasCurrentTask {
                Text("预计 5 分钟 · 轻量任务 · +\(AppConstants.xpPerTask)经验")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(theme.textSecondary)
            } else {
                Text("从一个 5 分钟小任务开始")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(theme.textSecondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 38)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(theme.accent.opacity(0.06))
        )
    }
}

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\TodoTask.sortOrder), SortDescriptor(\TodoTask.createdAt)]) private var tasks: [TodoTask]
    @Query private var progressList: [UserProgress]
    @Query(sort: [SortDescriptor(\RewardStyle.unlockLevel), SortDescriptor(\RewardStyle.name)]) private var rewards: [RewardStyle]
    @Query private var settingsList: [AppSettings]

    let theme: ThemePalette

    @State private var showCreator = false
    @State private var showSettings = false
    @State private var animationTrigger = 0
    @State private var latestOutcome: TaskCompletionOutcome?
    @State private var detailTask: TodoTask?

    private var progress: UserProgress? { progressList.first }
    private var settings: AppSettings? { settingsList.first }

    private var viewModel: HomeViewModel? {
        guard let progress else { return nil }
        return HomeViewModel(tasks: tasks, progress: progress, rewards: rewards)
    }

    var body: some View {
        ZStack(alignment: .top) {
            theme.background.ignoresSafeArea()

            Group {
                if let viewModel {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 28) {
                            
                            // 主任务区核心内容流
                            VStack(alignment: .leading, spacing: 0) {
                                XPBarView(
                                    progress: viewModel.progress,
                                    theme: theme,
                                    xpStyleID: viewModel.xpStyleID,
                                    effectStyleID: viewModel.effectStyleID,
                                    animationTrigger: animationTrigger,
                                    latestOutcome: latestOutcome,
                                    completedTodayCount: viewModel.completedTodayCount,
                                    gainedXPToday: viewModel.gainedXPToday,
                                    nextUnlockText: viewModel.nextUnlockText
                                )

                                Spacer().frame(height: 12)

                                WarmupHintBar(theme: theme, hasCurrentTask: viewModel.currentTask != nil)

                                Spacer().frame(height: 10)

                                if let currentTask = viewModel.currentTask {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("先做这一个")
                                            .font(.headline)
                                            .foregroundStyle(theme.textPrimary)

                                        CurrentTaskCard(
                                            task: currentTask,
                                            theme: theme,
                                            onOpen: { detailTask = currentTask },
                                            onComplete: { complete(task: currentTask) }
                                        )
                                    }
                                } else {
                                    emptyState(viewModel: viewModel)
                                }
                            }

                            if !viewModel.alternativeTasks.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("备选任务")
                                        .font(.headline)
                                        .foregroundStyle(theme.textPrimary)

                                    ForEach(viewModel.alternativeTasks, id: \.id) { task in
                                        NextTaskCard(
                                            task: task,
                                            theme: theme,
                                            onOpen: { detailTask = task },
                                            onMakeCurrent: { makeCurrent(task: task) }
                                        )
                                    }
                                }
                            }

                            Button {
                                showCreator = true
                            } label: {
                                Text("新建任务")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(theme.accent, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 8)
                        }
                        .padding(20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                } else {
                    ProgressView("正在加载首页…")
                        .tint(theme.accent)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle("首页")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(theme.textPrimary)
                }
            }
        }
        .sheet(isPresented: $showCreator) {
            NavigationStack {
                TaskEditorView(theme: theme)
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView(theme: theme)
            }
        }
        .sheet(item: $detailTask) { task in
            NavigationStack {
                TaskDetailView(task: task, theme: theme)
            }
        }
    }

    @ViewBuilder
    private func emptyState(viewModel: HomeViewModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("先做这一个")
                .font(.headline)
                .foregroundStyle(theme.textPrimary)
                
            VStack(alignment: .leading, spacing: 6) {
                Text("当前没有任务")
                    .font(.subheadline.bold())
                    .foregroundStyle(theme.textPrimary)
                Text("点击下方按钮开始你的下一步")
                    .font(.footnote)
                    .foregroundStyle(theme.textSecondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.surface.opacity(0.6), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(theme.border.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            )
        }
    }

    private func makeCurrent(task: TodoTask) {
        do {
            try TaskService.setCurrentTask(task, context: modelContext)
        } catch {
            assertionFailure("设为当前失败: \(error)")
        }
    }

    private func complete(task: TodoTask) {
        do {
            if let outcome = try TaskService.performPrimaryAction(for: task, context: modelContext) {
                latestOutcome = outcome
                animationTrigger += 1
                triggerFeedback(with: outcome)
            } else {
                latestOutcome = nil
            }
        } catch {
            assertionFailure("完成任务失败: \(error)")
        }
    }

    private func triggerFeedback(with outcome: TaskCompletionOutcome) {
        guard let settings else { return }

        if settings.hapticsEnabled {
            let generator = outcome.didLevelUp ? UINotificationFeedbackGenerator() : UIImpactFeedbackGenerator(style: .soft)
            if let generator = generator as? UIImpactFeedbackGenerator {
                generator.impactOccurred()
            } else if let generator = generator as? UINotificationFeedbackGenerator {
                generator.notificationOccurred(.success)
            }
        }

        if settings.soundEnabled {
            AudioServicesPlaySystemSound(outcome.didLevelUp ? 1025 : 1104)
        }
    }
}
