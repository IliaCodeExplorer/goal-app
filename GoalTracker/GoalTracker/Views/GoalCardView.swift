import SwiftUI

// v0.1.5 - Unified +/- System for ALL goal types
struct GoalCardView: View {
    @EnvironmentObject var goalManager: GoalManager
    let goal: Goal
    @State private var showingMenu = false
    @State private var showingManualInput = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - Header
            HStack {
                Image(systemName: goal.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Text(goal.frequency.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(goal.difficulty.emoji + " " + goal.difficulty.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if goal.isRepeating {
                            Image(systemName: "repeat")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer()
                
                // Status indicator
                if goal.isCompleted {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                } else if goal.currentValue < 0 {
                    // Failed state (отрицательное значение = провал)
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
            }
            
            // MARK: - Progress Bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    if goal.trackingType == .numeric {
                        Button {
                            HapticManager.shared.impact()
                            showingManualInput = true
                        } label: {
                            HStack(spacing: 4) {
                                Text("\(formatValue(abs(goal.currentValue))) / \(formatValue(goal.targetValue))")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Image(systemName: "pencil.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Text(statusText)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(statusColor)
                    }
                    
                    Spacer()
                    
                    Text("\(Int(progressPercentage))%")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(progressColor)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 16)
                        
                        // Progress (green or red)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: progressGradient,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * CGFloat(progressPercentage / 100),
                                height: 16
                            )
                            .animation(.spring(response: 0.3), value: progressPercentage)
                        
                        // Border
                        if goal.isCompleted || goal.currentValue < 0 {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(goal.isCompleted ? Color.green : Color.red, lineWidth: 2)
                                .frame(height: 16)
                        }
                    }
                }
                .frame(height: 16)
            }

            // MARK: - Weekly Stats (для всех типов)
            if let stats = goal.weeklyStats {
                WeeklyStatsView(stats: stats,/* trackingType: goal.trackingType*/)
                    .padding(.top, 4)
            }
            // MARK: - Universal +/- Buttons
            HStack(spacing: 12) {
                // MINUS Button (Не выполнил)
                Button {
                    HapticManager.shared.impact(style: .medium)
                    handleMinusButton()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(canPressMinus ? .red : .gray)
                        
                        Text("Не сделал")
                            .font(.caption2)
                            .foregroundColor(canPressMinus ? .red : .gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(canPressMinus ? Color.red.opacity(0.1) : Color.gray.opacity(0.05))
                    .cornerRadius(10)
                }
                .disabled(!canPressMinus)
                
                // Current Value Display
                VStack(spacing: 4) {
                    if goal.trackingType == .numeric {
                        Button {
                            HapticManager.shared.impact()
                            showingManualInput = true
                        } label: {
                            VStack(spacing: 2) {
                                Text("\(formatValue(abs(goal.currentValue)))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(goal.currentValue < 0 ? .red : .primary)
                                
                                Text("Текущее")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        VStack(spacing: 2) {
                            Text(goal.currentValue < 0 ? "✗" : (goal.isCompleted ? "✓" : "—"))
                                .font(.title)
                                .foregroundColor(goal.currentValue < 0 ? .red : (goal.isCompleted ? .green : .gray))
                            
                            Text("Статус")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(10)
                
                // PLUS Button (Выполнил)
                Button {
                    HapticManager.shared.success()
                    handlePlusButton()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(canPressPlus ? .green : .gray)
                        
                        Text("Сделал")
                            .font(.caption2)
                            .foregroundColor(canPressPlus ? .green : .gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(canPressPlus ? Color.green.opacity(0.1) : Color.gray.opacity(0.05))
                    .cornerRadius(10)
                }
                .disabled(!canPressPlus)
                
                // Menu
                Menu {
                    Button {
                        HapticManager.shared.impact()
                        showingMenu = true
                    } label: {
                        Label("Редактировать", systemImage: "pencil")
                    }
                    
                    if goal.isCompleted || goal.currentValue != 0 {
                        Button {
                            HapticManager.shared.impact()
                            resetGoal()
                        } label: {
                            Label("Сбросить", systemImage: "arrow.counterclockwise")
                        }
                    }
                    
                    Button(role: .destructive) {
                        HapticManager.shared.warning()
                        goalManager.deleteGoal(goal)
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding(8)
                }
            }
        }
        .padding()
        .background(cardBackground)
        .cornerRadius(16)
        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 2)
        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: 2)
        )
        .sheet(isPresented: $showingManualInput) {
            ManualProgressInputView(goal: goal)
        }
        .sheet(isPresented: $showingMenu) {
            GoalFormView(mode: .edit(goal))
        }
    }
    
    // MARK: - Logic
    
    private func handlePlusButton() {
        if goal.trackingType == .numeric {
            // Для numeric: +1 к значению
            goalManager.incrementGoalProgress(goalId: goal.id, by: 1)
        } else {
            // Для binary/habit: пометить как выполнено
            goalManager.updateGoalProgress(goalId: goal.id, value: goal.targetValue)
        }
    }
    
    private func handleMinusButton() {
        if goal.trackingType == .numeric {
            // Для numeric: открыть ручной ввод или -1
            if goal.currentValue > 0 {
                goalManager.decrementGoalProgress(goalId: goal.id, by: 1)
            }
        } else {
            // Для binary/habit: пометить как провалено (отрицательное значение)
            applyFailurePenalty()
        }
    }
    
    private func applyFailurePenalty() {
        // Штрафы
        let coinPenalty = goal.difficulty.penaltyAmount
        goalManager.userProfile.coins = max(0, goalManager.userProfile.coins - coinPenalty)
        
        let statPenalty = goal.difficulty.statPenalty
        goalManager.userProfile.characterStats.updateStat(for: .discipline, change: -statPenalty)
        
        // Пометить как провал (отрицательное значение)
        goalManager.updateGoalProgress(goalId: goal.id, value: -1)
        goalManager.saveProfile()
    }
    
    private func resetGoal() {
        goalManager.updateGoalProgress(goalId: goal.id, value: 0)
    }
    
    // MARK: - Computed Properties
    
    private var canPressPlus: Bool {
        // Можно нажать плюс если цель не выполнена
        return !goal.isCompleted && goal.currentValue >= 0
    }
    
    private var canPressMinus: Bool {
        // Можно нажать минус если:
        // 1. Для numeric: есть что уменьшать
        // 2. Для binary/habit: ещё не отмечено как провал
        if goal.trackingType == .numeric {
            return goal.currentValue > 0
        } else {
            return goal.currentValue >= 0
        }
    }
    
    private var progressPercentage: Double {
        if goal.currentValue < 0 {
            return 100 // Полная красная полоса для провала
        }
        guard goal.targetValue > 0 else { return 0 }
        return min((abs(goal.currentValue) / goal.targetValue) * 100, 100)
    }
    
    private var statusText: String {
        if goal.currentValue < 0 {
            return "Не выполнено"
        } else if goal.isCompleted {
            return "Завершено"
        } else {
            return "В процессе"
        }
    }
    
    private var statusColor: Color {
        if goal.currentValue < 0 {
            return .red
        } else if goal.isCompleted {
            return .green
        } else {
            return .secondary
        }
    }
    
    private var progressColor: Color {
        if goal.currentValue < 0 {
            return .red
        } else if goal.isCompleted {
            return .green
        } else if progressPercentage >= 50 {
            return .orange
        } else {
            return .blue
        }
    }
    
    private var progressGradient: [Color] {
        if goal.currentValue < 0 {
            return [Color.red, Color.red.opacity(0.7)]
        } else if goal.isCompleted {
            return [Color.green, Color.green.opacity(0.7)]
        } else {
            return [progressColor, progressColor.opacity(0.7)]
        }
    }
    
    private var cardBackground: LinearGradient {
        if goal.currentValue < 0 {
            return LinearGradient(
                colors: [Color.red.opacity(0.1), Color.red.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if goal.isCompleted {
            return LinearGradient(
                colors: [Color.green.opacity(0.1), Color.green.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            // Обычная карточка - чуть светлее чем фон
            return LinearGradient(
                colors: [
                    Color(.systemGray6).opacity(0.5),
                    Color(.systemGray6).opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var shadowColor: Color {
        if goal.currentValue < 0 {
            return Color.red.opacity(0.3)
        } else if goal.isCompleted {
            return Color.green.opacity(0.3)
        } else {
            return Color.black.opacity(0.1)
        }
    }
    
    private var shadowRadius: CGFloat {
        (goal.isCompleted || goal.currentValue < 0) ? 8 : 5
    }
    
    private var borderColor: Color {
        if goal.currentValue < 0 {
            return Color.red.opacity(0.5)
        } else if goal.isCompleted {
            return Color.green.opacity(0.5)
        } else {
            return Color.gray.opacity(0.15)  // ← ТОНКАЯ СЕРАЯ ГРАНИЦА
        }
    }
    
    private func formatValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        } else {
            return String(format: "%.1f", value)
        }
    }
}

// MARK: - Manual Input (для numeric целей)
struct ManualProgressInputView: View {
    @EnvironmentObject var goalManager: GoalManager
    @Environment(\.dismiss) var dismiss
    let goal: Goal
    @State private var inputValue: String
    @FocusState private var isInputFocused: Bool
    
    init(goal: Goal) {
        self.goal = goal
        _inputValue = State(initialValue: String(Int(abs(goal.currentValue))))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: goal.icon)
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text(goal.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Цель: \(formatValue(goal.targetValue))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Введите значение")
                        .font(.headline)
                    
                    TextField("Значение", text: $inputValue)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .focused($isInputFocused)
                }
                .padding(.horizontal)
                
                // Quick buttons
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach([1, 5, 10, 50, 100], id: \.self) { increment in
                        Button {
                            HapticManager.shared.impact()
                            let current = Double(inputValue) ?? 0
                            inputValue = String(Int(current + Double(increment)))
                        } label: {
                            Text("+\(increment)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
                
                Button {
                    if let value = Double(inputValue), value >= 0 {
                        HapticManager.shared.success()
                        goalManager.updateGoalProgress(goalId: goal.id, value: min(value, goal.targetValue))
                        dismiss()
                    }
                } label: {
                    Text("Сохранить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Обновить")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
            }
            .onAppear {
                isInputFocused = true
            }
        }
    }
    
    private func formatValue(_ value: Double) -> String {
        String(Int(value))
    }
}

// MARK: - Difficulty Penalties
extension Difficulty {
    var penaltyAmount: Int {
        switch self {
        case .easy: return 5
        case .medium: return 15
        case .hard: return 30
        case .epic: return 50
        }
    }
    
    var statPenalty: Int {
        switch self {
        case .easy: return 2
        case .medium: return 5
        case .hard: return 10
        case .epic: return 15
        }
    }
}
        // MARK: - Weekly Stats View
// MARK: - Weekly Stats View
struct WeeklyStatsView: View {
    let stats: WeeklyStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Average line
            HStack(spacing: 6) {
                Image(systemName: "chart.bar.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text("За неделю:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if stats.trackingType == .numeric {
                    Text("\(String(format: "%.1f", stats.averageValue)) / \(String(format: "%.0f", stats.totalTarget / 7))")
                        .font(.caption)
                        .fontWeight(.semibold)
                } else {
                    Text("\(Int(stats.successRate))% дней")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                Text("(\(Int(stats.averagePercentage))%)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(performanceColor)
                
                Image(systemName: stats.trend.icon)
                    .font(.caption)
                    .foregroundColor(stats.trend.color)
                
                Spacer()
            }
            
            // Mini chart
            HStack(spacing: 4) {
                ForEach(stats.dailyValues) { day in
                    VStack(spacing: 2) {
                        if stats.trackingType == .numeric {
                            // Для numeric - bar chart (СТОЛБИКИ)
                            GeometryReader { geometry in
                                VStack {
                                    Spacer()
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(barColor(for: day.percentage))
                                        .frame(height: geometry.size.height * CGFloat(day.percentage / 100))
                                }
                            }
                        } else {
                            // Для binary/habit - checkmarks (ГАЛОЧКИ)
                            ZStack {
                                Circle()
                                    .fill(day.percentage >= 100 ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                                    .frame(width: 30, height: 30)
                                
                                if day.percentage >= 100 {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.green)
                                } else {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        // Day label
                        Text(day.dayName)
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: stats.trackingType == .numeric ? 40 : 50)
        }
        .padding(8)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(8)
    }
    
    private var performanceColor: Color {
        if stats.averagePercentage >= 80 {
            return .green
        } else if stats.averagePercentage >= 50 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func barColor(for percentage: Double) -> Color {
        if percentage >= 100 {
            return .green
        } else if percentage >= 80 {
            return .blue
        } else if percentage >= 50 {
            return .orange
        } else {
            return .red
        }
    }
}
        #Preview {
            GoalCardView(goal: Goal(
                title: "Медитация",
                description: "Медитировать каждый день",
                frequency: .daily,
                trackingType: .binary,
                difficulty: .medium,
                targetValue: 1,
                icon: "brain.head.profile"
            ))
            .environmentObject(GoalManager())
            .padding()
        }


