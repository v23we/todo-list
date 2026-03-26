import SwiftUI
import SwiftData

struct TaskEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let theme: ThemePalette

    @State private var title = ""
    @State private var note = ""
    @State private var nextStep = ""
    @State private var section: TaskSection = .pending
    @State private var shouldSetCurrent = true
    @State private var subtaskDrafts: [String] = [""]
    @State private var errorMessage: String?

    private var hasNamedSubtasks: Bool {
        subtaskDrafts.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    var body: some View {
        Form {
            Section("基本信息") {
                TextField("任务标题", text: $title)
                TextField(hasNamedSubtasks ? "下一步（已由子任务自动生成）" : "下一步（可选）", text: $nextStep)
                    .disabled(hasNamedSubtasks)
                if hasNamedSubtasks {
                    Text("已有子任务时，首页显示的“下一步”会自动等于第一个未完成子任务。")
                        .font(.footnote)
                        .foregroundStyle(theme.textSecondary)
                }
                TextField("备注（可选）", text: $note, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section("状态") {
                Picker("分区", selection: $section) {
                    Text(TaskSection.pending.rawValue).tag(TaskSection.pending)
                    Text(TaskSection.later.rawValue).tag(TaskSection.later)
                }
                .pickerStyle(.segmented)

                Toggle("创建后设为当前任务", isOn: $shouldSetCurrent)
                    .disabled(section != .pending)
                    .onChange(of: section) { _, newValue in
                        if newValue != .pending {
                            shouldSetCurrent = false
                        }
                    }
            }

            Section("子任务（可选）") {
                ForEach(subtaskDrafts.indices, id: \.self) { index in
                    HStack {
                        TextField("子任务 \(index + 1)", text: $subtaskDrafts[index])
                        if subtaskDrafts.count > 1 {
                            Button(role: .destructive) {
                                subtaskDrafts.remove(at: index)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                            }
                        }
                    }
                }

                Button {
                    subtaskDrafts.append("")
                } label: {
                    Label("添加子任务", systemImage: "plus.circle")
                }
                .foregroundStyle(theme.accent)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(theme.background)
        .navigationTitle("新建任务")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("取消") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") {
                    saveTask()
                }
                .fontWeight(.semibold)
            }
        }
    }

    private func saveTask() {
        do {
            let draft = TaskDraft(
                title: title,
                note: note,
                nextStep: nextStep,
                section: section,
                shouldSetCurrent: shouldSetCurrent,
                subtasks: subtaskDrafts
            )
            _ = try TaskService.createTask(from: draft, context: modelContext)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
