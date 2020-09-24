import SwiftUI
import Foundation
import CoreData

protocol BridgeSelectInteracting {
    func tap(on bridge: HueBridge, list: [HueBridge], context: NSManagedObjectContext)
    func delete(indexSet: IndexSet, bridges: [HueBridge], context: NSManagedObjectContext)
    func destination() -> AnyView
}

class BridgeSelectInteractor: BridgeSelectInteracting {
    func tap(on bridge: HueBridge, list: [HueBridge], context: NSManagedObjectContext) {
        list.forEach { $0.active = false }
        bridge.active = true
        try? context.save()
    }
    
    func delete(indexSet: IndexSet, bridges: [HueBridge], context: NSManagedObjectContext) {
        let bridge = bridges[indexSet.first!]
        context.delete(bridge)
        try? context.save()
    }
    
    func destination() -> AnyView {
        AnyView(ConnectView())
    }
}
