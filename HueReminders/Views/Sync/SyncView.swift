//
//  SyncView.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-20.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI

struct CalendarRow: View {
    var viewModel: CalendarRowModel
    
    var body: some View {
        HStack {
            Text(viewModel.title)
            Spacer()
            Rectangle()
                .frame(width: 50.0)
                .foregroundColor(Color(viewModel.color))
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
        let calendars = [
            CalendarRowModel(title: "Work", color: .green),
            CalendarRowModel(title: "Birthdays", color: .red),
            CalendarRowModel(title: "Holidays", color: .yellow),
            CalendarRowModel(title: "Fun", color: .blue)
        ]
        
        return SyncViewContent(calendars: calendars)
    }
}
