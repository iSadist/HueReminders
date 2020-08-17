//
//  ListViewModel.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-07-08.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Combine

class ListViewModel: ObservableObject {
    @Published var reminders: [Reminder]
    @Published var bridges: [HueBridge]
    
    init(reminders: [Reminder], bridges: [HueBridge]) {
        self.reminders = reminders
        self.bridges = bridges
    }
}
