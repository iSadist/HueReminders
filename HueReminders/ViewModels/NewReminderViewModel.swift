import Foundation
import Combine
import SwiftUI

class NewReminderViewModel: ObservableObject {
    // Input
    @Published var name = ""
    @Published var color: Color = .white
    @Published var day = 0
    @Published var time = Date()
    @Published var selectedLights: Set<String> = []
    @Published var lights: [HueLightInfo] = []
    @Published var bridge: HueBridge?

    // Output
    @Published var valid = true
    
    var isNameValid: AnyPublisher<Bool, Never> {
        $name
            .map { name in
                return name.count > 0
            }
            .eraseToAnyPublisher()
    }
    var lightsDataTask: AnyPublisher<[HueLightInfo], Never>?
    
    var selectedLightPublisher: AnyPublisher<Bool, Never> {
        $selectedLights
            .map { light in
                return light.count > 0
            }
            .eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()
    
    func fetchLights() {
        guard let bridge = self.bridge else { return }
        let request = HueAPI.getLights(bridge: bridge)
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
