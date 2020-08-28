//
//  CalendarSyncModel.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-28.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import UIKit
import EventKit

struct CalendarSyncModel {
    var calendar: EKCalendar
    var lights: [HueLight]
    var color: UIColor
    var endDate: Date
}
