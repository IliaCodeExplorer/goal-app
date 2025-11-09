import SwiftUI

struct GoalCardView: View {
    @EnvironmentObject var goalManager: GoalManager
    let goal: Goal
    @State private var showingUpdateSheet = false
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
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
            
            // Interactive Progress Bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(goal.trackingType == .numeric ?
                         "\(formatValue(goal.currentValue)) / \(formatValue(goal.targetValue))" :
                         "\(goal.isCompleted ? "Завершено" : "Не завершено")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
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
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if goal.trackingType == .numeric && !goal.isCompleted {
                                    isDragging = true
                                    let percentage = max(0, min(1, value.location.x / geometry.size.width))
                                    let newValue = percentage * goal.targetValue
                                    goalManager.updateGoalProgress(goalId: goal.id, value: newValue)
                                }
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
                }
                .frame(height: 16)
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                if goal.trackingType == .binary {
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
                    Button {
                        showingUpdateSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Обновить")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                }
                
                Menu {
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
        .sheet(isPresented: $showingUpdateSheet) {
            UpdateGoalProgressView(goal: goal)
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onChanged { value in
                    if value.translation.width > 50 && goal.trackingType == .numeric && !goal.isCompleted {
                        dragOffset = value.translation.width
                    }
                }
                .onEnded { value in
                    if value.translation.width > 100 && goal.trackingType == .numeric {
                        goalManager.incrementGoalProgress(goalId: goal.id, by: 1)
                    }
                    dragOffset = 0
                }
        )
        .offset(x: dragOffset * 0.3)
        .animation(.spring(), value: dragOffset)
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

struct UpdateGoalProgressView: View {
    @EnvironmentObject var goalManager: GoalManager
    @Environment(\.dismiss) var dismiss
    let goal: Goal
    @State private var inputValue: String = ""
    @FocusState private var isInputFocused: Bool
    
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
                    
                    Text("Текущее: \(formatValue(goal.currentValue)) / Цель: \(formatValue(goal.targetValue))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Введите новое значение")
                        .font(.headline)
                    
                    TextField("Значение", text: $inputValue)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .font(.title3)
                        .focused($isInputFocused)
                }
                .padding(.horizontal)
                
                // Quick buttons
                VStack(spacing: 12) {
                    Text("Или выберите:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        ForEach([1.0, 5.0, 10.0], id: \.self) { increment in
                            Button {
                                let newValue = goal.currentValue + increment
                                goalManager.updateGoalProgress(goalId: goal.id, value: newValue)
                                dismiss()
                            } label: {
                                Text("+\(Int(increment))")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Button {
                    // Разрешаем только числа и точку
                    let filtered = inputValue.filter { $0.isNumber || $0 == "." }
                    if let value = Double(filtered), value >= 0 {
                        goalManager.updateGoalProgress(goalId: goal.id, value: value)
                        dismiss()
                    }
                } label: {
                    Text("Обновить прогресс")
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
        let filtered = inputValue.filter { $0.isNumber || $0 == "." }
        return Double(filtered) != nil
    }
    
    private func formatValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        } else {
            return String(format: "%.1f", value)
        }
    }
}

#Preview {
    GoalCardView(goal: Goal(
        title: "Пить воду",
        description: "Оставаться гидратированным",
        frequency: .daily,
        trackingType: .numeric,
        targetValue: 8,
        currentValue: 5,
        icon: "drop.fill"
    ))
    .environmentObject(GoalManager())
    .padding()
}
