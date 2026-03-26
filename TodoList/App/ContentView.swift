import SwiftUI
import SwiftData
import UIKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var progressList: [UserProgress]
    @State private var didBootstrap = false

    private var progress: UserProgress? {
        progressList.first
    }

    private var theme: ThemePalette {
        ThemePalette.palette(for: progress?.selectedThemeId ?? AppConstants.defaultThemeID)
    }

    var body: some View {
        ZStack(alignment: .top) {
            theme.background.ignoresSafeArea()

            if didBootstrap {
                rootTabView
            } else {
                ProgressView("正在准备 TodoList…")
                    .tint(theme.accent)
                    .foregroundStyle(theme.textPrimary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .task {
            guard !didBootstrap else { return }
            do {
                try PersistenceController.bootstrapIfNeeded(context: modelContext)
                didBootstrap = true
            } catch {
                assertionFailure("初始化失败: \(error)")
            }
        }
        .onAppear {
            applySceneSizeRestrictions()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            applySceneSizeRestrictions()
        }
    }

    private var rootTabView: some View {
        TabView {
            NavigationStack {
                HomeView(theme: theme)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .tabItem {
                Label("首页", systemImage: "house.fill")
            }

            NavigationStack {
                TasksView(theme: theme)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .tabItem {
                Label("任务", systemImage: "checklist")
            }

            NavigationStack {
                RewardsView(theme: theme)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .tabItem {
                Label("奖励", systemImage: "sparkles")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .tint(theme.accent)
    }

    @MainActor
    private func applySceneSizeRestrictions() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }),
              let restrictions = windowScene.sizeRestrictions else {
            return
        }

        let targetSize = windowScene.screen.bounds.size

        if restrictions.minimumSize != targetSize {
            restrictions.minimumSize = targetSize
        }

        if restrictions.maximumSize != targetSize {
            restrictions.maximumSize = targetSize
        }
    }
}
