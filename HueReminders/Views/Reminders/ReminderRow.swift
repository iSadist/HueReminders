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
    @ObservedObject var viewModel: ReminderRowViewModel
    
    var onToggle: ((Reminder) -> Void)?
    
    init(viewModel: ReminderRowViewModel, onToggle: ((Reminder) -> Void)?) {
        self.viewModel = viewModel
        self.onToggle = onToggle
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(viewModel.name)
            Text(viewModel.day)
            Text(viewModel.time)
            Text(viewModel.lightID)
            
            Spacer()
            
            Toggle(isOn: $viewModel.isActive) {
                Text("").hidden()
            }.frame(alignment: .center)
            .onTapGesture {
                self.viewModel.reminder.active = !self.viewModel.isActive // TODO: Do this in the viewModel instead
                self.onToggle?(self.viewModel.reminder)
            }
        }
        .padding()
            .background(viewModel.color) // TODO: Set the foreground color to either white or black depending on the background
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
        
        let viewModel = ReminderRowViewModel(reminder)
        return ReminderRow(viewModel: viewModel, onToggle: nil)
            .previewLayout(.fixed(width: 400, height: 70))
    }
}
