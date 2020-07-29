import Foundation

class HueAPI { // TODO: Is there a way to do this with Combine instead?
    static func connect(to ipaddress: String, completion: @escaping (Data?, Error?) -> Void) {
        let url = URL(string: "http://\(ipaddress)/api")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let parameterDictionary = ["devicetype": "huereminders"]
        let httpBody = try! JSONSerialization.data(withJSONObject: parameterDictionary)
        request.httpBody = httpBody

        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            completion(data, error)
        }
        task.resume()
    }

    static func getLights(bridge: HueBridge) -> URLRequest {
        guard let ip = bridge.address, let id = bridge.username else { fatalError("Missing ip or username") }
        let url = URL(string: "http://\(ip)/api/\(id)/lights")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
}
