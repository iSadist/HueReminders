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
            Text("\(light.name)")
                .onTapGesture {
                    guard let ip = self.bridge.address, let username = self.bridge.username else { return }
                    let url = URL(string: "http://\(ip)/api/\(username)/lights/\(light.id)/state")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "PUT"

                    let parameterDictionary = ["on": !light.on]
                    let httpBody = try! JSONSerialization.data(withJSONObject: parameterDictionary)
                    request.httpBody = httpBody

                    let task = URLSession.shared.dataTask(with: request)
                    task.resume()

                    self.viewModel.fetchData(request: self.lightsRequest)
            }

            Spacer()

            if light.on {
                Image(systemName: "lightbulb.fill")
                    .imageScale(.large)
                    .foregroundColor(.yellow)
            } else {
                Image(systemName: "lightbulb")
                    .imageScale(.large)
                    .foregroundColor(.gray)
            }
        }
    }
}
