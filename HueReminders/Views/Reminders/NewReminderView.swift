//
//  NewReminderView.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-07-08.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct NewReminderView: View {
    @FetchRequest(fetchRequest: HueBridge.findActiveBridge()) var activeBridge: FetchedResults<HueBridge>
    
    private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        NewReminderViewContent(bridge: activeBridge.sorted().first!)
    }
}

struct NewReminderViewContent: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var viewModel: NewReminderViewModel

    var activeBridge: HueBridge
    
    private var cancellables = Set<AnyCancellable>()
    
    init(bridge: HueBridge) {
        activeBridge = bridge
        viewModel = NewReminderViewModel(lightsRequest: HueAPI.getLights(bridge: activeBridge))
        
        // Setup subscriber
        viewModel.isNameValid
            .combineLatest(viewModel.selectedLightPublisher)
            .map { $0.0 && $0.1 }
            .receive(on: RunLoop.main)
            .assign(to: \.valid, on: viewModel)
            .store(in: &cancellables)
    }
    
    func addPressed() {
        let newReminder = Reminder(context: managedObjectContext)
        newReminder.name = viewModel.name
        newReminder.color = Int16(viewModel.color)
        newReminder.day = Int16(viewModel.day)
        newReminder.time = viewModel.time
        newReminder.active = false
        newReminder.bridge = activeBridge
        newReminder.lightID = "\(viewModel.selectedLight)"
        
        let request = HueAPI.setSchedule(on: newReminder.bridge!, reminder: newReminder)
        URLSession.shared.dataTask(with: request).resume()
        
        try? managedObjectContext.save()
        self.presentation.wrappedValue.dismiss()
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $viewModel.name)
                    .autocapitalization(.none)
            }
            Section {
                // Swap for the color picker in iOS 14. Currently in beta
                Picker("Color", selection: $viewModel.color) {
                    ForEach(0 ..< ReminderColor.allCases.count) { index in
                        Text(ReminderColor.allCases[index].rawValue)
                    }
                }
            }
            Section {
                Picker("Day", selection: $viewModel.day) {
                    ForEach(0 ..< WeekDay.allCases.count) { index in
                        Text(WeekDay.allCases[index].rawValue)
                    }
                }
            }
            Section {
                DatePicker("Time", selection: $viewModel.time, displayedComponents: .hourAndMinute)
            }
            
            Section {
                Text("Light to blink").bold()
                ForEach(self.viewModel.lights) { light in
                    HStack {
                        Text("\(light.name)").onTapGesture {
                            self.viewModel.selectedLight = light.id
                        }
                        
                        Spacer()
                        
                        if light.id == self.viewModel.selectedLight {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            
            Section {
                Button(action: addPressed) {
                    Text("Add").bold()
                }.disabled(!viewModel.valid)
            }
        }.navigationBarTitle("New reminder")
    }
}

struct NewReminderView_Previews: PreviewProvider {
    static var previews: some View {
        NewReminderView()
    }
}
