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

struct CalendarRow: View {
    @ObservedObject var viewModel: CalendarRowModel
    
    var body: some View {
        HStack {
            Text(viewModel.title)
            Spacer()
            Rectangle()
                .frame(width: 50.0)
                .foregroundColor(Color(viewModel.color))
            if viewModel.selected {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "checkmark.circle").hidden()
            }
        }
        .onTapGesture {
            self.viewModel.selected = !self.viewModel.selected
        }
    }
}

struct SyncView: View {
    @ObservedObject var viewModel: SyncViewModel
    
    init() {
        viewModel = SyncViewModel()
    }
    
    var body: some View {
        SyncViewContent(calendars: viewModel.calendars)
    }
}

struct SyncViewContent: View {
    var calendars: [CalendarRowModel]

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
                Text("Start syncing")
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
        
        return SyncViewContent(calendars: calendars)
    }
}
