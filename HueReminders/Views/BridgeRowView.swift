import SwiftUI

struct BridgeRowView: View {
    private var bridge: HueBridge
    private var onRemove: (String) -> Void

    init(_ bridge: HueBridge, onRemove: @escaping ((String) -> Void)) {
        self.bridge = bridge
        self.onRemove = onRemove
    }
    
    var body: some View {
        HStack {
            Text(bridge.name ?? "")
            Text(bridge.address ?? "")
            Spacer()
            Button(action: {
                self.onRemove(self.bridge.username ?? "")
            }) {
                Text("Remove")
                    .foregroundColor(.red)
            }
        }
    }
}
