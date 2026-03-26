import SwiftUI
import SwiftData

struct TasksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\TodoTask.sortOrder), SortDescriptor(\TodoTask.createdAt)]) private var tasks: [TodoTask]

    let theme: ThemePalette

    @State private var showCreator = false
    @State private var selectedTask: TodoTask?
    @State private var showCompleted = false

    private var viewModel: TasksViewModel {
        TasksViewModel(tasks: tasks)
    }

    var body: some View {
        List {
            taskSection("当前", tasks: viewModel.currentTasks)
            taskSection("待处理", tasks: viewModel.pendingTasks)
            taskSection("稍后", tasks: viewModel.laterTasks)

            Section {
                Button(showCompleted ? "收起已完成" : "展开已完成") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showCompleted.toggle()
                    }
                }
                .foregroundStyle(theme.accent)

                if showCompleted {
                    ForEach(viewModel.completedTasks, id: \.id) { task in
                        taskRow(task)
                    }
                }
            } header: {
                Text("已完成")
            }
        }
        .scrollContentBackground(.hidden)
        .background(theme.background)
        .navigationTitle("任务")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCreator = true
                } label: {
                    Image(systemName: "plus")
                }
                .foregroundStyle(theme.textPrimary)
            }
        }
        .sheet(isPresented: $showCreator) {
            NavigationStack {
                TaskEditorView(theme: theme)
            }
        }
        .sheet(item: $selectedTask) { task in
            NavigationStack {
                TaskDetailView(task: task, theme: theme)
            }
        }
    }

    @ViewBuilder
    private func taskSection(_ title: String, tasks: [TodoTask]) -> some View {
        Section {
            if tasks.isEmpty {
                Text("暂无\(title)任务")
                    .foregroundStyle(theme.textSecondary)
            } else {
                ForEach(tasks, id: \.id) { task in
                    taskRow(task)
                }
            }
        } header: {
            Text(title)
        }
    }

    private func taskRow(_ task: TodoTask) -> some View {
        Button {
            selectedTask = task
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(task.title)
                        .font(.headline)
                        .foregroundStyle(task.section == .later ? theme.textSecondary : theme.textPrimary)
                    if task.isCurrent {
                        Text("当前")
                            .font(.caption.bold())
                            .foregroundStyle(theme.accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(theme.surfaceStrong, in: Capsule())
                    } else if task.section == .later {
                        Text("稍后")
                            .font(.caption.bold())
                            .foregroundStyle(theme.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(theme.surfaceStrong.opacity(0.6), in: Capsule())
                    }
                }

                Text("下一步：\(task.nextStepText)")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)

                if let progressText = task.progressText {
                    Text("进度：\(progressText)")
                        .font(.footnote)
                        .foregroundStyle(theme.textSecondary)
                }

                if task.section == .later {
                    Text("已移到稍后，不参与首页当前任务或备选补位。")
                        .font(.footnote)
                        .foregroundStyle(theme.textSecondary)
                }
            }
            .padding(.vertical, 6)
            .opacity(task.section == .later ? 0.82 : 1)
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            if !task.isCompleted {
                Button("设为当前") {
                    try? TaskService.setCurrentTask(task, context: modelContext)
                }
                .tint(theme.accent)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if !task.isCompleted {
                Button(task.hasSubtasks ? "完成下一步" : "完成") {
                    _ = try? TaskService.performPrimaryAction(for: task, context: modelContext)
                }
                .tint(.green)
            }
            if task.section == .pending && !task.isCompleted {
                Button("稍后") {
                    try? TaskService.moveTask(task, to: .later, context: modelContext)
                }
                .tint(.orange)
            } else if task.section == .later && !task.isCompleted {
                Button("待处理") {
                    try? TaskService.moveTask(task, to: .pending, context: modelContext)
                }
                .tint(.blue)
            }
        }
        .listRowBackground(theme.surface)
    }
}
