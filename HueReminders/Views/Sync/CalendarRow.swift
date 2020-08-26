//
//  CalendarRow.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-26.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI

import SwiftUI
import EventKit
import UIKit
import Combine

struct CalendarRow: View {
    @ObservedObject var viewModel: CalendarRowModel
    @State var linkActive = true
    
    var body: some View {
        HStack {
            Rectangle()
                .frame(width: 50.0)
                .foregroundColor(Color(viewModel.color))
            Text(viewModel.title).lineLimit(1)
            Spacer()
            NavigationLink(destination: CalendarConfigurationView(), isActive: $linkActive) {
                Text("\(viewModel.lights.count) lights selected")
                    .font(.caption)
            }
            Toggle(isOn: $viewModel.selected) {
                Text("").hidden()
            }
        }
    }
}

struct CalendarRow_Previews: PreviewProvider {
    static var previews: some View {
        let work = EKCalendar(for: .event, eventStore: .init())
        work.title = "Work"
        work.cgColor = UIColor.green.cgColor
        return CalendarRow(viewModel: CalendarRowModel(calendar: work))
                .previewLayout(.fixed(width: 400, height: 70))
    }
}
