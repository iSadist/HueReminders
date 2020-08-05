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
        NavigationView {
            List(reminders) { reminder in
//                NavigationLink(destination: InspectReminderView(reminder)) {
                    ReminderRow(reminder: reminder)
//                }
            }
            .navigationBarItems(trailing:
                NavigationLink(destination: NewReminderView(), label: {
                    Text("Add")
            }))
            .navigationBarTitle("Reminders")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RemindersListView()
    }
}
