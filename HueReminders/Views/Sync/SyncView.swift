//
//  SyncView.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-20.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI
import EventKit
import UIKit
import Combine

struct SyncView: View {
    @ObservedObject var viewModel: SyncViewModel
    
    init() {
        viewModel = SyncViewModel()
    }
    
    var body: some View {
        SyncViewContent(calendars: viewModel.calendars, buttonDisabled: !viewModel.readyToStart, date: $viewModel.date)
    }
}

struct SyncViewContent: View {
    var calendars: [CalendarRowModel]
    var buttonDisabled: Bool
    var date: Binding<Date>

    var body: some View {
        VStack {
            if self.calendars.isEmpty {
                EmptyView(text: "No calendars available. Make sure to allow it in the privacy settings")
            } else {
                Form {
                    Section {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Calendars")
                                .font(.title)
                            Text("Select the ones to sync")
                                .font(.subheadline)
                        }
                        List {
                            ForEach(self.calendars) { calendar in
                                CalendarRow(viewModel: calendar)
                            }
                        }
                    }
                    
                    Section {
                        DatePicker("Sync end date", selection: date, displayedComponents: [.date])
                    }
                }.background(Color.white)
                
                Button(action: {
                    print("Start syncing...")
                }) {
                    Text("Start syncing")
                }.disabled(buttonDisabled)
            }
        }.onAppear {
            UITableView.appearance().backgroundColor = .clear
        }
    }
}

struct SyncView_Previews: PreviewProvider {
    static var previews: some View {
        let work = EKCalendar(for: .event, eventStore: .init())
        work.title = "Work"
        work.cgColor = UIColor.green.cgColor

        let birthdays = EKCalendar(for: .event, eventStore: .init())
        birthdays.title = "Birthdays"
        birthdays.cgColor = UIColor.blue.cgColor

        let holidays = EKCalendar(for: .event, eventStore: .init())
        holidays.title = "Holidays"
        holidays.cgColor = UIColor.red.cgColor
        
        let selectedCalendarRowModel = CalendarRowModel(calendar: work)
        selectedCalendarRowModel.selected = true

        let calendars = [
            selectedCalendarRowModel,
            CalendarRowModel(calendar: birthdays),
            CalendarRowModel(calendar: holidays)
        ]
        
        let date: Binding<Date> = Binding<Date>(get: { () -> Date in
            Date()
        }) { (_) in
            print("set")
        }

        return SyncViewContent(calendars: calendars, buttonDisabled: false, date: date)
    }
}
