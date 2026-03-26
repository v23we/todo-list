import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var settingsList: [AppSettings]

    let theme: ThemePalette

    private var settings: AppSettings? {
        settingsList.first
    }

    var body: some View {
        Group {
            if let settings {
                Form {
                    Toggle("开启音效", isOn: bind(settings, keyPath: \.soundEnabled))
                    Toggle("开启震动反馈", isOn: bind(settings, keyPath: \.hapticsEnabled))
                    Toggle("减少动态效果", isOn: bind(settings, keyPath: \.reduceMotionEnabled))
                }
                .scrollContentBackground(.hidden)
                .background(theme.background)
            } else {
                ProgressView("正在加载设置…")
                    .tint(theme.accent)
            }
        }
        .navigationTitle("设置")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("完成") {
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
    }

    private func bind(_ settings: AppSettings, keyPath: ReferenceWritableKeyPath<AppSettings, Bool>) -> Binding<Bool> {
        Binding(
            get: { settings[keyPath: keyPath] },
            set: { settings[keyPath: keyPath] = $0 }
        )
    }
}
