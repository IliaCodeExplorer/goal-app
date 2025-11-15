import SwiftUI

// v0.1.4 - Auto-reset on app launch
@main
struct GoalTrackerApp: App {
    @StateObject private var goalManager = GoalManager()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(goalManager)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                print("🚀 App became active")
                goalManager.checkAndResetRepeatingGoals()
            }
        }
    }
}
