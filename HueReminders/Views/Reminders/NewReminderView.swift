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
    @FetchRequest(fetchRequest: HueBridge.findAll()) var bridges: FetchedResults<HueBridge>
    
    private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        // BUG: Does not update to the active bridge
        NewReminderViewContent(bridges: bridges.sorted())
    }
}

struct NewReminderViewContent: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var viewModel: NewReminderViewModel

    var bridges: [HueBridge]
    
    private var interactor: AddReminderInteracting
    private var cancellables = Set<AnyCancellable>()
    
    init(bridges: [HueBridge]) {
        self.bridges = bridges
        viewModel = NewReminderViewModel()
        interactor = AddReminderInteractor()
        
        // Setup subscriber
        viewModel.isNameValid
            .combineLatest(viewModel.selectedLightPublisher)
            .map { $0.0 && $0.1 }
            .receive(on: RunLoop.main)
            .assign(to: \.valid, on: viewModel)
            .store(in: &cancellables)
    }
    
    func addPressed() {
        // TODO: Move code to interactor
        guard let bridge = viewModel.bridge else { return }
        let colorEnum = ReminderColor.allCases[viewModel.color]
        let color = colorEnum.getColor()
        print("Add color: \(colorEnum.rawValue) UIColor: \(color.getHueValues())")

        interactor.add(managedObjectContext: managedObjectContext,
                       name: viewModel.name,
                       color: color,
                       day: Int16(viewModel.day),
                       time: viewModel.time, bridge: bridge, lightIDs: viewModel.selectedLights) { success in
                        if success {
                            self.presentation.wrappedValue.dismiss()
                        }
        }
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
                Text("Hue Bridge")
                    .bold()
                
                if bridges.isEmpty {
                    EmptyView(text: "No connected bridge found. Go to setup to connect.")
                }
                
                ForEach(bridges) { bridge in
                    HStack {
                        Text("\(bridge.name ?? "")")
                        Spacer()
                        
                        if bridge.name == self.viewModel.bridge?.name {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .onTapGesture {
                        // TODO: Move code to interactor
                        guard self.viewModel.bridge != bridge else { return }
                        self.viewModel.selectedLights.removeAll()
                        self.viewModel.bridge = bridge
                        self.viewModel.fetchLights()
                    }
                }
            }
            
            if self.viewModel.bridge != nil {
                Section {
                    Text("Light to blink").bold()
                    
                    if self.viewModel.lights.isEmpty {
                        EmptyView(text: "No lights found for the selected bridge")
                    }

                    ForEach(self.viewModel.lights) { light in
                        HStack {
                            Text("\(light.name)")
                                .onTapGesture {
                                    // TODO: Move code to interactor
                                    if self.viewModel.selectedLights.contains(light.id) {
                                        self.viewModel.selectedLights.remove(light.id)
                                    } else {
                                        self.viewModel.selectedLights.insert(light.id)
                                    }
                            }
                            Spacer()
                            
                            if self.viewModel.selectedLights.contains(light.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
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
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let bridge = HueBridge(context: context)
        bridge.active = true
        bridge.address = "192.168.1.2"
        bridge.name = "Bridge"
        bridge.username = "fe9c003c-a646-430f-a189-516620fc5555"
        return NewReminderViewContent(bridges: [bridge])
    }
}
