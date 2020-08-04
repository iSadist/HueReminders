import Foundation

class HueAPI {
    static func connect(to ipaddress: String) -> URLRequest {
        let url = URL(string: "http://\(ipaddress)/api")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let parameterDictionary = ["devicetype": "huereminders"]
        let httpBody = try! JSONSerialization.data(withJSONObject: parameterDictionary)
        request.httpBody = httpBody
        return request
    }

    static func getLights(bridge: HueBridge) -> URLRequest {
        guard let ip = bridge.address, let id = bridge.username else { fatalError("Missing ip or username") }
        let url = URL(string: "http://\(ip)/api/\(id)/lights")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
}
