import AppIntents

struct WateryWatWatShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddWaterIntent(),
            phrases: [
                "Add water in \(.applicationName)",
                "Log water in \(.applicationName)"
            ],
            shortTitle: "Add Water",
            systemImageName: "drop.fill"
        )
    }
}
