//
//  ContentView.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-07-08.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {

    @ObservedObject private var listViewModel = ListViewModel()

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 10) {
                List(listViewModel.reminders) { reminder in
                    NavigationLink(destination: InspectReminderView(reminder)) {
                        ReminderRow(reminder: reminder)
                            .onTapGesture {
                                print(reminder.name)
                            }
                    }
                }
                .navigationBarItems(trailing:
                    NavigationLink(destination: NewReminder(onAddReminder: { (reminder) in
                        self.listViewModel.reminders.append(reminder)
                    }), label: {
                    Text("Add")
                }))
                .navigationBarTitle("Reminders")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
