#!/usr/bin/swift

import Foundation

func runShell(_ command: String, args: [String] = []) {
    let process = Process()
    process.launchPath = command
    process.arguments = args
    process.standardOutput = nil
    process.standardError = nil
    try? process.run()
}

let nc = DistributedNotificationCenter.default()

nc.addObserver(forName: Notification.Name("AppleInterfaceThemeChangedNotification"), object: nil, queue: nil) { _ in
    let mode = (UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark") ? "dark" : "light"
    let theme = mode == "dark" ? "frappe" : "latte"
    print("Appearance changed to \(mode)")
    runShell("/Users/bruno/.config/nvim/set-theme.sh", args: [mode])
    runShell("/Users/bruno/Library/Application Support/k9s/set-theme.sh", args: [theme])
}

// Also run once immediately on startup (optional)
let initialMode = (UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark") ? "dark" : "light"
let initialTheme = initialMode == "dark" ? "frappe" : "latte"
runShell("/Users/bruno/.config/nvim/set-theme.sh", args: [initialMode])
runShell("/Users/bruno/Library/Application Support/k9s/set-theme.sh", args: [initialTheme])

RunLoop.main.run()
