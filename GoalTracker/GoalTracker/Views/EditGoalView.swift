import SwiftUI

struct EditGoalView: View {
    @EnvironmentObject var goalManager: GoalManager
    @Environment(\.dismiss) var dismiss
    
    let goal: Goal
    
    @State private var title: String
    @State private var description: String
    @State private var selectedFrequency: Frequency
    @State private var selectedTrackingType: TrackingType
    @State private var selectedDifficulty: Difficulty
    @State private var targetValue: String
    @State private var selectedIcon: String
    @State private var showingIconPicker = false
    @State private var isRepeating: Bool
    
    init(goal: Goal) {
        self.goal = goal
        _title = State(initialValue: goal.title)
        _description = State(initialValue: goal.description)
        _selectedFrequency = State(initialValue: goal.frequency)
        _selectedTrackingType = State(initialValue: goal.trackingType)
        _selectedDifficulty = State(initialValue: goal.difficulty)
        _targetValue = State(initialValue: String(Int(goal.targetValue)))
        _selectedIcon = State(initialValue: goal.icon)
        _isRepeating = State(initialValue: goal.isRepeating)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Детали цели") {
                    HStack {
                        Button {
                            showingIconPicker = true
                        } label: {
                            Image(systemName: selectedIcon)
                                .font(.title)
                                .foregroundColor(.blue)
                                .frame(width: 50, height: 50)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            TextField("Название цели", text: $title)
                                .font(.body)
                            
                            Text("Нажмите на иконку для выбора")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    TextField("Описание (необязательно)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                        .font(.body)
                }
                
                Section("Сложность") {
                    Picker("Уровень сложности", selection: $selectedDifficulty) {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            HStack {
                                Text(difficulty.emoji)
                                Text(difficulty.rawValue)
                            }
                            .tag(difficulty)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    HStack {
                        Text("Награда:")
                            .font(.subheadline)
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.yellow)
                            Text("\(selectedDifficulty.coinMultiplier)")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                    }
                }
                
                Section("Частота") {
                    Picker("Как часто?", selection: $selectedFrequency) {
                        ForEach(Frequency.allCases, id: \.self) { frequency in
                            Text(frequency.rawValue).tag(frequency)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Toggle("Повторять автоматически", isOn: $isRepeating)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    
                    if isRepeating {
                        Text("Цель будет сбрасываться после завершения каждого периода")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Тип отслеживания") {
                    ForEach(TrackingType.allCases, id: \.self) { type in
                        Button {
                            selectedTrackingType = type
                        } label: {
                            HStack {
                                Image(systemName: type.icon)
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                    .frame(width: 30)
                                
                                Text(type.rawValue)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedTrackingType == type {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .font(.body.weight(.semibold))
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Описание выбранного типа
                    VStack(alignment: .leading, spacing: 8) {
                        if selectedTrackingType == .binary {
                            Text("Да/Нет отслеживание - Завершено или не завершено")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else if selectedTrackingType == .habit {
                            Text("Привычка - Отмечайте каждый раз когда выполняете")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Целевое значение")
                                .font(.subheadline)
                            
                            TextField("Введите число", text: $targetValue)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: targetValue) { oldValue, newValue in
                                    // Фильтруем только числа и точку
                                    let filtered = newValue.filter { $0.isNumber || $0 == "." }
                                    if filtered != newValue {
                                        targetValue = filtered
                                    }
                                }
                            
                            Text("Только числа. Например: 8, 10, 100")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                
                Section("История") {
                    HStack {
                        Text("Текущий прогресс:")
                        Spacer()
                        Text("\(Int(goal.currentValue))/\(Int(goal.targetValue))")
                            .fontWeight(.bold)
                    }
                    
                    HStack {
                        Text("Всего завершений:")
                        Spacer()
                        Text("\(goal.completionHistory.count)")
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    if !goal.completionHistory.isEmpty {
                        Text("История сохранится при изменении цели")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Редактировать цель")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveGoal()
                    }
                    .disabled(!isFormValid)
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                IconPicker(selectedIcon: $selectedIcon)
            }
        }
    }
    
    private var isFormValid: Bool {
        if title.isEmpty { return false }
        
        if selectedTrackingType == .numeric {
            let filtered = targetValue.filter { $0.isNumber || $0 == "." }
            guard let value = Double(filtered), value > 0 else {
                return false
            }
        }
        
        return true
    }
    
    private func saveGoal() {
        var updatedGoal = goal
        
        updatedGoal.title = title
        updatedGoal.description = description
        updatedGoal.frequency = selectedFrequency
        updatedGoal.trackingType = selectedTrackingType
        updatedGoal.difficulty = selectedDifficulty
        updatedGoal.icon = selectedIcon
        updatedGoal.isRepeating = isRepeating
        
        if selectedTrackingType == .binary {
            updatedGoal.targetValue = 1.0
        } else {
            let filtered = targetValue.filter { $0.isNumber || $0 == "." }
            updatedGoal.targetValue = Double(filtered) ?? goal.targetValue
        }
        
        updatedGoal.completionHistory = goal.completionHistory
        updatedGoal.currentValue = goal.currentValue
        
        goalManager.updateGoal(updatedGoal)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
}
