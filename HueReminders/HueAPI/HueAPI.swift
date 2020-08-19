import Foundation
import UIKit

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
    
    static func toggleActive(for reminder: Reminder, _ bridge: HueBridge) {
        guard let lights = reminder.light as? Set<HueLight> else { fatalError("Missing lights") }
        for light in lights {
            guard let ip = bridge.address, let username = bridge.username else { fatalError("Missing ip or username") }
            guard let scheduleID = light.scheduleID else { fatalError("Missing schedule ID on Reminder") }
            let url = URL(string: "http://\(ip)/api/\(username)/schedules/\(scheduleID)/")!
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            
            let parameterDictionary = ["status": reminder.active ? "enabled" : "disabled"]
            let httpBody = try! JSONSerialization.data(withJSONObject: parameterDictionary)
            request.httpBody = httpBody
            
            let task = URLSession.shared.dataTask(with: request)
            task.resume()
        }
    }
    
    static func setSchedule(on bridge: HueBridge, reminder: Reminder, light: HueLight) -> URLRequest {
        guard let ip = bridge.address, let id = bridge.username else { fatalError("Missing ip or username") }
        guard let time = reminder.time else { fatalError("Missing time on reminder") }
        guard let lightID = light.lightID else { fatalError("Missing light id")}
        let url = URL(string: "http://\(ip)/api/\(id)/schedules")!
        var request = URLRequest(url: url)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateString = formatter.string(from: time)
        
        var hue: CGFloat = 0
        var sat: CGFloat = 0
        var bri: CGFloat = 0
        var alpha: CGFloat = 0

        let color = ReminderColor.allCases[Int(reminder.color)].getColor()
        color.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
        
        // Convert to Hue API values
        hue *= 65535
        sat *= 254
        bri *= 254
        
        print("\(hue) \(sat) \(bri) \(alpha)")
    
        let body = ["on": true, "hue": Int(hue), "sat": Int(sat), "bri": Int(bri)] as [String: Any]
        let command = ["address": "/api/\(id)/lights/\(lightID)/state", "method": "PUT", "body": body] as [String: Any]
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
    
    static func deleteSchedule(on bridge: HueBridge, reminder: Reminder) -> [URLRequest] {
        var requests = [URLRequest]()
        guard let lights = reminder.light as? Set<HueLight> else { fatalError("Missing lights") }
        for light in lights {
            guard let ip = bridge.address, let id = bridge.username else { fatalError("Missing ip or username") }
            guard let scheduleID = light.scheduleID else { continue }
            let url = URL(string: "http://\(ip)/api/\(id)/schedules/\(scheduleID)")!
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            requests.append(request)
        }
        
        return requests
    }
}
