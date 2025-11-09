import SwiftUI
import UIKit

// v2.5.2 - GoalCardView с Manual Input + Penalty System
// ИЗМЕНЕНИЯ:
// 1. Добавлен ручной ввод текущего значения для numeric целей
// 2. Реализована penalty система для кнопки "дизлайк"
// 3. Исправлен баг с отрицательными значениями (защита min=0)
// 4. Кнопка минус отключается при currentValue = 0

struct GoalCardView: View {
    @EnvironmentObject var goalManager: GoalManager
    let goal: Goal
    @State private var showingManualInput = false
    @State private var showingPenaltyAlert = false
    @State private var showingMenu = false
    @State private var dragOffset: CGFloat = 0
    
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
                
                if goal.isCompleted {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }
            }
            
            // MARK: - Progress Bar (with tap to input for numeric)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    if goal.trackingType == .numeric {
                        // НОВОЕ: Тап для ручного ввода
                        Button {
                            showingManualInput = true
                        } label: {
                            HStack(spacing: 4) {
                                Text("\(formatValue(goal.currentValue)) / \(formatValue(goal.targetValue))")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Image(systemName: "pencil.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Text(goal.isCompleted ? "Завершено" : "Не завершено")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    Text("\(Int(goal.progressPercentage))%")
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
                        
                        // Progress
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: goal.isCompleted ?
                                        [Color.green, Color.green.opacity(0.7)] :
                                        [progressColor, progressColor.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * CGFloat(goal.progressPercentage / 100),
                                height: 16
                            )
                            .animation(.spring(), value: goal.progressPercentage)
                        
                        // Highlight for completed goals
                        if goal.isCompleted {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.green, lineWidth: 2)
                                .frame(height: 16)
                        }
                    }
                }
                .frame(height: 16)
            }
            
            // MARK: - Action Buttons
            HStack(spacing: 12) {
                if goal.trackingType == .binary {
                    // Binary: Done / Reset button
                    Button {
                        goalManager.updateGoalProgress(
                            goalId: goal.id,
                            value: goal.currentValue >= goal.targetValue ? 0 : goal.targetValue
                        )
                    } label: {
                        HStack {
                            Image(systemName: goal.currentValue >= goal.targetValue ? "arrow.counterclockwise" : "checkmark.circle")
                            Text(goal.currentValue >= goal.targetValue ? "Сброс" : "Завершить")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(goal.currentValue >= goal.targetValue ? Color.orange : Color.green)
                        .cornerRadius(8)
                    }
                } else {
                    // Numeric: +/- buttons
                    HStack(spacing: 8) {
                        // MINUS Button (ИСПРАВЛЕН БАГ: disabled при нуле)
                        Button {
                            showingPenaltyAlert = true
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(goal.currentValue > 0 ? .red : .gray)
                        }
                        .disabled(goal.currentValue <= 0)
                        
                        // Manual Input Button
                        Button {
                            showingManualInput = true
                        } label: {
                            VStack(spacing: 4) {
                                Text("\(formatValue(goal.currentValue))")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Text("Ввести вручную")
                                    .font(.caption2)
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // PLUS Button
                        Button {
                            goalManager.incrementGoalProgress(goalId: goal.id, by: 1)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                // Menu button
                Menu {
                    Button {
                        // Edit goal - открываем GoalFormView в режиме edit
                        showingMenu = true
                    } label: {
                        Label("Редактировать", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        goalManager.deleteGoal(goal)
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(
            goal.isCompleted ?
                LinearGradient(colors: [Color.green.opacity(0.1), Color.green.opacity(0.05)],
                              startPoint: .topLeading, endPoint: .bottomTrailing) :
                LinearGradient(colors: [Color(.systemBackground), Color(.systemBackground)],
                              startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(16)
        .shadow(
            color: goal.isCompleted ? Color.green.opacity(0.3) : Color.black.opacity(0.1),
            radius: goal.isCompleted ? 8 : 5,
            x: 0,
            y: 2
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(goal.isCompleted ? Color.green.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        // MARK: - Sheets and Alerts
        .sheet(isPresented: $showingManualInput) {
            ManualProgressInputView(goal: goal)
        }
        .sheet(isPresented: $showingMenu) {
            GoalFormView(mode: .edit(goal))
        }
        .alert("Не выполнил цель?", isPresented: $showingPenaltyAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Да, получить штраф", role: .destructive) {
                applyPenalty()
            }
        } message: {
            Text("Штраф: -\(goal.difficulty.penaltyAmount) монет, -\(goal.difficulty.statPenalty) к статам персонажа")
        }
    }
    
    // MARK: - Penalty System
    private func applyPenalty() {
        // 1. Отнять монеты
        let coinPenalty = goal.difficulty.penaltyAmount
        goalManager.userProfile.coins = max(0, goalManager.userProfile.coins - coinPenalty)
        
        // 2. Уменьшить статы персонажа
        let statPenalty = goal.difficulty.statPenalty
        
        // Всегда бьет по дисциплине
        goalManager.userProfile.characterStats.updateStat(for: .discipline, change: -statPenalty)
        
        // Определяем какую еще характеристику понизить
        let title = goal.title.lowercased()
        let description = goal.description.lowercased()
        let combinedText = title + " " + description
        
        if combinedText.contains("спорт") || combinedText.contains("тренировка") || combinedText.contains("бег") {
            goalManager.userProfile.characterStats.updateStat(for: .physical, change: -statPenalty)
        } else if combinedText.contains("книга") || combinedText.contains("учить") || combinedText.contains("курс") {
            goalManager.userProfile.characterStats.updateStat(for: .mental, change: -statPenalty)
        } else if combinedText.contains("вода") || combinedText.contains("сон") || combinedText.contains("здоров") {
            goalManager.userProfile.characterStats.updateStat(for: .health, change: -statPenalty)
        } else if combinedText.contains("работа") || combinedText.contains("бизнес") || combinedText.contains("проект") {
            goalManager.userProfile.characterStats.updateStat(for: .career, change: -statPenalty)
        } else if combinedText.contains("семья") || combinedText.contains("друзья") || combinedText.contains("звонок") {
            goalManager.userProfile.characterStats.updateStat(for: .social, change: -statPenalty)
        }
        
        // 3. Визуальный эффект (уже есть haptic в updateGoalProgress)
        goalManager.decrementGoalProgress(goalId: goal.id, by: 1)
        
        // 4. Сохранить
        goalManager.saveProfile()
    }
    
    private var progressColor: Color {
        if goal.progressPercentage >= 100 {
            return .green
        } else if goal.progressPercentage >= 50 {
            return .orange
        } else {
            return .blue
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

// MARK: - Manual Progress Input View (NEW!)
struct ManualProgressInputView: View {
    @EnvironmentObject var goalManager: GoalManager
    @Environment(\.dismiss) var dismiss
    let goal: Goal
    @State private var inputValue: String
    @FocusState private var isInputFocused: Bool
    
    init(goal: Goal) {
        self.goal = goal
        _inputValue = State(initialValue: String(Int(goal.currentValue)))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Icon and title
                VStack(spacing: 8) {
                    Image(systemName: goal.icon)
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text(goal.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Текущее: \(formatValue(goal.currentValue)) / Цель: \(formatValue(goal.targetValue))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Input field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Введите текущее значение")
                        .font(.headline)
                    
                    TextField("Значение", text: $inputValue)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .focused($isInputFocused)
                        .onChange(of: inputValue) { oldValue, newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered != newValue {
                                inputValue = filtered
                            }
                        }
                }
                .padding(.horizontal)
                
                // Quick increment buttons
                VStack(spacing: 12) {
                    Text("Или добавить:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach([1, 5, 10, 50, 100, 500], id: \.self) { increment in
                            Button {
                                let current = Double(inputValue) ?? goal.currentValue
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
                }
                .padding(.horizontal)
                
                // Save button
                Button {
                    if let value = Double(inputValue), value >= 0 {
                        goalManager.updateGoalProgress(goalId: goal.id, value: min(value, goal.targetValue))
                        dismiss()
                    }
                } label: {
                    Text("Сохранить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValidInput ? Color.blue : Color.gray)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .disabled(!isValidInput)
                
                Spacer()
            }
            .navigationTitle("Обновить прогресс")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                isInputFocused = true
            }
        }
    }
    
    private var isValidInput: Bool {
        guard let value = Double(inputValue) else { return false }
        return value >= 0 && value <= goal.targetValue
    }
    
    private func formatValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        } else {
            return String(format: "%.1f", value)
        }
    }
}

// MARK: - Difficulty Extension (Penalty amounts)
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

#Preview {
    GoalCardView(goal: Goal(
        title: "Пройти 10,000 шагов",
        description: "Ходить больше каждый день",
        frequency: .daily,
        trackingType: .numeric,
        difficulty: .medium,
        targetValue: 10000,
        currentValue: 5000,
        icon: "figure.walk"
    ))
    .environmentObject(GoalManager())
    .padding()
}
