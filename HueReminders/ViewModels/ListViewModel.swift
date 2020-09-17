import Combine

class ListViewModel: ObservableObject {
    @Published var reminders: [Reminder]
    @Published var bridges: [HueBridge]
    @Published var showingAlert: Bool
    
    init(reminders: [Reminder], bridges: [HueBridge]) {
        self.reminders = reminders
        self.bridges = bridges
        self.showingAlert = false
    }
}
