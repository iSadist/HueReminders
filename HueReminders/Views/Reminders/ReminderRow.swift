//
//  Reminder.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-07-08.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI

struct ReminderRow: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var viewModel: ReminderRowViewModel

    func sendToggleRequestToHue() {
        print(viewModel.reminder, viewModel.bridge)
        HueAPI.toggleActive(for: viewModel.reminder, viewModel.bridge)
    }
    
    init(viewModel: ReminderRowViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.name)
                    .bold()
                HStack(alignment: .center, spacing: 10) {
                    Text(viewModel.day)
                    Text(viewModel.time)
                    Spacer()
                }
            }
            VStack(alignment: .trailing, spacing: 0) {
                Toggle(isOn: $viewModel.isActive) {
                    Text("").hidden()
                }.frame(alignment: .center)
                    .onTapGesture {
                        self.viewModel.reminder.active = !self.viewModel.isActive // TODO: Do this in the viewModel instead
                        try? self.managedObjectContext.save()
                        self.sendToggleRequestToHue()
                }
            }
        }
        .padding()
        .background(viewModel.color) // TODO: Set the foreground color to either white or black depending on the background
        .cornerRadius(10)
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
        let bridge = HueBridge(context: context)
        let viewModel = ReminderRowViewModel(reminder, bridge)
        return ReminderRow(viewModel: viewModel)
            .previewLayout(.fixed(width: 400, height: 70))
    }
}
