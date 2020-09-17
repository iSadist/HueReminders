import SwiftUI
import Combine

struct RemindersListView: View {
    @FetchRequest(fetchRequest: Reminder.findAll()) var reminders: FetchedResults<Reminder>
    @FetchRequest(fetchRequest: HueBridge.findAll()) var activeBridge: FetchedResults<HueBridge>
    var interactor: ReminderListInteracting? = ReminderListInteractor()

    var body: some View {
        interactor?.willLoad(reminders: reminders.sorted())
        let viewModel = ListViewModel(reminders: reminders.sorted(), bridges: self.activeBridge.sorted())
        return RemindersListContent(viewModel: viewModel)
    }
}

private struct RemindersListContent: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var viewModel: ListViewModel
    var interactor: ReminderListInteracting? = ReminderListInteractor()
    
    func move(from source: IndexSet, to destination: Int, _ bridge: HueBridge) {
        self.interactor?.move(from: source, to: destination, bridge, viewModel, managedObjectContext)
    }
    
    private func validateAll() {
        viewModel.reminders.forEach { validate(reminder: $0) }
    }

    private func validate(reminder: Reminder) {
        self.interactor?.validate(reminder: reminder, viewModel: viewModel, context: managedObjectContext)
    }

    func delete(indexSet: IndexSet, _ bridge: HueBridge) {
        if let index = indexSet.first {
            let remindersForBridge = self.viewModel.reminders.filter { $0.bridge == bridge }
            let reminder = remindersForBridge[index]
            self.interactor?.delete(reminder: reminder, context: managedObjectContext)
        }
    }
    
    func deleteAll() {
        self.viewModel.reminders.forEach { self.interactor?.delete(reminder: $0, context: self.managedObjectContext) }
    }

    var body: some View {
        let bridges: [HueBridge] = viewModel.bridges
        let reminders: [Reminder] = viewModel.reminders
        
        return
            NavigationView {
                List {
                    ForEach(bridges) { bridge in
                        if bridges.count > 1 {
                            Text(bridge.name!).font(.title)
                        }
                        
                        if reminders.filter { $0.bridge == bridge }.isEmpty {
                            Text(NSLocalizedString("REMINDERS-LIST_NO-REMINDERS-MESSAGE", comment: "")).font(.caption)
                        } else {
                            ForEach(reminders.filter { $0.bridge == bridge }) { reminder in
                                ReminderRow(viewModel: ReminderRowViewModel(reminder, bridge))
                            }
                            .onMove(perform: { self.move(from: $0, to: $1, bridge) })
                            .onDelete { self.delete(indexSet: $0, bridge) }
                        }
                    }
                    
                    if reminders.count > 1 {
                        HStack {
                            Spacer()
                            Button(action: {
                                self.viewModel.showingAlert = true
                            }) {
                                Text(NSLocalizedString("REMINDERS-LIST_REMOVE-ALL-BUTTON-TEXT", comment: ""))
                                    .foregroundColor(.red)
                            }
                            Spacer()
                        }
                    }
                }
                .actionSheet(isPresented: self.$viewModel.showingAlert) {
                    ActionSheet(
                        title: Text(NSLocalizedString("REMINDERS-LIST_REMOVE-ALL-CONFIRM-TITLE", comment: "")),
                        message: Text(NSLocalizedString("REMINDERS-LIST_REMOVE-ALL-CONFIRM-MESSAGE", comment: "")),
                        buttons: [
                            .destructive(Text(NSLocalizedString("REMINDERS-LIST_REMOVE-ALL-CONFIRM-DELETE", comment: "")), action: self.deleteAll),
                            .cancel()
                        ]
                    )
                }
                .navigationBarTitle(NSLocalizedString("REMINDERS-LIST_NAVIGATION-TITLE", comment: ""))
                .navigationBarItems(leading: EditButton(),
                                    trailing: NavigationLink(destination: NewReminderView(),
                                                             label: {
                                                                Image(systemName: "plus")
                                                                    .imageScale(.large)
                                    }
                    )
                )
                .onAppear {
                    self.validateAll()
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let bridge = HueBridge(context: context)
        bridge.active = true
        bridge.address = "192.168.1.2"
        bridge.name = "First floor"
        
        let bridge2 = HueBridge(context: context)
        bridge2.active = false
        bridge2.address = "192.168.1.2"
        bridge2.name = "Second floor"
        
        let bridge3 = HueBridge(context: context)
        bridge3.active = false
        bridge3.address = "192.168.1.3"
        bridge3.name = "Basement"
        
        let reminder = Reminder(context: context)
        reminder.active = true
        reminder.color = HueColor.create(context: context, color: .blue)
        reminder.day = 1
        reminder.name = "Wake up"
        reminder.time = Date()
        
        let reminder2 = Reminder(context: context)
        reminder2.active = false
        reminder2.color = HueColor.create(context: context, color: .green)
        reminder2.day = 4
        reminder2.name = "Go to bed"
        reminder2.time = Date()
        
        let reminder3 = Reminder(context: context)
        reminder3.active = false
        reminder3.color = HueColor.create(context: context, color: .yellow)
        reminder3.day = 4
        reminder3.name = "Go to bed"
        reminder3.time = Date().advanced(by: 1)
        
        bridge.addToReminder(reminder)
        bridge.addToReminder(reminder2)
        bridge2.addToReminder(reminder3)
        
        let viewModel = ListViewModel(reminders: [reminder, reminder2, reminder3], bridges: [bridge, bridge2, bridge3])
        
        return RemindersListContent(viewModel: viewModel)
    }
}
