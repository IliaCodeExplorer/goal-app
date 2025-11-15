import SwiftUI
import Foundation

// v0.1.3 - Fixed Icon Button + Haptics + Binary/Habit creation
struct GoalFormView: View {
    @EnvironmentObject var goalManager: GoalManager
    @Environment(\.dismiss) var dismiss
    
    let mode: FormMode
    
    @State private var title: String
    @State private var description: String
    @State private var selectedFrequency: Frequency
    @State private var selectedTrackingType: TrackingType
    @State private var selectedDifficulty: Difficulty
    @State private var targetValue: String
    @State private var selectedIcon: String
    @State private var showingIconPicker = false
    @State private var isRepeating: Bool
    
    enum FormMode {
        case create
        case edit(Goal)
        
        var title: String {
            switch self {
            case .create: return "Новая цель"
            case .edit: return "Редактировать цель"
            }
        }
        
        var buttonText: String {
            switch self {
            case .create: return "Создать цель"
            case .edit: return "Сохранить изменения"
            }
        }
    }
    
    init(mode: FormMode) {
        self.mode = mode
        
        switch mode {
        case .create:
            _title = State(initialValue: "")
            _description = State(initialValue: "")
            _selectedFrequency = State(initialValue: .daily)
            _selectedTrackingType = State(initialValue: .numeric)
            _selectedDifficulty = State(initialValue: .medium)
            _targetValue = State(initialValue: "")
            _selectedIcon = State(initialValue: "target")
            _isRepeating = State(initialValue: false)
            
        case .edit(let goal):
            _title = State(initialValue: goal.title)
            _description = State(initialValue: goal.description)
            _selectedFrequency = State(initialValue: goal.frequency)
            _selectedTrackingType = State(initialValue: goal.trackingType)
            _selectedDifficulty = State(initialValue: goal.difficulty)
            _targetValue = State(initialValue: String(Int(goal.targetValue)))
            _selectedIcon = State(initialValue: goal.icon)
            _isRepeating = State(initialValue: goal.isRepeating)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Form {
                    // MARK: - Goal Details Section
                    Section {
                        HStack(spacing: 12) {
                            Button {
                                HapticManager.shared.impact()
                                showingIconPicker = true
                            } label: {
                                Image(systemName: selectedIcon)
                                    .font(.title)
                                    .foregroundColor(.blue)
                                    .frame(width: 50, height: 50)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                TextField("Название цели", text: $title)
                                    .font(.body)
                                
                                Text("Нажмите на иконку слева")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        TextField("Описание (необязательно)", text: $description, axis: .vertical)
                            .lineLimit(3...6)
                            .font(.body)
                    } header: {
                        Text("Детали цели")
                    }
                    
                    // MARK: - Difficulty Section
                    Section {
                        VStack(spacing: 16) {
                            ForEach(Difficulty.allCases, id: \.self) { difficulty in
                                DifficultyOptionView(
                                    difficulty: difficulty,
                                    isSelected: selectedDifficulty == difficulty
                                ) {
                                    HapticManager.shared.impact()
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedDifficulty = difficulty
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("Сложность")
                    } footer: {
                        Text("Влияет на награды: \(selectedDifficulty.coinMultiplier) монет за выполнение")
                            .font(.caption)
                    }
                    
                    // MARK: - Frequency Section
                    Section {
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
                    } header: {
                        Text("Частота")
                    }
                    
                    // MARK: - Tracking Type Section
                    Section {
                        ForEach(TrackingType.allCases, id: \.self) { type in
                            Button {
                                HapticManager.shared.selection()
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTrackingType = type
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: type.icon)
                                        .font(.title3)
                                        .foregroundColor(selectedTrackingType == type ? .blue : .gray)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(type.rawValue)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        Text(type.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedTrackingType == type {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.title3)
                                    }
                                }
                                .contentShape(Rectangle())
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Целевое значение для Numeric
                        if selectedTrackingType == .numeric {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Целевое значение")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextField("Введите число", text: $targetValue)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                                    .onChange(of: targetValue) { oldValue, newValue in
                                        let filtered = newValue.filter { $0.isNumber }
                                        if filtered != newValue {
                                            targetValue = filtered
                                        }
                                    }
                                
                                Text("Только числа. Например: 8, 10, 100, 10000")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } header: {
                        Text("Тип отслеживания")
                    }
                    
                    Section {
                        Color.clear
                            .frame(height: 80)
                    }
                    .listRowBackground(Color.clear)
                }
                
                // MARK: - Action Button
                VStack {
                    Button {
                        HapticManager.shared.impact(style: .medium)
                        saveGoal()
                    } label: {
                        HStack {
                            Spacer()
                            Text(mode.buttonText)
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
            .navigationTitle(mode.title)
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
        
        if selectedTrackingType == .numeric {
            let filtered = targetValue.filter { $0.isNumber }
            guard let value = Double(filtered), value > 0 else {
                return false
            }
        }
        
        return true
    }
    
    private func saveGoal() {
        let target: Double
        
        // FIX: Binary и Habit тоже должны создаваться
        if selectedTrackingType == .binary || selectedTrackingType == .habit {
            target = 1.0
        } else {
            let filtered = targetValue.filter { $0.isNumber }
            guard let value = Double(filtered), value > 0 else {
                HapticManager.shared.error()
                return
            }
            target = value
        }
        
        switch mode {
        case .create:
            let newGoal = Goal(
                title: title,
                description: description,
                frequency: selectedFrequency,
                trackingType: selectedTrackingType,
                difficulty: selectedDifficulty,
                targetValue: target,
                icon: selectedIcon,
                isRepeating: isRepeating
            )
            goalManager.addGoal(newGoal)
            HapticManager.shared.success()
            
        case .edit(let existingGoal):
            var updatedGoal = existingGoal
            updatedGoal.title = title
            updatedGoal.description = description
            updatedGoal.frequency = selectedFrequency
            updatedGoal.trackingType = selectedTrackingType
            updatedGoal.difficulty = selectedDifficulty
            updatedGoal.targetValue = target
            updatedGoal.icon = selectedIcon
            updatedGoal.isRepeating = isRepeating
            goalManager.updateGoal(updatedGoal)
            HapticManager.shared.success()
        }
        
        dismiss()
    }
}

// MARK: - Difficulty Option View
struct DifficultyOptionView: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(difficulty.emoji)
                    .font(.system(size: 32))
                    .frame(width: 50, height: 50)
                    .background(isSelected ? difficultyColor.opacity(0.2) : Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(difficulty.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        
                        Text("+\(difficulty.coinMultiplier) монет")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(difficultyColor)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(difficultyColor)
                }
            }
            .padding()
            .background(isSelected ? difficultyColor.opacity(0.1) : Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? difficultyColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var difficultyColor: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        case .epic: return .purple
        }
    }
}

#Preview {
    GoalFormView(mode: .create)
        .environmentObject(GoalManager())
}
