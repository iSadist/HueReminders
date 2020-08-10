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
    
    static func toggleOnState(for light: HueLightInfo, _ bridge: HueBridge) {
        guard let ip = bridge.address, let username = bridge.username else { return }
        let url = URL(string: "http://\(ip)/api/\(username)/lights/\(light.id)/state")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        let parameterDictionary = ["on": !light.on]
        let httpBody = try! JSONSerialization.data(withJSONObject: parameterDictionary)
        request.httpBody = httpBody

        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
    
    static func setSchedule(on bridge: HueBridge, reminder: Reminder) -> URLRequest {
        guard let ip = bridge.address, let id = bridge.username else { fatalError("Missing ip or username") }
        guard let time = reminder.time else { fatalError("Missing time on reminder") }
        let url = URL(string: "http://\(ip)/api/\(id)/schedules")!
        var request = URLRequest(url: url)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateString = formatter.string(from: time)
    
        let body = ["alert": "lselect"]
        let command = ["address": "/api/\(id)/lights/1/state", "method": "PUT", "body": body] as [String: Any]
        let parameters = [
            "name": reminder.name ?? "Timed trigger",
            "description": "Created by HueReminders app",
            "command": command,
            "autodelete": true,
            "localtime": dateString
            ] as [String: Any]
        
        let httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        request.httpBody = httpBody
        request.httpMethod = "POST"
        return request
    }
}
