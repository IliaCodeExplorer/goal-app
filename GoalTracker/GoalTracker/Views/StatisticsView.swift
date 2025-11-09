//
//  StatisticsView.swift
//  GoalTracker
//
//  Created by Ilyas on 11/7/25.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject var goalManager: GoalManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Overview Cards
                    OverviewCardsView()
                    
                    // Weekly Progress Chart
                    WeeklyProgressChart()
                    
                    // Goal Categories Breakdown
                    GoalCategoriesView()
                    
                    // Streak Info
                    StreakInfoView()
                    
                    // Best Achievements
                    TopAchievementsView()
                }
                .padding()
            }
            .navigationTitle("Статистика")
        }
    }
}

// MARK: - Overview Cards
struct OverviewCardsView: View {
    @EnvironmentObject var goalManager: GoalManager
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Общая статистика")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatsCardView(
                    title: "Всего целей",
                    value: "\(goalManager.totalGoals)",
                    icon: "target",
                    color: .blue
                )
                
                StatsCardView(
                    title: "Завершено",
                    value: "\(goalManager.completedGoals)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatsCardView(
                    title: "Уровень",
                    value: "\(goalManager.userProfile.level)",
                    icon: "star.fill",
                    color: .orange
                )
                
                StatsCardView(
                    title: "Монеты",
                    value: "\(goalManager.userProfile.coins)",
                    icon: "dollarsign.circle.fill",
                    color: .yellow
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct StatsCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Weekly Progress Chart
struct WeeklyProgressChart: View {
    @EnvironmentObject var goalManager: GoalManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Прогресс за 7 дней")
                .font(.headline)
            
            let data = goalManager.completionsInLast7Days()
                .sorted { $0.key < $1.key }
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                        BarMark(
                            x: .value("День", dayName(from: item.key)),
                            y: .value("Выполнено", item.value)
                        )
                        .foregroundStyle(.blue.gradient)
                        .cornerRadius(4)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let day = value.as(String.self) {
                                Text(day)
                                    .font(.caption)
                            }
                        }
                    }
                }
            } else {
                // Fallback for older iOS versions
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                        VStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue)
                                .frame(width: 30, height: CGFloat(item.value) * 20 + 20)
                            
                            Text(dayName(from: item.key))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func dayName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

// MARK: - Goal Categories
struct GoalCategoriesView: View {
    @EnvironmentObject var goalManager: GoalManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Распределение по частоте")
                .font(.headline)
            
            let frequencyData = Dictionary(grouping: goalManager.goals, by: { $0.frequency })
            
            ForEach(Frequency.allCases, id: \.self) { frequency in
                if let count = frequencyData[frequency]?.count, count > 0 {
                    HStack {
                        Text(frequency.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(count)")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        GeometryReader { geometry in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: geometry.size.width * CGFloat(count) / CGFloat(goalManager.totalGoals))
                        }
                        .frame(width: 100, height: 20)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

// MARK: - Streak Info
struct StreakInfoView: View {
    @EnvironmentObject var goalManager: GoalManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Текущая серия")
                        .font(.headline)
                    Text("\(goalManager.userProfile.streak) дней")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Рекорд")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(goalManager.userProfile.longestStreak)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
            
            // Motivational message
            Text(streakMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.2), Color.yellow.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
    
    private var streakMessage: String {
        let streak = goalManager.userProfile.streak
        if streak == 0 {
            return "Начни сегодня и создай свою серию!"
        } else if streak < 7 {
            return "Отличное начало! Продолжай в том же духе 💪"
        } else if streak < 30 {
            return "Невероятно! Ты на пути к месячной серии 🔥"
        } else {
            return "Легенда! Такая дисциплина восхищает 🏆"
        }
    }
}

// MARK: - Top Achievements
struct TopAchievementsView: View {
    @EnvironmentObject var goalManager: GoalManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Последние достижения")
                    .font(.headline)
                
                Spacer()
                
                Text("\(goalManager.achievements.count)")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            if goalManager.achievements.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("Пока нет достижений")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Выполняй цели чтобы разблокировать!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ForEach(goalManager.achievements.prefix(3)) { achievement in
                    AchievementRowView(achievement: achievement)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct AchievementRowView: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(rarityColor)
                .frame(width: 40, height: 40)
                .background(rarityColor.opacity(0.2))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(achievement.rarity.rawValue)
                    .font(.caption)
                    .foregroundColor(rarityColor)
            }
            
            Spacer()
            
            Text("+\(achievement.coinsEarned)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.orange)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var rarityColor: Color {
        switch achievement.rarity {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
}

#Preview {
    StatisticsView()
        .environmentObject(GoalManager())
}
