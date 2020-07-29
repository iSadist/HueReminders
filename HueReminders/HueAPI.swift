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

    static func getLights(bridge: HueBridge, completion: @escaping ([HueLight]) -> Void) {
        guard let ip = bridge.address, let id = bridge.username else { return }
        let url = URL(string: "http://\(ip)/api/\(id)/lights")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { (data, result, error) in
            guard let data = data else { return }
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            var lights: [HueLight] = []

            if let dict = json as? [String: Any] {
                for light in dict {

                    if let light = dict[light.key] as? [String: Any] {
                        let hueLight = HueLight()
                        hueLight.name = light["name"] as? String
                        lights.append(hueLight)
                    }
                }
            }
            completion(lights)
        }
        task.resume()
    }
}
