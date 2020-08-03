//
//  MainContainerView.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-03.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI

enum MainTab: String {
    case Bridge, Reminders, Connect
}

struct MainContainerView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    private var initialView: MainTab = .Bridge
    @State private var selectedView: MainTab = .Bridge

    init(_ initialView: MainTab) {
        self.initialView = initialView
    }

    var body: some View {
        TabView(selection: $selectedView) {
            BridgeSelectView()
                .tabItem {
                    Image(systemName: "b.circle")
                    Text("Bridges")
                }
                .tag(MainTab.Bridge)
            RemindersListView()
                .tabItem {
                    Image(systemName: "alarm")
                    Text("Reminders")
                }
                .tag(MainTab.Reminders)
            ConnectView()
                .tabItem {
                    Image(systemName: "link")
                    Text("Connect")
                }
                .tag(MainTab.Connect)
        }.onAppear {
            self.selectedView = self.initialView
        }
    }
}

struct MainContainerView_Previews: PreviewProvider {
    static var previews: some View {
        MainContainerView(MainTab.Bridge)
    }
}
