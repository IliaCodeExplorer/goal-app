import SwiftUI

struct StatsView: View {
    @EnvironmentObject var goalManager: GoalManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Overall Stats
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Обзор")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 12) {
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
                        }
                        
                        HStack(spacing: 12) {
                            StatsCardView(
                                title: "В процессе",
                                value: "\(goalManager.activeGoals.count)",
                                icon: "clock.fill",
                                color: .orange
                            )
                            
                            StatsCardView(
                                title: "Достижения",
                                value: "\(goalManager.achievements.count)",
                                icon: "trophy.fill",
                                color: .yellow
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Completion Rate
                    if goalManager.totalGoals > 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Процент завершения")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text("\(completionPercentage)%")
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundColor(.green)
                                    
                                    Spacer()
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 20)
                                        
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(
                                                LinearGradient(
                                                    colors: [.green, .green.opacity(0.7)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(
                                                width: geometry.size.width * CGFloat(completionPercentage) / 100,
                                                height: 20
                                            )
                                    }
                                }
                                .frame(height: 20)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Weekly Progress Chart
                    if goalManager.totalCompletions > 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Прогресс за неделю")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            WeeklyChartView(data: goalManager.completionsInLast7Days())
                                .frame(height: 200)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Total Completions
                    if goalManager.totalCompletions > 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("История выполнения")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.green)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(goalManager.totalCompletions)")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.primary)
                                    
                                    Text("Всего завершений")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Goals by Frequency
                    if !goalManager.goals.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Цели по частоте")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            VStack(spacing: 12) {
                                ForEach(Frequency.allCases, id: \.self) { frequency in
                                    let count = goalManager.goals.filter { $0.frequency == frequency }.count
                                    if count > 0 {
                                        HStack {
                                            Text(frequency.rawValue)
                                                .font(.headline)
                                            
                                            Spacer()
                                            
                                            Text("\(count)")
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .foregroundColor(.blue)
                                        }
                                        .padding()
                                        .background(Color(.systemBackground))
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Recent Completions
                    if !recentCompletions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Последние завершения")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            VStack(spacing: 12) {
                                ForEach(recentCompletions.prefix(5), id: \.id) { record in
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        
                                        Text(formatDate(record.date))
                                            .font(.subheadline)
                                        
                                        Spacer()
                                        
                                        Text("\(Int(record.value))")
                                            .font(.headline)
                                            .foregroundColor(.blue)
                                    }
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Статистика")
        }
    }
    
    private var completionPercentage: Int {
        guard goalManager.totalGoals > 0 else { return 0 }
        return Int((Double(goalManager.completedGoals) / Double(goalManager.totalGoals)) * 100)
    }
    
    private var recentCompletions: [CompletionRecord] {
        goalManager.goals
            .flatMap { $0.completionHistory }
            .sorted { $0.date > $1.date }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

struct WeeklyChartView: View {
    let data: [Date: Int]
    
    var sortedData: [(Date, Int)] {
        data.sorted { $0.key < $1.key }
    }
    
    var maxValue: Int {
        sortedData.map { $0.1 }.max() ?? 1
    }
    
    var body: some View {
        // Custom bar chart that works on all iOS versions
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(sortedData, id: \.0) { date, count in
                VStack(spacing: 4) {
                    Spacer()
                    
                    ZStack(alignment: .bottom) {
                        // Background bar
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 150)
                        
                        // Progress bar
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: count > 0 ? [.blue, .blue.opacity(0.7)] : [.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: calculateBarHeight(count: count))
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Count label
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(count > 0 ? .blue : .gray)
                    
                    // Day label
                    Text(dayAbbreviation(date))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 8)
    }
    
    private func calculateBarHeight(count: Int) -> CGFloat {
        guard maxValue > 0 else { return 0 }
        let percentage = Double(count) / Double(maxValue)
        return CGFloat(percentage) * 130 + 20 // Min height 20, max 150
    }
    
    private func dayAbbreviation(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEE"
        let day = formatter.string(from: date)
        return String(day.prefix(2)).capitalized
    }
}

struct StatsCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    StatsView()
        .environmentObject(GoalManager())
}
