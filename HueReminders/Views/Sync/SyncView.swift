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
                        syncing: viewModel.isSyncing,
                        syncProgress: viewModel.syncProgress,
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
                EmptyView(text: NSLocalizedString("SYNC_NO-CALENDARS", comment: ""))
            } else {
                NavigationView {
                    Form {
                        Section {
                            List {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(NSLocalizedString("SYNC_CALENDARS-TITLE", comment: ""))
                                        .font(.title)
                                        .bold()
                                    Text(NSLocalizedString("SYNC_CALENDARS-SUB-TITLE", comment: ""))
                                        .font(.subheadline)
                                }
                                ForEach(self.calendars) { calendar in
                                    NavigationLink(
                                        destination: interactor.destination(to: calendar)) {
                                        CalendarRow(viewModel: calendar)
                                    }
                                }
                            }
                        }
                        
                        Section {
                            DatePicker(NSLocalizedString("SYNC_END-DATE", comment: ""),
                                       selection: date,
                                       displayedComponents: [.date])
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
                                Text(NSLocalizedString("SYNC_START", comment: ""))
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
                    .navigationBarTitle(NSLocalizedString("SYNC_NAVIGATION-TITLE", comment: ""))
                    .navigationBarHidden(true)
                }
            }
        }.onAppear {
            UITableView.appearance().backgroundColor = .clear
            syncProgress = 0.0
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
