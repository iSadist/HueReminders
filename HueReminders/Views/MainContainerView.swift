//
//  MainContainerView.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-03.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI

struct MainContainerView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    private var initialView: Int = 0
    @State private var selectedView: Int = 0

    init(selectedView: Int) {
        self.initialView = selectedView
    }

    var body: some View {
        TabView(selection: $selectedView) {
            BridgeSelectView()
                .tabItem {
                    Image(systemName: "1.circle")
                    Text("Bridges")
                }
                .tag(0)
            ConnectView()
                .tabItem {
                    Image(systemName: "2.circle")
                    Text("Connect")
                }
                .tag(1)
        }.onAppear {
            self.selectedView = self.initialView
        }
    }
}

struct MainContainerView_Previews: PreviewProvider {
    static var previews: some View {
        MainContainerView(selectedView: 1)
    }
}
