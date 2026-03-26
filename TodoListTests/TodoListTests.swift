import XCTest
import SwiftData
@testable import TodoList

@MainActor
final class TodoListTests: XCTestCase {
    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            TodoTask.self,
            Subtask.self,
            UserProgress.self,
            RewardStyle.self,
            AppSettings.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    func testTaskCompletionCarriesOverflowAndLevelsUp() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let progress = UserProgress(level: 1, currentXP: 90, totalXP: 90)
        context.insert(progress)
        try RewardService.bootstrapRewards(context: context, progress: progress)

        let rewards = try RewardService.fetchRewards(context: context)
        let outcome = ProgressService.applyTaskCompletion(progress: progress, rewards: rewards)

        XCTAssertTrue(outcome.didLevelUp)
        XCTAssertEqual(progress.level, 2)
        XCTAssertEqual(progress.currentXP, 10)
        XCTAssertEqual(progress.totalXP, 110)
    }

    func testRewardUnlockMatchesLevel() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let progress = UserProgress(level: 3)
        context.insert(progress)

        try RewardService.bootstrapRewards(context: context, progress: progress)
        let rewards = try RewardService.fetchRewards(context: context)

        XCTAssertTrue(rewards.contains(where: { $0.id == "theme_sky" && $0.isUnlocked }))
        XCTAssertTrue(rewards.contains(where: { $0.id == "xp_bean" && $0.isUnlocked }))
        XCTAssertFalse(rewards.contains(where: { $0.id == "sound_bell" && $0.isUnlocked }))
    }

    func testCurrentTaskPromotionUsesOrderedPendingTasks() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let progress = UserProgress()
        context.insert(progress)
        try RewardService.bootstrapRewards(context: context, progress: progress)

        let current = TodoTask(title: "当前任务", isCurrent: true, section: .pending, sortOrder: 1)
        let altOne = TodoTask(title: "备选一", section: .pending, sortOrder: 2)
        let altTwo = TodoTask(title: "备选二", section: .pending, sortOrder: 3)

        context.insert(current)
        context.insert(altOne)
        context.insert(altTwo)
        try context.save()

        _ = try TaskService.completeTask(current, context: context)

        XCTAssertTrue(altOne.isCurrent)
        XCTAssertFalse(altTwo.isCurrent)
    }

    func testPrimaryActionWithSubtasksCompletesOnlyFirstIncompleteSubtask() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let progress = UserProgress()
        context.insert(progress)
        try RewardService.bootstrapRewards(context: context, progress: progress)

        let task = TodoTask(title: "写周报", isCurrent: true, section: .pending, sortOrder: 1)
        let subtaskOne = Subtask(title: "整理本周事项", orderIndex: 0, parentTask: task)
        let subtaskTwo = Subtask(title: "补上风险说明", orderIndex: 1, parentTask: task)
        task.subtasks = [subtaskOne, subtaskTwo]

        context.insert(task)
        context.insert(subtaskOne)
        context.insert(subtaskTwo)
        try context.save()

        let firstOutcome = try TaskService.performPrimaryAction(for: task, context: context)

        XCTAssertNil(firstOutcome)
        XCTAssertTrue(subtaskOne.isCompleted)
        XCTAssertFalse(subtaskTwo.isCompleted)
        XCTAssertFalse(task.isCompleted)
        XCTAssertEqual(progress.totalXP, 0)

        let finalOutcome = try TaskService.performPrimaryAction(for: task, context: context)

        XCTAssertNotNil(finalOutcome)
        XCTAssertTrue(subtaskTwo.isCompleted)
        XCTAssertTrue(task.isCompleted)
        XCTAssertEqual(progress.totalXP, AppConstants.xpPerTask)
    }

    func testLaterTasksAreExcludedFromCurrentPromotion() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let progress = UserProgress()
        context.insert(progress)
        try RewardService.bootstrapRewards(context: context, progress: progress)

        let current = TodoTask(title: "当前任务", isCurrent: true, section: .pending, sortOrder: 1)
        let laterTask = TodoTask(title: "稍后任务", section: .later, sortOrder: 2)
        let pendingTask = TodoTask(title: "待处理任务", section: .pending, sortOrder: 3)

        context.insert(current)
        context.insert(laterTask)
        context.insert(pendingTask)
        try context.save()

        _ = try TaskService.completeTask(current, context: context)

        XCTAssertFalse(laterTask.isCurrent)
        XCTAssertTrue(pendingTask.isCurrent)
    }

    func testManualNextStepIsIgnoredWhenTaskHasSubtasks() {
        let task = TodoTask(title: "收拾书桌", manualNextStep: "这条不该显示", section: .pending)
        let subtask = Subtask(title: "先把水杯拿走", orderIndex: 0, parentTask: task)
        task.subtasks = [subtask]

        XCTAssertEqual(task.displayNextStep, "先把水杯拿走")
    }

    func testDisplayNextStepUsesManualValueWhenThereAreNoSubtasks() {
        let task = TodoTask(title: "收拾书桌", manualNextStep: "先清空桌面", section: .pending)

        XCTAssertEqual(task.displayNextStep, "先清空桌面")
    }

    func testDisplayNextStepIsNilWhenThereAreNoSubtasksAndNoManualValue() {
        let task = TodoTask(title: "收拾书桌", manualNextStep: "   ", section: .pending)

        XCTAssertNil(task.displayNextStep)
    }
}
