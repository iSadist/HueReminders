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
    var interactor: SyncInteracting

    var body: some View {
        SyncViewContent(calendars: viewModel.calendars,
                        buttonDisabled: !viewModel.readyToStart,
                        date: $viewModel.date,
                        interactor: interactor)
    }
}

struct SyncViewContent: View {
    var calendars: [CalendarRowModel]
    var buttonDisabled: Bool
    var date: Binding<Date>
    @State var syncing: Bool = false
    @State var syncProgress: Float = 0.0
    var interactor: SyncInteracting

    var body: some View {
        VStack {
            if self.calendars.isEmpty {
                EmptyView(text: "No calendars available. Make sure to allow it in the privacy settings")
            } else {
                NavigationView {
                    Form {
                        Section {
                            List {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("Calendars")
                                        .font(.title)
                                        .bold()
                                    Text("Select the ones to sync")
                                        .font(.subheadline)
                                }
                                ForEach(self.calendars) { calendar in
                                    NavigationLink(destination: CalendarConfigurationListView(interactor: CalendarConfigurationInterator(),
                                                                                              model: calendar)) {
                                        CalendarRow(viewModel: calendar)
                                    }
                                }
                            }
                        }
                        
                        Section {
                            DatePicker("Sync end date", selection: date, displayedComponents: [.date])
                        }
                        
                        HStack {
                            Button(action: {
                                self.syncing = true
                                let syncModels = self.calendars
                                    .filter({ $0.selected == true })
                                    .map {
                                        CalendarSyncModel(calendar: $0.calendar,
                                                          lights: Array($0.lights),
                                                          color: $0.color,
                                                          endDate: self.date.wrappedValue)
                                }
                                self.interactor.sync(syncModels) { progress in
                                    self.syncProgress = progress
                                    if progress == 1.0 {
                                        self.syncing = false
                                    }
                                }
                            }) {
                                Text("Start syncing")
                            }.disabled(buttonDisabled)
                            
                            if syncing {
                                ProgressBar(value: $syncProgress)
                            }
                            
                            if syncProgress == 1.0 {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                            }
                        }
                        
                    }.background(Color(UIColor.systemBackground))
                    .navigationBarTitle("Calendars")
                    .navigationBarHidden(true)
                }
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

        return SyncViewContent(calendars: calendars,
                               buttonDisabled: false,
                               date: date,
                               syncing: true,
                               interactor: SyncInteractor())
    }
}
