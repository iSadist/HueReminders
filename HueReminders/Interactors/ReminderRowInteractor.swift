import Foundation
import CoreData

protocol ReminderRowInteracting {
    func toggle(_ viewModel: ReminderRowViewModel, context: NSManagedObjectContext)
}

class ReminderRowInteractor: ReminderRowInteracting {
    func toggle(_ viewModel: ReminderRowViewModel, context: NSManagedObjectContext) {
        viewModel.reminder.active = !viewModel.isActive
        try? context.save()
        HueAPI.toggleActive(for: viewModel.reminder, viewModel.bridge)
    }
}
