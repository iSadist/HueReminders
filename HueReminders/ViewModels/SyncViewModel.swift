import Foundation
import Combine
import EventKit
import UIKit

class SyncViewModel: ObservableObject {
    @Published var calendars: [CalendarRowModel] = []
    @Published var readyToStart: Bool
    @Published var date: Date
    @Published var isSyncing: Bool
    @Published var syncProgress: Float
    
    var selectedCalendarsPublisher: AnyPublisher<Bool, Never>?
    var validDatePublisher: AnyPublisher<Bool, Never> {
        $date
            .map { $0.compare(Date()).rawValue > 0 }
            .eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()
    var store: EKEventStore // TODO: Perhaps create an Event Store class to perform some of these things? Could maybe be a singleton class?

    init() {
        readyToStart = false
        store = EKEventStore()
        date = Date()
        isSyncing = false
        syncProgress = 0.0
        
        self.setupCalendar()
    }
    
    func setupPublisher() -> AnyPublisher<Bool, Never> {
        let publishers = self.calendars.map { $0.isSelected }
        let sequence = Publishers.MergeMany(publishers).eraseToAnyPublisher()
        return sequence
    }
    
    func setupCalendar() { // TODO: Also move this out of the View model
        store.requestAccess(to: .event) { (granted, error) in
            print("Calendar access granted: \(granted)")
            
            if error != nil {
                print(error.debugDescription)
            }
            
            self.populateCalendar()
        }
    }
    
    func populateCalendar() {
        let calendars = store.calendars(for: .event)
        
        for calendar in calendars {
            let row = CalendarRowModel(calendar: calendar)
            self.calendars.append(row)
        }
        
        // TOOO: This wouldn't have to be done like this if the calendars where passed into the model instead
        selectedCalendarsPublisher = setupPublisher()
        selectedCalendarsPublisher!.combineLatest(validDatePublisher)
            .map({ (first, second) -> Bool in
                first && second
            })
            .receive(on: RunLoop.main)
            .assign(to: \.readyToStart, on: self)
            .store(in: &cancellables)
    }
}
