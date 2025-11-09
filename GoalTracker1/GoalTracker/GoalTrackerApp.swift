import SwiftUI

@main
struct GoalTrackerApp: App {
    @StateObject private var goalManager = GoalManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(goalManager)
        }
    }
}
