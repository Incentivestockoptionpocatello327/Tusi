import AppKit
import Carbon

/// Registers a user-chosen combo as a global hotkey via Carbon (no accessibility
/// permission needed). The event handler is installed once at init; the hotkey itself can
/// be re-registered at any time via `update(combo:)` when the user rebinds it.
final class HotkeyManager {
    private var hotKeyRef: EventHotKeyRef?
    private var handlerRef: EventHandlerRef?
    private let callback: () -> Void

    /// Fails only if the Carbon event handler can't be installed (rare). The hotkey
    /// registration itself is done separately via `update(combo:)`, which is retryable.
    init?(callback: @escaping () -> Void) {
        self.callback = callback

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        var handler: EventHandlerRef?
        let installStatus = InstallEventHandler(
            GetEventDispatcherTarget(),
            { _, _, userData -> OSStatus in
                guard let userData else { return noErr }
                let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
                DispatchQueue.main.async { manager.callback() }
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &handler
        )
        guard installStatus == noErr else { return nil }
        handlerRef = handler
    }

    /// (Re)registers the global hotkey. Returns whether registration succeeded — a bare
    /// combo (no modifier) is rejected, as are combos another app already owns.
    @discardableResult
    func update(combo: KeyCombo) -> Bool {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        let carbonMods = Self.carbonModifiers(from: combo.modifiers)
        guard carbonMods != 0 else { return false }

        let hotKeyID = EventHotKeyID(signature: Self.fourCC("TUSI"), id: 1)
        var ref: EventHotKeyRef?
        let status = RegisterEventHotKey(
            UInt32(combo.keyCode),
            carbonMods,
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &ref
        )
        guard status == noErr else { return false }
        hotKeyRef = ref
        return true
    }

    deinit {
        if let hotKeyRef { UnregisterEventHotKey(hotKeyRef) }
        if let handlerRef { RemoveEventHandler(handlerRef) }
    }

    private static func carbonModifiers(from raw: UInt) -> UInt32 {
        let flags = NSEvent.ModifierFlags(rawValue: raw)
        var carbon: UInt32 = 0
        if flags.contains(.command) { carbon |= UInt32(cmdKey) }
        if flags.contains(.option) { carbon |= UInt32(optionKey) }
        if flags.contains(.control) { carbon |= UInt32(controlKey) }
        if flags.contains(.shift) { carbon |= UInt32(shiftKey) }
        return carbon
    }

    private static func fourCC(_ string: String) -> FourCharCode {
        string.utf16.reduce(0) { ($0 << 8) + FourCharCode($1) }
    }
}
