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

struct CalendarRow: View {
    @ObservedObject var viewModel: CalendarRowModel
    
    var body: some View {
        HStack {
            Rectangle()
                .frame(width: 50.0)
                .foregroundColor(Color(viewModel.color))
            Text(viewModel.title)
            Spacer()
            if viewModel.selected {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "checkmark.circle").hidden()
            }
            Toggle(isOn: $viewModel.selected) {
                Text("").hidden()
            }
        }
    }
}

struct SyncView: View {
    @ObservedObject var viewModel: SyncViewModel
    
    init() {
        viewModel = SyncViewModel()
    }
    
    var body: some View {
        SyncViewContent(calendars: viewModel.calendars, buttonDisabled: !viewModel.readyToStart, date: $viewModel.date)
            .padding()
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
                List {
                    Text("Calendars")
                        .font(.title)
                    ForEach(self.calendars) { calendar in
                        CalendarRow(viewModel: calendar)
                    }
                }
                
                DatePicker("Sync to", selection: date, displayedComponents: [DatePickerComponents.date])
                
                Button(action: {
                    print("Start syncing...")
                }) {
                    Text("Start syncing")
                }.disabled(buttonDisabled)
            }
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

        let calendars = [
            CalendarRowModel(calendar: work),
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
