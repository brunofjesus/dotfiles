#!/usr/bin/swift

import Foundation

let home = NSHomeDirectory()

func runShell(_ command: String, args: [String] = []) {
    let process = Process()
    process.launchPath = command
    process.arguments = args
    process.standardOutput = nil
    process.standardError = nil
    try? process.run()
}

// Re-theme every app that supports live theme switching.
func applyTheme(mode: String) {
    let theme = mode == "dark" ? "frappe" : "latte"
    runShell("\(home)/.config/nvim/set-theme.sh", args: [mode])
    runShell("\(home)/Library/Application Support/k9s/set-theme.sh", args: [theme])
    runShell("\(home)/.config/tmux/set-theme.sh", args: [theme])
}

func currentMode() -> String {
    UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark" ? "dark" : "light"
}

let nc = DistributedNotificationCenter.default()

nc.addObserver(forName: Notification.Name("AppleInterfaceThemeChangedNotification"), object: nil, queue: nil) { _ in
    let mode = currentMode()
    print("Appearance changed to \(mode)")
    applyTheme(mode: mode)
}

// Also run once immediately on startup.
applyTheme(mode: currentMode())

RunLoop.main.run()
