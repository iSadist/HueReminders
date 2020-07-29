import Combine
import Foundation

struct HueLightInfo: Identifiable {
    var id: String
    var name: String
}

struct HueLightResponse: Decodable {
//    var state: Any
//    var swupdate: Any
    var type: String
    var name: String
    var modelid: String
    var manufacturername: String
    var productname: String
//    var capabilities: Any
//    var config: Any
    var uniqueid: String
    var swversion: String
}

typealias JSONValues = [String: HueLightResponse]

class LightListViewModel: ObservableObject {
    @Published var lights: [HueLightInfo] = []
    var lightsDataTask: AnyPublisher<[HueLightInfo], Never>

    init(request: URLRequest) {
        lightsDataTask = URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: JSONValues.self, decoder: JSONDecoder())
            .map({ dictionary -> [HueLightInfo] in
                var lights: [HueLightInfo] = []
                for entry in dictionary {
                    lights.append(HueLightInfo(id: entry.key, name: entry.value.name))
                }
                return lights
            })
            .replaceError(with: [HueLightInfo(id: "", name: "")])
            .eraseToAnyPublisher()
    }
}
