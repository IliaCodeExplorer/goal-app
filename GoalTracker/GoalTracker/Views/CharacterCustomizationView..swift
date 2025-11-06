//
//  CharacterCustomizationView..swift
//  GoalTracker
//
//  Created by Ilyas on 11/5/25.
//

import SwiftUI

struct CharacterCustomizationView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🚧 В разработке")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    Text("Скоро здесь будет полная кастомизация персонажа!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Что будет доступно:")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        FeatureRow(icon: "tshirt.fill", title: "Одежда", description: "Разблокируй крутые наряды")
                        FeatureRow(icon: "eyeglasses", title: "Аксессуары", description: "Очки, часы, наушники")
                        FeatureRow(icon: "sparkles", title: "Эффекты", description: "Аура огня, мудрости")
                        FeatureRow(icon: "paintpalette.fill", title: "Цвета", description: "Измени цвет персонажа")
                    }
                }
                .padding()
            }
            .navigationTitle("Кастомизация")
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

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.purple)
                .frame(width: 40, height: 40)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        .padding(.horizontal)
    }
}

#Preview {
    CharacterCustomizationView()
}
