import Combine
import SwiftUI
import Foundation
import UIKit

typealias JSONValues = [String: HueLightResponse]

class LightListViewModel: ObservableObject {
    @Published var lights: [HueLightInfo] = []
    var lightsDataTask: AnyPublisher<[HueLightInfo], Never>?

    private var cancellables = Set<AnyCancellable>()

    init(request: URLRequest) {
        self.fetchData(request: request)
    }

    func fetchData(request: URLRequest) {
        lightsDataTask = URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: JSONValues.self, decoder: JSONDecoder())
            .map({ dictionary -> [HueLightInfo] in
                var lights: [HueLightInfo] = []
                for entry in dictionary {
                    let state = entry.value.state
                    let color = Color(hue: Double(state.hue) / 65535,
                                      saturation: Double(state.sat) / 255,
                                      brightness: 1)

                    lights.append(HueLightInfo(id: entry.key,
                                               name: entry.value.name,
                                               on: entry.value.state.on,
                                               color: color))
                }
                lights.sort()
                return lights
            })
            .replaceError(with: [HueLightInfo(id: "", name: "", on: false, color: .gray)])
            .eraseToAnyPublisher()

        lightsDataTask?
            .receive(on: DispatchQueue.main)
            .assign(to: \.lights, on: self)
            .store(in: &cancellables)
    }
}
