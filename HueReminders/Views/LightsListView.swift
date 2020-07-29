import SwiftUI
import Combine

struct LightsListView: View {
    @ObservedObject var viewModel: LightListViewModel

    private var cancellables = Set<AnyCancellable>()

    init(_ request: URLRequest) {
        viewModel = LightListViewModel(request: request)
        viewModel.lightsDataTask
            .receive(on: DispatchQueue.main)
            .assign(to: \.lights, on: viewModel)
            .store(in: &cancellables)
    }

    var body: some View {
        List(viewModel.lights) { light in
            Text("\(light.id) \(light.name)")
        }
    }
}

struct LightsListView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
