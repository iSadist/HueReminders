import Foundation

class BridgeRowViewModel: ObservableObject {
    @Published var name: String
    @Published var address: String
    @Published var isActive: Bool
    
    init(_ bridge: HueBridge) {
        name = bridge.name ?? ""
        address = bridge.address ?? ""
        isActive = bridge.active
    }
}
