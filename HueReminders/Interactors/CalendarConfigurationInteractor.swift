import Foundation
import CoreData

protocol CalendarConfigurationInteracting {
    func lightRowTapped(light: HueLightInfo,
                        bridge: HueBridge,
                        model: CalendarRowModel,
                        context: NSManagedObjectContext)
}

class CalendarConfigurationInterator: CalendarConfigurationInteracting {
    func lightRowTapped(light: HueLightInfo,
                        bridge: HueBridge,
                        model: CalendarRowModel,
                        context: NSManagedObjectContext) {
        if !model.lights.contains(where: { $0.lightID == light.id }) {
            let hueLight = HueLight(context: context)
            hueLight.lightID = light.id
            hueLight.bridge = bridge
            bridge.addToLights(hueLight)
            model.lights.insert(hueLight)
        } else {
            if let index = model.lights.firstIndex(where: { $0.lightID == light.id }) {
                model.lights.remove(at: index)
            }
        }
    }
}
