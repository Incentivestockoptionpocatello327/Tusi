import Foundation

/// Looks up `key` in Localizable.strings. Only English is shipped (Resources/en.lproj) —
/// the source strings ARE the Chinese, so any other system language just falls back to
/// them unchanged, which is exactly the "follow the system, don't add a toggle" behavior
/// this app wants. Short name because this wraps ~90 call sites across the app.
func L(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}
