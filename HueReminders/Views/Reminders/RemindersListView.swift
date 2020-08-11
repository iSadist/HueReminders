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
    @ObservedObject private var listViewModel = ListViewModel()

    var body: some View {
        RemindersListContent(reminders: reminders.sorted())
    }
}

private struct RemindersListContent: View {
    @FetchRequest(fetchRequest: HueBridge.findActiveBridge()) var activeBridge: FetchedResults<HueBridge>
    @Environment(\.managedObjectContext) var managedObjectContext
    var reminders: [Reminder]
    
    func onToggle(reminder: Reminder) {
        HueAPI.toggleActive(for: reminder, self.activeBridge.sorted().first!)
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(reminders) { reminder in
//                NavigationLink(destination: InspectReminderView(reminder)) {
                    ReminderRow(viewModel: ReminderRowViewModel(reminder), onToggle: self.onToggle)
                        .frame(height: 57)
//                }
                }.onDelete { indexSet in
                    if let index = indexSet.first {
                        let reminder = self.reminders[index]
                        let bridge = self.activeBridge.sorted().first!
                        let request = HueAPI.deleteSchedule(on: bridge, reminder: reminder)
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
            }
            .navigationBarTitle("Reminders")
            .navigationBarItems(leading: EditButton(),
                                trailing: NavigationLink(destination: NewReminderView(),
                                                         label: {
                                                            Text("Add")
                                }
                )
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let reminder = Reminder(context: context)
        reminder.active = true
        reminder.color = 1
        reminder.day = 1
        reminder.name = "Wake up"
        reminder.time = Date()
        
        let reminder2 = Reminder(context: context)
        reminder2.active = false
        reminder2.color = 1
        reminder2.day = 1
        reminder2.name = "Go to bed"
        reminder2.time = Date()
        
        return RemindersListContent(reminders: [reminder, reminder2])
    }
}
