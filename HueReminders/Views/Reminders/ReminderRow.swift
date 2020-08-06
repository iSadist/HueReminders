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
}

private let rectWidth: CGFloat = 100

struct ReminderRow: View {
    var reminder: Reminder
    
    @State var offset = CGSize(width: -rectWidth, height: 0)
    @State var active = false
    
    var color: Color {
        return active ? Color.green : Color.red
    }
    
    var formatter: DateFormatter = {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm"
        return timeFormatter
    }()
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("")
                .frame(width: rectWidth, height: 70, alignment: .center)
                .background(color)
                .foregroundColor(Color.black)

            Text(reminder.name!)
            Text(ReminderColor.allCases[Int(reminder.color)].rawValue)
            Text(WeekDay.allCases[Int(reminder.day)].rawValue)
            Text("\(formatter.string(from: reminder.time!))")
        }
        .animation(.interactiveSpring())
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { gesture in
                    if gesture.translation.width > rectWidth - 10 {
                        return
                    }
                    
                    self.offset.width = gesture.translation.width - rectWidth
                }
                .onEnded({ gesture in
                    if gesture.translation.width > 100 {
                        self.offset.width = -rectWidth
                        self.active = !self.active
                        self.reminder.active = self.active
                        return
                    }
                    
                    self.offset.width = -rectWidth
                })
        ).offset(x: self.offset.width, y: 0)
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
        return ReminderRow(reminder: reminder)
            .previewLayout(.fixed(width: 400, height: 70))
    }
}
