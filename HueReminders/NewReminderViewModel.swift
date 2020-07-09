import Foundation
import Combine

class NewReminderViewModel: ObservableObject {
    // Input
    @Published var name = ""
    @Published var color = 0
    @Published var day = 0
    @Published var time = Date()

    // Output
    @Published var valid = true
    
    var isNameValid: AnyPublisher<Bool, Never> {
        $name
            .map { name in
                return name.count > 0
            }
            .eraseToAnyPublisher()
    }
}
