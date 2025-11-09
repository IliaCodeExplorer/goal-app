import SwiftUI

struct AddGoalView: View {
    @EnvironmentObject var goalManager: GoalManager
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedFrequency: Frequency = .daily
    @State private var selectedTrackingType: TrackingType = .numeric
    @State private var targetValue: String = ""
    @State private var selectedIcon: String = "target"
    @State private var showingIconPicker = false
    @State private var isRepeating: Bool = false
    
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
                    }
                    
                    // Добавляем пространство для кнопки
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
                            Text("Создать цель")
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
            .navigationTitle("Новая цель")
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
            // Проверяем что targetValue содержит корректное число
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
        
        // Дополнительная проверка перед сохранением
        guard target > 0 else {
            return
        }
        
        let newGoal = Goal(
            title: title,
            description: description,
            frequency: selectedFrequency,
            trackingType: selectedTrackingType,
            targetValue: target,
            icon: selectedIcon,
            isRepeating: isRepeating
        )
        
        goalManager.addGoal(newGoal)
        dismiss()
    }
}

#Preview {
    AddGoalView()
        .environmentObject(GoalManager())
}
