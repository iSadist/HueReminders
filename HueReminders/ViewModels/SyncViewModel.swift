//
//  SyncViewModel.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-20.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation
import Combine
import EventKit
import UIKit

class CalendarRowModel: ObservableObject, Identifiable {
    var id = UUID()
    @Published var title: String
    @Published var color: UIColor
    @Published var selected: Bool = false
    @Published var lights: Set<HueLight> = []
    
    init(calendar: EKCalendar) {
        title = calendar.title
        color = UIColor(cgColor: calendar.cgColor)
    }
    
    var isSelected: AnyPublisher<Bool, Never> {
        $selected
            .map { $0 }
            .eraseToAnyPublisher()
    }
}

class SyncViewModel: ObservableObject {
    @Published var calendars: [CalendarRowModel] = []
    @Published var readyToStart: Bool
    @Published var date: Date
    
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
            .map({ (first,second) -> Bool in
                first && second
            })
            .receive(on: RunLoop.main)
            .assign(to: \.readyToStart, on: self)
            .store(in: &cancellables)
    }
}
