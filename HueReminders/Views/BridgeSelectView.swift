//
//  BridgeSelectView.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-07-26.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI

struct Bridge: Identifiable {
    var id = UUID()
    var name = ""
    var username = ""
}

struct BridgeRow: View {
    var body: some View {
        Text("Sample text")
    }
}

struct BridgeSelectView: View {
    @State var bridges: [Bridge] = []
    
    init(bridges: [Bridge]) {
        self.bridges = bridges
    }
    
    var body: some View {
        VStack {
            Text("Bridges")
            List(bridges) { bridge in
                Text(bridge.name)
            }
        }
    }
}

struct BridgeSelectView_Previews: PreviewProvider {
    static var previews: some View {
        BridgeSelectView(bridges: [])
    }
}
