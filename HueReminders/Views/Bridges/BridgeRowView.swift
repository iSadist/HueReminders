import SwiftUI

struct BridgeRowView: View {
    @ObservedObject private var bridge: HueBridge

    init(_ bridge: HueBridge) {
        self.bridge = bridge
    }

    var body: some View {
        HStack {
            Text(bridge.name ?? "")
            Text(bridge.address ?? "")
            Spacer()
            
            if bridge.active {
                Image(systemName: "checkmark.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(.green)
            }
        }
        .padding()
    }
}

struct BridgeRowView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let bridge = HueBridge(context: context)
        bridge.name = "Test bridge"
        bridge.address = "192.168.1.2"
        bridge.active = true
        return BridgeRowView(bridge)
            .previewLayout(PreviewLayout.fixed(width: 300, height: 70))
    }
}
