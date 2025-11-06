import SwiftUI

struct ContentView: View {
    @EnvironmentObject var goalManager: GoalManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Цели", systemImage: "target")
                }
                .tag(0)
            
            CharacterView()
                .tabItem {
                    Label("Персонаж", systemImage: "person.fill")
                }
                .tag(1)
            
            RewardsShopView()
                .tabItem {
                    Label("Награды", systemImage: "gift.fill")
                }
                .tag(2)
            
            AchievementsView()
                .tabItem {
                    Label("Достижения", systemImage: "trophy.fill")
                }
                .tag(3)
            
            StatsView()
                .tabItem {
                    Label("Статистика", systemImage: "chart.bar.fill")
                }
                .tag(4)
        }
        .accentColor(.purple)
    }
}

#Preview {
    ContentView()
        .environmentObject(GoalManager())
}
