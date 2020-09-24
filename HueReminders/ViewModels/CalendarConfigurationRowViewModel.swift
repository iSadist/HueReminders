import Foundation
import Combine
import EventKit
import UIKit

class CalendarConfigurationRowViewModel: ObservableObject {
    @Published var selected: Bool
    @Published var name: String
    
    init(light: HueLightInfo, selectedLights: Set<HueLight>) {
        name = light.name
        selected = selectedLights.contains(where: { $0.lightID == light.id })
    }
}
