import SwiftUI

struct BridgeRowView: View {
    private var bridge: HueBridge

    init(_ bridge: HueBridge) {
        self.bridge = bridge
    }

    var body: some View {
        HStack {
            Text(bridge.name ?? "")
            Text(bridge.address ?? "")
            Spacer()
        }
    }
}
