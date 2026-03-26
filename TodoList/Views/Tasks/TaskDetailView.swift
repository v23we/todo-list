import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var task: TodoTask

    let theme: ThemePalette

    @State private var newSubtaskTitle = ""
    @State private var latestOutcome: TaskCompletionOutcome?

    private var viewModel: TaskDetailViewModel {
        TaskDetailViewModel(task: task)
    }

    var body: some View {
        Form {
            Section("基本信息") {
                TextField("任务标题", text: $task.title)
                if viewModel.shouldShowNextStepField {
                    TextField("下一步（可选）", text: $task.manualNextStep)
                }
                TextField("备注（可选）", text: $task.note, axis: .vertical)
                    .lineLimit(3...6)
            }

            if !task.isCompleted {
                Section("任务状态") {
                    Picker("分区", selection: Binding(
                        get: { task.section },
                        set: { newValue in
                            try? TaskService.moveTask(task, to: newValue, context: modelContext)
                        }
                    )) {
                        Text(TaskSection.pending.rawValue).tag(TaskSection.pending)
                        Text(TaskSection.later.rawValue).tag(TaskSection.later)
                    }
                    .pickerStyle(.segmented)

                    Toggle("设为当前任务", isOn: Binding(
                        get: { task.isCurrent },
                        set: { newValue in
                            if newValue {
                                try? TaskService.setCurrentTask(task, context: modelContext)
                            } else {
                                try? TaskService.clearCurrentTask(task, context: modelContext)
                            }
                        }
                    ))
                    .disabled(task.section != .pending)

                    Button {
                        latestOutcome = try? TaskService.performPrimaryAction(for: task, context: modelContext)
                        if task.isCompleted {
                            dismiss()
                        }
                    } label: {
                        Label(task.primaryActionDetailTitle, systemImage: "checkmark.circle.fill")
                            .foregroundStyle(theme.accent)
                    }

                    if task.section == .later {
                        Text("“稍后”表示先放一边，不会进入首页当前任务或备选任务。")
                            .font(.footnote)
                            .foregroundStyle(theme.textSecondary)
                    }
                }
            } else {
                Section("完成状态") {
                    Text("已完成")
                    if let completedAt = task.completedAt {
                        Text(completedAt.formatted(date: .abbreviated, time: .shortened))
                            .foregroundStyle(theme.textSecondary)
                    }
                }
            }

            Section("首页展示") {
                Text("下一步：\(viewModel.displayNextStep ?? viewModel.displayNextStepPlaceholder)")
                Text("进度：\(viewModel.progressText)")
                if let latestOutcome {
                    Text("本次完成获得 +\(latestOutcome.gainedXP) XP")
                        .foregroundStyle(theme.textSecondary)
                }
            }

            Section("子任务") {
                Text(viewModel.subtaskHintText)
                    .font(.footnote)
                    .foregroundStyle(theme.textSecondary)

                Text(viewModel.subtaskSummaryText)
                    .font(.footnote)
                    .foregroundStyle(theme.textSecondary)

                if viewModel.sortedSubtasks.isEmpty {
                    Text("暂无子任务")
                        .foregroundStyle(theme.textSecondary)
                } else {
                    ForEach(viewModel.sortedSubtasks, id: \.id) { subtask in
                        Toggle(isOn: Binding(
                            get: { subtask.isCompleted },
                            set: { newValue in
                                latestOutcome = try? TaskService.setSubtask(
                                    subtask,
                                    isCompleted: newValue,
                                    in: task,
                                    context: modelContext
                                )
                            }
                        )) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(subtask.title)
                                if task.nextIncompleteSubtask?.id == subtask.id && !subtask.isCompleted {
                                    Text("当前首页会把这一步显示为“下一步”")
                                        .font(.caption)
                                        .foregroundStyle(theme.textSecondary)
                                }
                            }
                        }
                        .disabled(task.isCompleted)
                    }
                    .onDelete(perform: deleteSubtasks)
                }

                if !task.isCompleted {
                    HStack {
                        TextField("添加子任务", text: $newSubtaskTitle)
                        Button("添加", action: addSubtask)
                            .disabled(newSubtaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(theme.background)
        .navigationTitle("任务详情")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") {
                    try? modelContext.save()
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
    }

    private func addSubtask() {
        let trimmed = newSubtaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let wasWithoutSubtasks = task.sortedSubtasks.isEmpty

        let subtask = Subtask(
            title: trimmed,
            orderIndex: task.sortedSubtasks.count,
            parentTask: task
        )
        task.subtasks.append(subtask)
        if wasWithoutSubtasks {
            task.manualNextStep = ""
        }
        modelContext.insert(subtask)
        newSubtaskTitle = ""
        try? modelContext.save()
    }

    private func deleteSubtasks(at offsets: IndexSet) {
        let sorted = viewModel.sortedSubtasks
        for index in offsets {
            let subtask = sorted[index]
            task.subtasks.removeAll(where: { $0.id == subtask.id })
            modelContext.delete(subtask)
        }
        for (index, subtask) in task.sortedSubtasks.enumerated() {
            subtask.orderIndex = index
        }
        try? modelContext.save()
    }
}
