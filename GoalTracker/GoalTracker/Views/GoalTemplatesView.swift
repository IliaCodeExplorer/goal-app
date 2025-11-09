//
//  GoalTemplatesView.swift
//  GoalTracker
//
//  Created by Ilyas on 11/5/25.
//

import SwiftUI

struct GoalTemplatesView: View {
    @EnvironmentObject var goalManager: GoalManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: GoalCategory?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)
                        
                        Text("Библиотека целей")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Выберите готовые цели из категорий")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Categories
                    ForEach(GoalCategory.allCases, id: \.self) { category in
                        CategorySectionView(
                            category: category,
                            isExpanded: selectedCategory == category,
                            onTap: {
                                withAnimation {
                                    if selectedCategory == category {
                                        selectedCategory = nil
                                    } else {
                                        selectedCategory = category
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Шаблоны целей")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CategorySectionView: View {
    @EnvironmentObject var goalManager: GoalManager
    @Environment(\.dismiss) var dismiss
    let category: GoalCategory
    let isExpanded: Bool
    let onTap: () -> Void
    
    var templates: [GoalTemplate] {
        GoalTemplateManager.shared.templates(for: category)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Category Header
            Button(action: onTap) {
                HStack {
                    Image(systemName: category.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(
                            LinearGradient(
                                colors: [categoryColor, categoryColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.rawValue)
                            .font(.headline)
                        
                        Text("\(templates.count) целей")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Templates List
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(templates) { template in
                        TemplateRowView(template: template) {
                            // Проверка на дубликат - ИСПРАВЛЕНО
                            let isDuplicate = goalManager.goals.contains { existingGoal in
                                existingGoal.title.lowercased() == template.title.lowercased()
                            }
                            
                            if isDuplicate {
                                // Можно показать alert или просто пропустить
                                return
                            }
                            
                            // Создаем цель из шаблона
                            let newGoal = Goal(
                                title: template.title,
                                description: template.description,
                                frequency: template.frequency,
                                trackingType: template.trackingType,
                                difficulty: template.difficulty,
                                targetValue: template.targetValue,
                                icon: template.icon,
                                isRepeating: true
                            )
                            goalManager.addGoal(newGoal)
                            dismiss()
                        }
                    }
                }
                .padding(.top, 12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal)
    }
    
    private var categoryColor: Color {
        switch category {
        case .muslim: return .indigo
        case .fitness: return .red
        case .business: return .blue
        case .achiever: return .orange
        case .family: return .pink
        case .health: return .green
        case .learning: return .purple
        }
    }
}

struct TemplateRowView: View {
    let template: GoalTemplate
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: template.icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(template.frequency.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(template.trackingType.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if template.trackingType == .numeric {
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Text("Цель: \(Int(template.targetValue))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    GoalTemplatesView()
        .environmentObject(GoalManager())
}
