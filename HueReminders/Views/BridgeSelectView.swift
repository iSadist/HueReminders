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
            List {
                ForEach(bridges) { bridge in
                    BridgeRowView(bridge)
                }.onDelete { indexSet in
                    let bridge = self.bridges[indexSet.first!]
                    self.managedObjectContext.delete(bridge)
                    try? self.managedObjectContext.save()
                }
                .onTapGesture {
                    print("tap")
                }
            }
            .navigationBarTitle("Hue Bridges")
            .navigationBarItems(leading: EditButton(), trailing: NavigationLink(destination: ConnectView()) {
                Text("Connect another")
            })
        }
    }
}

struct BridgeSelectView_Previews: PreviewProvider {
    static var previews: some View {
        BridgeSelectView()
    }
}