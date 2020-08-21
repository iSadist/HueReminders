import SwiftUI
import Combine

struct LightsListView: View {
    @FetchRequest(fetchRequest: HueBridge.findAll()) var bridges: FetchedResults<HueBridge>

    var body: some View {
        LightSectionView(bridges: bridges.sorted())
    }
}

struct LightSectionView: View {
    var bridges: [HueBridge]

    @ViewBuilder
    var body: some View {
        if bridges.isEmpty {
            EmptyView(text: "Connect to a Hue Bridge to see lights")
        } else {
            List {
                ForEach(bridges) { bridge in
                    Text(bridge.name!).font(.title)
                    LightListContentView(bridge: bridge)
                }
            }
        }
    }
}

struct LightListContentView: View {
    @ObservedObject var viewModel: LightListViewModel
    var bridge: HueBridge
    var lightsRequest: URLRequest
    
    init(bridge: HueBridge) {
        self.bridge = bridge
        self.lightsRequest = HueAPI.getLights(bridge: bridge)
        self.viewModel = LightListViewModel(request: self.lightsRequest)
    }

    @ViewBuilder
    var body: some View {
        if viewModel.lights.isEmpty {
            EmptyView(text: "No lights found")
        } else {
            ForEach(viewModel.lights) { light in
                LightRowView(light)
                    .onTapGesture {
                        HueAPI.toggleOnState(for: light, self.bridge)
                        self.viewModel.fetchData(request: self.lightsRequest)
                }
            }
        }
    }
}

struct LightsListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let bridge = HueBridge(context: context)
        bridge.name = "Test bridge"
        bridge.address = "192.168.1.2"
        return LightSectionView(bridges: [bridge])
    }
}
