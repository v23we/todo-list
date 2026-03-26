import SwiftData

enum PersistenceController {
    static let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TodoTask.self,
            Subtask.self,
            UserProgress.self,
            RewardStyle.self,
            AppSettings.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("无法创建 ModelContainer: \(error)")
        }
    }()

    @MainActor
    static func bootstrapIfNeeded(context: ModelContext) throws {
        let progress = try ProgressService.fetchProgress(context: context)

        let settingsDescriptor = FetchDescriptor<AppSettings>()
        if try context.fetch(settingsDescriptor).first == nil {
            context.insert(AppSettings())
        }

        try RewardService.bootstrapRewards(context: context, progress: progress)
        try TaskService.normalizeCurrentTask(context: context)

        if context.hasChanges {
            try context.save()
        }
    }
}
