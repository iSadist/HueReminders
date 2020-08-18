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
    
    func delete(indexSet: IndexSet, _ bridge: HueBridge) {
        if let index = indexSet.first {
            let remindersForBridge = self.viewModel.reminders.filter { $0.bridge == bridge }
            let reminder = remindersForBridge[index]
            
            guard let request = HueAPI.deleteSchedule(on: bridge, reminder: reminder) else {
                // Just delete the reminder if can't send a delete request
                self.managedObjectContext.delete(reminder)
                try? self.managedObjectContext.save()
                return
            }
            let task = URLSession.shared.dataTask(with: request) { _, _, _ in
                // TODO: Handle data, response and error

                DispatchQueue.main.async {
                    self.managedObjectContext.delete(reminder)
                    try? self.managedObjectContext.save()
                }
            }
            task.resume()
        }
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
                        
                        ForEach(reminders.filter { $0.bridge == bridge }) { reminder in
                            ReminderRow(viewModel: ReminderRowViewModel(reminder, bridge))
                        }
                        .onMove(perform: { self.move(from: $0, to: $1, bridge) })
                        .onDelete { self.delete(indexSet: $0, bridge) }
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
        
        let reminder = Reminder(context: context)
        reminder.active = true
        reminder.color = 1
        reminder.day = 1
        reminder.name = "Wake up"
        reminder.time = Date()
        
        let reminder2 = Reminder(context: context)
        reminder2.active = false
        reminder2.color = 6
        reminder2.day = 4
        reminder2.name = "Go to bed"
        reminder2.time = Date()
        
        let reminder3 = Reminder(context: context)
        reminder3.active = false
        reminder3.color = 6
        reminder3.day = 4
        reminder3.name = "Go to bed"
        reminder3.time = Date().advanced(by: 1)
        
        bridge.addToReminder(reminder)
        bridge.addToReminder(reminder2)
        bridge2.addToReminder(reminder3)
        
        let viewModel = ListViewModel(reminders: [reminder, reminder2, reminder3], bridges: [bridge, bridge2])
        
        return RemindersListContent(viewModel: viewModel)
    }
}
