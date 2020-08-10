import SwiftUI
import Combine

struct LightsListView: View {
    @ObservedObject var viewModel: LightListViewModel

    private var bridge: HueBridge
    private var lightsRequest: URLRequest

    init(_ request: URLRequest, hueBridge: HueBridge) {
        lightsRequest = request
        bridge = hueBridge
        viewModel = LightListViewModel(request: request)
    }

    var body: some View {
        List(viewModel.lights) { light in
            LightRowView(light)
                .onTapGesture {
                    HueAPI.toggleOnState(for: light, self.bridge)
                    self.viewModel.fetchData(request: self.lightsRequest)
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
        return LightsListView(URLRequest(url: URL(string: "http://someurl.com")!), hueBridge: bridge)
    }
}
