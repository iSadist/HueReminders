import Combine

class NewReminderViewModel: ObservableObject {
    // Input
    @Published var name = ""
    @Published var color = ""
    @Published var day = ""
    @Published var time = ""

    // Output
    @Published var isValid = true
}
