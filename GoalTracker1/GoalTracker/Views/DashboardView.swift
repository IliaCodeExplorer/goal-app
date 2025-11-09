import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var goalManager: GoalManager
    @State private var showingAddGoal = false
    @State private var showingTemplates = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if goalManager.goals.isEmpty {
                    EmptyStateView(showingAddGoal: $showingAddGoal, showingTemplates: $showingTemplates)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Header Stats
                            HeaderStatsView()
                                .padding(.horizontal)
                            
                            // Active Goals
                            if !goalManager.activeGoals.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Активные цели")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal)
                                    
                                    ForEach(goalManager.activeGoals) { goal in
                                        GoalCardView(goal: goal)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                            
                            // Completed Goals
                            if !goalManager.completedGoalsList.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Завершенные")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                        .padding(.horizontal)
                                    
                                    ForEach(goalManager.completedGoalsList) { goal in
                                        GoalCardView(goal: goal)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
                
                // Achievement Notification Overlay
                if goalManager.showAchievementNotification, let achievement = goalManager.latestAchievement {
                    AchievementNotificationView(achievement: achievement)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(100)
                }
            }
            .navigationTitle("Мои цели")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingTemplates = true
                    } label: {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.title3)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddGoal = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView()
            }
            .sheet(isPresented: $showingTemplates) {
                GoalTemplatesView()
            }
        }
        .onAppear {
            goalManager.checkAndResetRepeatingGoals()
        }
    }
}

struct HeaderStatsView: View {
    @EnvironmentObject var goalManager: GoalManager
    
    var body: some View {
        HStack(spacing: 15) {
            StatBoxView(
                title: "Всего",
                value: "\(goalManager.totalGoals)",
                color: .blue
            )
            
            StatBoxView(
                title: "Активные",
                value: "\(goalManager.activeGoals.count)",
                color: .orange
            )
            
            StatBoxView(
                title: "Завершено",
                value: "\(goalManager.completedGoals)",
                color: .green
            )
        }
    }
}

struct StatBoxView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct EmptyStateView: View {
    @Binding var showingAddGoal: Bool
    @Binding var showingTemplates: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("Пока нет целей")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Создайте свою первую цель или выберите из шаблонов")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            HStack(spacing: 16) {
                Button {
                    showingTemplates = true
                } label: {
                    Label("Шаблоны", systemImage: "list.bullet.rectangle")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(12)
                }
                
                Button {
                    showingAddGoal = true
                } label: {
                    Label("Создать", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding(.top)
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(GoalManager())
}
