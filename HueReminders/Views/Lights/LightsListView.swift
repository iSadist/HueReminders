import SwiftUI
import Combine

struct LightsListView: View {
    @FetchRequest(fetchRequest: HueBridge.findAll()) var bridges: FetchedResults<HueBridge>
    var interactor: LightListInteracting

    var body: some View {
        LightSectionView(bridges: bridges.sorted(), interactor: self.interactor)
    }
}

struct LightSectionView: View {
    var bridges: [HueBridge]
    var interactor: LightListInteracting

    @ViewBuilder
    var body: some View {
        if bridges.isEmpty {
            EmptyView(text: "Connect to a Hue Bridge to see lights")
        } else {
            List {
                ForEach(bridges) { bridge in
                    Text(bridge.name!).font(.title)
                    LightListContentView(bridge: bridge, interactor: self.interactor)
                }
            }
        }
    }
}

struct LightListContentView: View {
    @ObservedObject var viewModel: LightListViewModel
    var bridge: HueBridge
    var lightsRequest: URLRequest
    var interactor: LightListInteracting
    
    init(bridge: HueBridge, interactor: LightListInteracting) {
        self.interactor = interactor
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
                        self.interactor.lightRowTapped(light: light, bridge: self.bridge, viewModel: self.viewModel)
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
        bridge.username = ""
        return LightSectionView(bridges: [bridge], interactor: LightListInteractor())
    }
}
