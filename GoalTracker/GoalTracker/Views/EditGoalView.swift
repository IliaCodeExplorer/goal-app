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
            ZStack(alignment: .bottom) {
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
                        .pickerStyle(.segmented)
                        
                        HStack {
                            Text("Награда:")
                                .foregroundColor(.secondary)
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.yellow)
                                Text("\(selectedDifficulty.coinMultiplier)")
                                    .fontWeight(.bold)
                            }
                        }
                        .font(.subheadline)
                    }
                    
                    Section("Частота") {
                        Picker("Как часто?", selection: $selectedFrequency) {
                            ForEach(Frequency.allCases, id: \.self) { frequency in
                                Text(frequency.rawValue).tag(frequency)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        Toggle("Повторять автоматически", isOn: $isRepeating)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                        
                        if isRepeating {
                            Text("Цель будет сбрасываться после завершения каждого периода")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Section("Тип отслеживания") {
                        Picker("Тип", selection: $selectedTrackingType) {
                            ForEach(TrackingType.allCases, id: \.self) { type in
                                HStack {
                                    Image(systemName: type.icon)
                                    Text(type.rawValue)
                                }
                                .tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        if selectedTrackingType == .binary {
                            Text("Да/Нет отслеживание - Завершено или не завершено")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Целевое значение")
                                    .font(.subheadline)
                                
                                TextField("Введите число", text: $targetValue)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                    .onChange(of: targetValue) { oldValue, newValue in
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
                    }
                    
                    Section {
                        Color.clear
                            .frame(height: 80)
                    }
                    .listRowBackground(Color.clear)
                }
                
                // Фиксированная кнопка внизу
                VStack {
                    Button {
                        saveGoal()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Сохранить изменения")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(isFormValid ? Color.blue : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid)
                    .padding()
                    .background(
                        Rectangle()
                            .fill(Color(UIColor.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                    )
                }
            }
            .navigationTitle("Редактировать цель")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                IconPicker(selectedIcon: $selectedIcon)
            }
        }
    }
    
    private var isFormValid: Bool {
        if title.isEmpty {
            return false
        }
        
        if selectedTrackingType == .numeric || selectedTrackingType == .habit {
            let filtered = targetValue.filter { $0.isNumber || $0 == "." }
            guard let value = Double(filtered), value > 0 else {
                return false
            }
        }
        
        return true
    }
    
    private func saveGoal() {
        let target: Double
        
        if selectedTrackingType == .binary {
            target = 1.0
        } else {
            let filtered = targetValue.filter { $0.isNumber || $0 == "." }
            target = Double(filtered) ?? 0
        }
        
        guard target > 0 else { return }
        
        var updatedGoal = goal
        updatedGoal.title = title
        updatedGoal.description = description
        updatedGoal.frequency = selectedFrequency
        updatedGoal.trackingType = selectedTrackingType
        updatedGoal.difficulty = selectedDifficulty
        updatedGoal.targetValue = target
        updatedGoal.icon = selectedIcon
        updatedGoal.isRepeating = isRepeating
        
        goalManager.updateGoal(updatedGoal)
        dismiss()
    }
}

#Preview {
    EditGoalView(goal: Goal(
        title: "Тестовая цель",
        frequency: .daily,
        trackingType: .numeric,
        difficulty: .medium,
        targetValue: 10
    ))
    .environmentObject(GoalManager())
}
