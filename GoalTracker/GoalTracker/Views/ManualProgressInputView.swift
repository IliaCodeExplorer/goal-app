//
//  ManualProgressInputView.swift
//  GoalTracker
//
//  Created by Ilyas on 11/17/25.
//

import SwiftUI

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

#Preview {
    ManualProgressInputView(goal: Goal(
        title: "Отжимания",
        frequency: .daily,
        trackingType: .numeric,
        targetValue: 50,
        currentValue: 25,
        icon: "figure.strengthtraining.traditional"
    ))
    .environmentObject(GoalManager())
}
