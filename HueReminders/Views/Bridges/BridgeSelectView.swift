//
//  BridgeSelectView.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-07-26.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI

struct BridgeSelectView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: HueBridge.findAll()) var bridges: FetchedResults<HueBridge>

    var body: some View {
        BridgeSelectViewContent(bridges: bridges.sorted())
    }
}

struct BridgeSelectViewContent: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    var bridges: [HueBridge]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(bridges) { bridge in
//                    NavigationLink(destination: LightsListView(HueAPI.getLights(bridge: bridge), hueBridge: bridge),
//                                   tag: bridge.name ?? "",
//                                   selection: self.setActive()) {
//                    }
                    BridgeRowView(bridge)
                        .onTapGesture {
                            self.bridges.forEach { $0.active = false }
                            bridge.active = true
                            try? self.managedObjectContext.save()
                    }
                }.onDelete { indexSet in
                    let bridge = self.bridges[indexSet.first!]
                    self.managedObjectContext.delete(bridge)
                    try? self.managedObjectContext.save()
                }
            }
            .navigationBarTitle("Hue Bridges")
            .navigationBarItems(leading: EditButton())
        }
    }
}

struct BridgeSelectView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let bridge = HueBridge(context: context)
        bridge.address = "192.168.1.2"
        bridge.name = "Office bridge"
        bridge.username = "abcd1234"
        
        let bridge2 = HueBridge(context: context)
        bridge2.address = "192.168.1.3"
        bridge2.name = "Second bridge"
        bridge2.username = "abcd12345"
        bridge2.active = true
        
        return BridgeSelectViewContent(bridges: [bridge, bridge2])
    }
}
