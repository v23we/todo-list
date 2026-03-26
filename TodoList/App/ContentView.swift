import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var progressList: [UserProgress]
    @State private var didBootstrap = false

    private var progress: UserProgress? {
        progressList.first
    }

    private var theme: ThemePalette {
        ThemePalette.palette(for: progress?.selectedThemeId ?? AppConstants.defaultThemeID)
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            if didBootstrap {
                TabView {
                    NavigationStack {
                        HomeView(theme: theme)
                    }
                    .tabItem {
                        Label("首页", systemImage: "house.fill")
                    }

                    NavigationStack {
                        TasksView(theme: theme)
                    }
                    .tabItem {
                        Label("任务", systemImage: "checklist")
                    }

                    NavigationStack {
                        RewardsView(theme: theme)
                    }
                    .tabItem {
                        Label("奖励", systemImage: "sparkles")
                    }
                }
                .tint(theme.accent)
            } else {
                ProgressView("正在准备 TodoList…")
                    .tint(theme.accent)
                    .foregroundStyle(theme.textPrimary)
            }
        }
        .task {
            guard !didBootstrap else { return }
            do {
                try PersistenceController.bootstrapIfNeeded(context: modelContext)
                didBootstrap = true
            } catch {
                assertionFailure("初始化失败: \(error)")
            }
        }
    }
}
