//
//  TrackingTypePicker..swift
//  GoalTracker
//
//  Created by Ilyas on 11/9/25.
//

import SwiftUI

struct TrackingTypePicker: View {
    @Binding var selectedType: TrackingType
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(TrackingType.allCases, id: \.self) { type in
                Button {
                    selectedType = type
                } label: {
                    HStack(spacing: 16) {
                        // Иконка
                        ZStack {
                            Circle()
                                .fill(selectedType == type ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: type.icon)
                                .font(.system(size: 20))
                                .foregroundColor(selectedType == type ? .blue : .gray)
                        }
                        
                        // Текст
                        VStack(alignment: .leading, spacing: 4) {
                            Text(type.rawValue)
                                .font(.system(size: 17))
                                .foregroundColor(.primary)
                            
                            Text(type.description)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Чекмарк
                        if selectedType == type {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                
                // Разделитель
                if type != TrackingType.allCases.last {
                    Divider()
                        .padding(.leading, 76)
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    TrackingTypePicker(selectedType: .constant(.numeric))
        .padding()
}
