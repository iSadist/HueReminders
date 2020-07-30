import Foundation
import Combine

class ConnectViewModel: ObservableObject {
    @Published var ipAddress = ""
    @Published var isAnimating = false
    @Published var usernameID = ""
    @Published var informationMessage = ""

    @Published var bridgeSelectViewVisible = false
    @Published var isConnected = false
    @Published var canConnect = false

    var validIPAddressPublisher: AnyPublisher<Bool, Never> {
        $ipAddress
            .map { ip in
                let regex = try! NSRegularExpression(pattern: "\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b")
                let match = regex.firstMatch(in: ip, options: [], range: NSRange(location: 0, length: ip.utf16.count))
                return match != nil

            }
            .eraseToAnyPublisher()
    }

    var connectedPublisher: AnyPublisher<Bool, Never> {
        $usernameID
            .map { name in
                return name.count > 0
            }
            .eraseToAnyPublisher()
    }
}
