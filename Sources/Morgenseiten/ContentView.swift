import AppKit
import SwiftUI

/// Transient view state. Kept in an `ObservableObject` instead of `@State`,
/// because `@State` is a macro in current SDKs and its compiler plugin ships
/// only with Xcode, not with the Command Line Tools.
@MainActor
final class UIState: ObservableObject {
    @Published var justCopied = false
    @Published var confirmingReset = false
}

struct ContentView: View {
    /// The draft survives quitting the app, so a crash never costs a page.
    @AppStorage("draft") private var text = ""
    @StateObject private var ui = UIState()
    @FocusState private var editorFocused: Bool

    private var wordCount: Int { WordLimit.count(text) }
    private var isComplete: Bool { wordCount >= WordLimit.target }

    var body: some View {
        VStack(spacing: 0) {
            editor
            footer
        }
        .background(Color(nsColor: .textBackgroundColor))
        .onAppear { editorFocused = true }
        .onChange(of: text) { _, newValue in
            let clamped = WordLimit.clamp(newValue)
            if clamped != newValue {
                text = clamped
                NSSound.beep()
            }
        }
        .confirmationDialog(
            "Neue Seite beginnen?",
            isPresented: $ui.confirmingReset
        ) {
            Button("Text verwerfen", role: .destructive) {
                text = ""
                editorFocused = true
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Der aktuelle Text wird gelöscht.")
        }
    }

    private var editor: some View {
        TextEditor(text: $text)
            .font(.system(size: 18, design: .serif))
            .lineSpacing(7)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.never)
            .focused($editorFocused)
            .frame(maxWidth: 680)
            .padding(.horizontal, 32)
            .padding(.top, 44)
            .frame(maxWidth: .infinity)
    }

    private var footer: some View {
        VStack(spacing: 10) {
            ProgressView(value: Double(wordCount), total: Double(WordLimit.target))
                .tint(isComplete ? .green : .accentColor)
                .animation(.easeOut(duration: 0.2), value: wordCount)

            HStack {
                Text("\(wordCount) / \(WordLimit.target) Wörter")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)

                Spacer()

                Button("Neue Seite") { ui.confirmingReset = true }
                    .disabled(text.isEmpty)

                Button(ui.justCopied ? "Kopiert ✓" : "Kopieren", action: copy)
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut("c", modifiers: [.command, .shift])
                    .disabled(!isComplete)
                    .help(isComplete
                          ? "Text in die Zwischenablage kopieren (⇧⌘C)"
                          : "Verfügbar, sobald 750 Wörter erreicht sind")
            }
            .font(.callout)
        }
        .frame(maxWidth: 680)
        .padding(.horizontal, 36)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
    }

    private func copy() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        ui.justCopied = true
        Task {
            try? await Task.sleep(for: .seconds(2))
            ui.justCopied = false
        }
    }
}
