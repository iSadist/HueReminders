//
//  Reminder.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-07-08.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI

enum WeekDay: String, CaseIterable {
    case Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday // swiftlint:disable identifier_name
}

enum ReminderColor: String, CaseIterable {
    case White, Blue, Red, Green, Yellow, Pink, Purple, Orange // swiftlint:disable identifier_name
    
    func getColor() -> UIColor {
        switch self {
        case .White: return .white
        case .Blue: return .blue
        case .Red: return .red
        case .Green: return .green
        case .Yellow: return .yellow
        case .Pink: return .systemPink
        case .Purple: return .purple
        case .Orange: return .orange
        }
    }
}

struct ReminderRow: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    var reminder: Reminder

    @State var active = false
    
    var color: Color {
        return Color(ReminderColor.allCases[Int(reminder.color)].getColor())
    }
    
    var formatter: DateFormatter = {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm"
        return timeFormatter
    }()
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(reminder.name!)
            Text(WeekDay.allCases[Int(reminder.day)].rawValue)
            Text("\(formatter.string(from: reminder.time!))")
            Text(reminder.lightID ?? "")
            
            Spacer()
            
            Toggle(isOn: $active) {
                Text("").hidden()
            }.frame(alignment: .center)
        }
        .padding()
        .background(color) // TODO: Set the foreground color to either white or black depending on the background
        .onAppear {
            self.active = self.reminder.active
        }
    }
}

struct ReminderRow_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let reminder = Reminder(context: context)
        reminder.active = true
        reminder.color = 1
        reminder.day = 1
        reminder.name = "Reminder"
        reminder.time = Date()
        reminder.lightID = "1"
        return ReminderRow(reminder: reminder)
            .previewLayout(.fixed(width: 400, height: 70))
    }
}
