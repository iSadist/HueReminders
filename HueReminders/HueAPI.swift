import Foundation

class HueAPI {
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

    static func getLights(bridge: HueBridge) {
        guard let ip = bridge.address, let id = bridge.username else { return }

        let url = URL(string: "http://\(ip)/\(id)/lights")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { (data, result, error) in
            print(data?.debugDescription)
        }
    }
}
