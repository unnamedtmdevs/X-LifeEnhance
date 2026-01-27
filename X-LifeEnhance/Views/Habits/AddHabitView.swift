//
//  AddHabitView.swift
//  X-LifeEnhance
//
//  Created by Simon Bakhanets on 27.01.2026.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: HabitViewModel
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedFrequency = HabitFrequency.daily
    @State private var enableReminder = false
    @State private var reminderTime = Date()
    
    let icons = ["star.fill", "heart.fill", "bolt.fill", "flame.fill", "moon.fill", "sun.max.fill", "cloud.fill", "leaf.fill", "book.fill", "figure.run", "brain.head.profile", "fork.knife", "cup.and.saucer.fill", "pencil", "paintbrush.fill", "music.note", "camera.fill", "headphones"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Name field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Habit Name")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.subheadline)
                            
                            TextField("e.g., Morning Meditation", text: $name)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        // Description field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.subheadline)
                            
                            TextField("e.g., 10 minutes of mindfulness", text: $description)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        // Icon selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Icon")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.subheadline)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 12) {
                                ForEach(icons, id: \.self) { icon in
                                    Button(action: { selectedIcon = icon }) {
                                        ZStack {
                                            Circle()
                                                .fill(selectedIcon == icon ? Color.appPrimary : Color.white.opacity(0.1))
                                                .frame(width: 50, height: 50)
                                            
                                            Image(systemName: icon)
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Frequency picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Frequency")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.subheadline)
                            
                            Picker("Frequency", selection: $selectedFrequency) {
                                ForEach(HabitFrequency.allCases, id: \.self) { frequency in
                                    Text(frequency.rawValue).tag(frequency)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        // Reminder toggle
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle(isOn: $enableReminder) {
                                Text("Enable Reminder")
                                    .foregroundColor(.white)
                            }
                            .tint(.appPrimary)
                            
                            if enableReminder {
                                DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .labelsHidden()
                                    .colorScheme(.dark)
                            }
                        }
                        
                        // Add button
                        Button(action: addHabit) {
                            Text("Add Habit")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.appPrimary, .appSecondary]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.5 : 1)
                    }
                    .padding()
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.appPrimary)
                }
            }
        }
    }
    
    private func addHabit() {
        let habit = Habit(
            name: name,
            description: description,
            icon: selectedIcon,
            color: "Blue",
            frequency: selectedFrequency,
            reminderTime: enableReminder ? reminderTime : nil
        )
        viewModel.addHabit(habit)
        presentationMode.wrappedValue.dismiss()
    }
}
