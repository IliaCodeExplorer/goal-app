import SwiftUI
import Combine

// v0.1.5.2 - Smart sorting + Collapsible completed section
struct DashboardView: View {
    @EnvironmentObject var goalManager: GoalManager
    @State private var showingAddGoal = false
    @State private var showingTemplates = false
    @State private var showCompletedGoals = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if goalManager.goals.isEmpty {
                    EmptyStateView(showingAddGoal: $showingAddGoal, showingTemplates: $showingTemplates)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header Stats
                            HeaderStatsView()
                                .padding(.horizontal)
                            
                            // Daily Goals Section
                            if !goalManager.dailyGoals.isEmpty {
                                GoalSectionView(
                                    title: "Сегодня",
                                    icon: "sun.max.fill",
                                    color: .orange,
                                    goals: goalManager.dailyGoals
                                )
                            }
                            
                            // Weekly Goals Section
                            if !goalManager.weeklyGoals.isEmpty {
                                GoalSectionView(
                                    title: "Эта неделя",
                                    icon: "calendar",
                                    color: .blue,
                                    goals: goalManager.weeklyGoals
                                )
                            }
                            
                            // Monthly Goals Section
                            if !goalManager.monthlyGoals.isEmpty {
                                GoalSectionView(
                                    title: "Этот месяц",
                                    icon: "calendar.badge.clock",
                                    color: .purple,
                                    goals: goalManager.monthlyGoals
                                )
                            }
                            
                            // Yearly Goals Section
                            if !goalManager.yearlyGoals.isEmpty {
                                GoalSectionView(
                                    title: "Этот год",
                                    icon: "calendar.circle",
                                    color: .indigo,
                                    goals: goalManager.yearlyGoals
                                )
                            }
                            
                            // Completed Goals Collapsible Section
                            if !goalManager.completedGoalsList.isEmpty {
                                CompletedGoalsSectionView(isExpanded: $showCompletedGoals)
                                    .padding(.horizontal)
                            }
                            
                            // Bottom spacing
                            Color.clear.frame(height: 20)
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
                        HapticManager.shared.impact()
                        showingTemplates = true
                    } label: {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.title3)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.shared.impact()
                        showingAddGoal = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                GoalFormView(mode: .create)
            }
            .sheet(isPresented: $showingTemplates) {
                GoalTemplatesView()
            }
        }
        .onAppear {
            print("🏠 Dashboard appeared")
            goalManager.checkAndResetRepeatingGoals()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            print("📱 App entered foreground")
            goalManager.checkAndResetRepeatingGoals()
        }
    }
}

// MARK: - Goal Section View
struct GoalSectionView: View {
    let title: String
    let icon: String
    let color: Color
    let goals: [Goal]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("(\(goals.count))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.horizontal)
            
            ForEach(goals) { goal in
                GoalCardView(goal: goal)
                    .padding(.horizontal)
            }
        }
    }
}

// MARK: - Completed Goals Collapsible Section
struct CompletedGoalsSectionView: View {
    @EnvironmentObject var goalManager: GoalManager
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Button
            Button {
                HapticManager.shared.impact()
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                    
                    Text("Завершенные")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("(\(goalManager.completedGoalsList.count))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expandable Content
            // Expandable Content
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(goalManager.completedGoalsList) { goal in
                        GoalCardView(goal: goal)
                    }
                }
                .padding(.top, 12)
            }
        }
    }
}

// MARK: - Header Stats
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

// MARK: - Stat Box
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

// MARK: - Empty State
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
                    HapticManager.shared.impact()
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
                    HapticManager.shared.impact()
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
