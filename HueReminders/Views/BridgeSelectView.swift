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
        NavigationView {
            VStack {
                List(bridges) { bridge in
                    BridgeRowView(bridge, onRemove: { username in
                        if let item = self.bridges.first(where: { $0.username == username }) {
                            self.managedObjectContext.delete(item)
                        }
                    })
                }
            }
        }
    }
}

struct BridgeSelectView_Previews: PreviewProvider {
    static var previews: some View {
        BridgeSelectView()
    }
}
