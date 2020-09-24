import SwiftUI

struct BridgeRowView: View {
    @ObservedObject var viewModel: BridgeRowViewModel

    var body: some View {
        HStack {
            Text(viewModel.name)
            Text(viewModel.address)
            Spacer()
            
            if viewModel.isActive {
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
        let viewModel = BridgeRowViewModel(bridge)
        return BridgeRowView(viewModel: viewModel)
            .previewLayout(PreviewLayout.fixed(width: 300, height: 70))
    }
}
