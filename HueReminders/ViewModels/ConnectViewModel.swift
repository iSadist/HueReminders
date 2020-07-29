import Foundation
import Combine

class ConnectViewModel: ObservableObject {
    @Published var ipAddress = ""
    @Published var isAnimating = false
    @Published var usernameID = ""
    @Published var informationMessage = ""

    @Published var bridgeSelectViewVisible = false
    @Published var isConnected = false

    var connectedPublisher: AnyPublisher<Bool, Never> {
        $usernameID
            .map { name in
                return name.count > 0
            }
            .eraseToAnyPublisher()
    }
}
