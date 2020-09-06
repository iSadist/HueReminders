//
//  ContentView.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-07-08.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI
import Combine

struct RemindersListView: View {
    @FetchRequest(fetchRequest: Reminder.findAll()) var reminders: FetchedResults<Reminder>
    @FetchRequest(fetchRequest: HueBridge.findAll()) var activeBridge: FetchedResults<HueBridge>
    
    func setReminderPosition() {
        let remindersWithoutPosition = reminders.filter { $0.position == -1 }
        for reminder in remindersWithoutPosition {
            if let lastPosition = reminders.filter({ $0.bridge == reminder.bridge }).max()?.position {
                reminder.position = lastPosition + 1
            } else {
                reminder.position = 0
            }
        }
    }

    var body: some View {
        setReminderPosition()
        let viewModel = ListViewModel(reminders: reminders.sorted(), bridges: self.activeBridge.sorted())
        return RemindersListContent(viewModel: viewModel)
    }
}

private struct RemindersListContent: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var viewModel: ListViewModel
    
    func move(from source: IndexSet, to destination: Int, _ bridge: HueBridge) {
        guard let index = source.first else { return }
        // TODO: Refactor this code into some utility
        let filteredReminders = self.viewModel.reminders.filter { $0.bridge == bridge }
        let movedReminder = filteredReminders[index]

        if index > destination {
            filteredReminders.filter {
                $0.position < index && $0.position >= destination
            }.forEach { $0.position += 1 }
            movedReminder.position = Int16(destination)
        } else if index < destination {
            filteredReminders.filter {
                $0.position > index && $0.position < destination
            }.forEach { $0.position -= 1 }
            movedReminder.position = destination == 0 ? 0 : Int16(destination - 1)
        } else {
            return
        }
        
        try? managedObjectContext.save()
    }
    
    private func validateAll() {
        viewModel.reminders.forEach { validate(reminder: $0) }
    }

    private func validate(reminder: Reminder) {
        if let time = reminder.time, time < Date() {
            delete(reminder: reminder)
            if let index = viewModel.reminders.firstIndex(of: reminder) {
                viewModel.reminders.remove(at: index)
            }
        }
    }

    func delete(indexSet: IndexSet, _ bridge: HueBridge) {
        if let index = indexSet.first {
            // TODO: Move to interactor
            let remindersForBridge = self.viewModel.reminders.filter { $0.bridge == bridge }
            let reminder = remindersForBridge[index]
            self.delete(reminder: reminder)
        }
    }
    
    func delete(reminder: Reminder) {
        guard let bridge = reminder.bridge else { fatalError("Reminder missing bridge") }
        let requests = HueAPI.deleteSchedule(on: bridge, reminder: reminder)
        
        for request in requests {
            let task = URLSession.shared.dataTask(with: request) { _, _, _ in
                // TODO: Handle data, response and error

            }
            task.resume()
        }

        if let lights = reminder.light {
            reminder.removeFromLight(lights)
        }
        reminder.removeFromLight(reminder.light!)
        
        // TODO: Remove the local notification
        
        self.managedObjectContext.delete(reminder)
        try? self.managedObjectContext.save()
    }
    
    func deleteAll() {
        self.viewModel.reminders.forEach { self.delete(reminder: $0) }
    }

    var body: some View {
        let bridges: [HueBridge] = viewModel.bridges
        let reminders: [Reminder] = viewModel.reminders
        
        return
            NavigationView {
                List {
                    ForEach(bridges) { bridge in
                        if bridges.count > 1 {
                            Text(bridge.name!).font(.title)
                        }
                        
                        if reminders.filter { $0.bridge == bridge }.isEmpty {
                            Text("No reminders found").font(.caption)
                        } else {
                            ForEach(reminders.filter { $0.bridge == bridge }) { reminder in
                                ReminderRow(viewModel: ReminderRowViewModel(reminder, bridge))
                            }
                            .onMove(perform: { self.move(from: $0, to: $1, bridge) })
                            .onDelete { self.delete(indexSet: $0, bridge) }
                        }
                    }
                    
                    if reminders.count > 1 {
                        HStack {
                            Spacer()
                            Button(action: {
                                print("Removing all reminders")
                                self.deleteAll()
                            }) {
                                Text("Remove all reminders")
                                    .foregroundColor(.red)
                            }
                            Spacer()
                        }
                    }
                }
                .navigationBarTitle("Reminders")
                .navigationBarItems(leading: EditButton(),
                                    trailing: NavigationLink(destination: NewReminderView(),
                                                             label: {
                                                                Image(systemName: "plus")
                                                                    .imageScale(.large)
                                    }
                    )
                )
                .onAppear {
                    self.validateAll()
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let bridge = HueBridge(context: context)
        bridge.active = true
        bridge.address = "192.168.1.2"
        bridge.name = "First floor"
        
        let bridge2 = HueBridge(context: context)
        bridge2.active = false
        bridge2.address = "192.168.1.2"
        bridge2.name = "Second floor"
        
        let bridge3 = HueBridge(context: context)
        bridge3.active = false
        bridge3.address = "192.168.1.3"
        bridge3.name = "Basement"
        
        let reminder = Reminder(context: context)
        reminder.active = true
        reminder.color = HueColor.create(context: context, color: .blue)
        reminder.day = 1
        reminder.name = "Wake up"
        reminder.time = Date()
        
        let reminder2 = Reminder(context: context)
        reminder2.active = false
        reminder2.color = HueColor.create(context: context, color: .green)
        reminder2.day = 4
        reminder2.name = "Go to bed"
        reminder2.time = Date()
        
        let reminder3 = Reminder(context: context)
        reminder3.active = false
        reminder3.color = HueColor.create(context: context, color: .yellow)
        reminder3.day = 4
        reminder3.name = "Go to bed"
        reminder3.time = Date().advanced(by: 1)
        
        bridge.addToReminder(reminder)
        bridge.addToReminder(reminder2)
        bridge2.addToReminder(reminder3)
        
        let viewModel = ListViewModel(reminders: [reminder, reminder2, reminder3], bridges: [bridge, bridge2, bridge3])
        
        return RemindersListContent(viewModel: viewModel)
    }
}
