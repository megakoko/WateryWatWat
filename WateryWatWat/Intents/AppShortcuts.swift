import AppIntents

struct WateryWatWatShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddWaterIntent(),
            phrases: [
                "Add water using \(.applicationName)",
                "Log water using \(.applicationName)"
            ],
            shortTitle: "Add Water",
            systemImageName: "drop.fill"
        )
        AppShortcut(
            intent: LogWaterWithAmountIntent(),
            phrases: [
                "Quick log water with \(.applicationName)",
                "Log a drink with \(.applicationName)"
            ],
            shortTitle: "Quick Log Water",
            systemImageName: "drop.fill"
        )
    }
}
