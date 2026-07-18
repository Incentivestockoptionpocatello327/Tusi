import Foundation
import Combine

/// Transient UI state shared between the panel controller and SwiftUI views.
@MainActor
final class PanelState: ObservableObject {
    @Published var pinned = false
    @Published var showSettings = false
    /// While true the key monitor swallows the next keystroke and turns it into a shortcut.
    @Published var recordingShortcut = false
    /// Set when the ⌥Space global hotkey couldn't be registered (usually another app owns
    /// it). Surfaced in Settings so the failure isn't silent — the menu-bar icon still works.
    @Published var globalHotkeyFailed = false
}

extension Notification.Name {
    static let tusiFocusInput = Notification.Name("tusi.focusInput")
}
