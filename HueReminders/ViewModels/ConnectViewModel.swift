import UIKit
import Combine

class ConnectViewModel: ObservableObject {
    @Published var ipAddress = ""
    @Published var isLoading = false
    @Published var bridgeName = ""
    @Published var informationMessage = ""

    @Published var bridgeSelectViewVisible = false
    @Published var canConnect = false
    
    var connectDataTask: AnyPublisher<String, Never>?
    
    private var cancellables = Set<AnyCancellable>()

    var validIPAddressPublisher: AnyPublisher<Bool, Never> {
        $ipAddress
            .map { ip in
                let regex = try! NSRegularExpression(pattern: "\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b")
                let match = regex.firstMatch(in: ip, options: [], range: NSRange(location: 0, length: ip.utf16.count))
                return match != nil

            }
            .eraseToAnyPublisher()
    }
    
    var validBridgeNamePublisher: AnyPublisher<Bool, Never> {
        $bridgeName
            .map { name in
                return name.count > 0
            }
            .eraseToAnyPublisher()
    }
    
    func connect(request: URLRequest) {
        self.isLoading = true
        connectDataTask = URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: [HueConnectResponse].self, decoder: JSONDecoder())
            .map({ dictionary -> String in
                let firstResponse = dictionary.first
                var message = ""
                
                if let error = firstResponse?.error {
                    switch error.type {
                    case 101:
                        message = "The link button was not pressed"
                    default:
                        message = "Unknown error in response"
                    }
                } else if let username = firstResponse?.success?.username {
                    message = "Connection successful"

                    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
                    let context = appDelegate.persistentContainer.viewContext
                    let bridge = HueBridge(context: context)
                    bridge.username = username
                    bridge.address = self.ipAddress
                    bridge.name = self.bridgeName
                    bridge.active = true

                    try? context.fetch(HueBridge.findAll())
                        .forEach { $0.active = false } // Only one bridge should be active
                    try? context.save()
                }
                
                return message
            })
            .replaceError(with: "Could not connect")
            .eraseToAnyPublisher()
        
        connectDataTask?
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { message in
                self.informationMessage = message
                self.isLoading = false
            })
            .store(in: &cancellables)
    }
}
