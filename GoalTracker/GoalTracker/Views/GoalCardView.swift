import SwiftUI

struct GoalCardView: View {
    @EnvironmentObject var goalManager: GoalManager
    let goal: Goal
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: goal.icon)
                    .font(.title2)
                    .foregroundColor(difficultyColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(goal.frequency.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(goal.difficulty.emoji)
                    .font(.title3)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [difficultyColor, difficultyColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * CGFloat(goal.progressPercentage / 100),
                            height: 12
                        )
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: goal.currentValue)
                }
            }
            .frame(height: 12)
            
            // Progress Text and Controls
            HStack {
                // Progress Label
                if goal.trackingType == .binary {
                    if goal.isCompleted {
                        Text("✅ Выполнено")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    } else if goal.currentValue < 0 {
                        Text("❌ Провалено")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    } else {
                        Text("⏳ В ожидании")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("\(Int(goal.currentValue)) / \(Int(goal.targetValue))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("(\(Int(goal.progressPercentage))%)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Control Buttons - ВСЕ типы целей имеют + и -
                if goal.trackingType == .binary {
                    // Для бинарных целей
                    if goal.isCompleted || goal.currentValue < 0 {
                        // Показываем статус
                        HStack(spacing: 6) {
                            Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.title2)
                            Text(goal.isCompleted ? "Выполнено" : "Провалено")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(goal.isCompleted ? .green : .red)
                    } else {
                        // Кнопки выбора
                        HStack(spacing: 16) {
                            // Fail Button (Провал)
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    goalManager.updateGoalProgress(goalId: goal.id, value: -1)
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title)
                                    Text("Нет")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(width: 70, height: 60)
                                .background(Color.red)
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Success Button (Выполнено)
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    goalManager.updateGoalProgress(goalId: goal.id, value: goal.targetValue)
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title)
                                    Text("Да")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(width: 70, height: 60)
                                .background(Color.green)
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                } else {
                    // Для числовых целей - кнопки + и -
                    if !goal.isCompleted {
                        HStack(spacing: 12) {
                            // Minus Button
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    goalManager.decrementGoalProgress(goalId: goal.id)
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Plus Button
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    goalManager.incrementGoalProgress(goalId: goal.id)
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.green)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    } else {
                        // Checkmark for completed numeric goals
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                            Text("Готово")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.green)
                    }
                }
            }
            
            // Rewards Info
            if !goal.isCompleted {
                HStack(spacing: 16) {
                    Label("\(goal.coinReward)", systemImage: "dollarsign.circle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Label("\(goal.coinReward * 2) XP", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(goal.isCompleted ? Color.green.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            GoalDetailView(goal: goal)
        }
    }
    
    private var difficultyColor: Color {
        switch goal.difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        case .epic: return .purple
        }
    }
}

// MARK: - Goal Detail View
struct GoalDetailView: View {
    @EnvironmentObject var goalManager: GoalManager
    @Environment(\.dismiss) var dismiss
    let goal: Goal
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Goal Icon and Title
                    HStack {
                        Image(systemName: goal.icon)
                            .font(.system(size: 50))
                            .foregroundColor(difficultyColor)
                        
                        VStack(alignment: .leading) {
                            Text(goal.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(goal.difficulty.rawValue)
                                .font(.subheadline)
                                .foregroundColor(difficultyColor)
                        }
                    }
                    .padding()
                    
                    // Description
                    if !goal.description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Описание")
                                .font(.headline)
                            Text(goal.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Progress
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Прогресс")
                            .font(.headline)
                        
                        HStack {
                            Text("\(Int(goal.currentValue))")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(difficultyColor)
                            
                            Text("/ \(Int(goal.targetValue))")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: goal.progressPercentage, total: 100)
                            .tint(difficultyColor)
                            .scaleEffect(y: 2)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Statistics
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Статистика")
                            .font(.headline)
                        
                        HStack(spacing: 20) {
                            StatItemView(title: "Частота", value: goal.frequency.rawValue, icon: "calendar")
                            StatItemView(title: "Награда", value: "\(goal.coinReward)", icon: "dollarsign.circle.fill")
                            StatItemView(title: "Опыт", value: "\(goal.coinReward * 2)", icon: "star.fill")
                        }
                        
                        if !goal.completionHistory.isEmpty {
                            Divider()
                            HStack {
                                Text("Выполнено раз:")
                                Spacer()
                                Text("\(goal.completionHistory.count)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Delete Button
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Удалить цель", systemImage: "trash.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Детали цели")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .alert("Удалить цель?", isPresented: $showingDeleteAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Удалить", role: .destructive) {
                    goalManager.deleteGoal(goal)
                    dismiss()
                }
            } message: {
                Text("Это действие нельзя отменить")
            }
        }
    }
    
    private var difficultyColor: Color {
        switch goal.difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        case .epic: return .purple
        }
    }
}

// MARK: - Stat Item View
struct StatItemView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    GoalCardView(goal: Goal(
        title: "Читать 30 минут",
        description: "Читать книги каждый день",
        frequency: .daily,
        trackingType: .numeric,
        difficulty: .medium,
        targetValue: 30,
        currentValue: 15,
        icon: "book.fill"
    ))
    .environmentObject(GoalManager())
    .padding()
}
