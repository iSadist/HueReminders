import Foundation
import CoreData

protocol ReminderListInteracting {
    func delete(reminder: Reminder, context: NSManagedObjectContext)
    func validate(reminder: Reminder, viewModel: ListViewModel, context: NSManagedObjectContext)
    func move(from source: IndexSet,
              to destination: Int,
              _ bridge: HueBridge,
              _ viewModel: ListViewModel,
              _ context: NSManagedObjectContext)
    func willLoad(reminders: [Reminder])
}

class ReminderListInteractor: ReminderListInteracting {
    func willLoad(reminders: [Reminder]) {
        let remindersWithoutPosition = reminders.filter { $0.position == -1 }
        for reminder in remindersWithoutPosition {
            if let lastPosition = reminders.filter({ $0.bridge == reminder.bridge }).max()?.position {
                reminder.position = lastPosition + 1
            } else {
                reminder.position = 0
            }
        }
    }
    
    func delete(reminder: Reminder, context: NSManagedObjectContext) {
        guard let bridge = reminder.bridge else { fatalError("Reminder missing bridge") }
        let requests = HueAPI.deleteSchedule(on: bridge, reminder: reminder)
        
        for request in requests {
            let task = URLSession.shared.dataTask(with: request) { _, _, _ in
                // TODO: Handle data, response and error

            }
            task.resume()
        }

        if let lights = reminder.light {
            reminder.removeFromLight(lights)
        }
        reminder.removeFromLight(reminder.light!)
        reminder.removeLocalNotification()

        context.delete(reminder)
        try? context.save()
    }
    
    func validate(reminder: Reminder, viewModel: ListViewModel, context: NSManagedObjectContext) {
        if let time = reminder.time, time < Date() {
            self.delete(reminder: reminder, context: context)
            if let index = viewModel.reminders.firstIndex(of: reminder) {
                viewModel.reminders.remove(at: index)
            }
        }
    }
    
    func move(from source: IndexSet,
              to destination: Int,
              _ bridge: HueBridge,
              _ viewModel: ListViewModel,
              _ context: NSManagedObjectContext) {
        guard let index = source.first else { return }
        let filteredReminders = viewModel.reminders.filter { $0.bridge == bridge }
        let movedReminder = filteredReminders[index]

        if index > destination {
            filteredReminders.filter {
                $0.position < index && $0.position >= destination
            }.forEach { $0.position += 1 }
            movedReminder.position = Int16(destination)
        } else if index < destination {
            filteredReminders.filter {
                $0.position > index && $0.position < destination
            }.forEach { $0.position -= 1 }
            movedReminder.position = destination == 0 ? 0 : Int16(destination - 1)
        } else {
            return
        }
        
        try? context.save()
    }
}
