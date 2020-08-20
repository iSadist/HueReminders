//
//  MainContainerView.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-03.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI

enum MainTab: String {
    case Lights, Setup, Sync, Reminders
}

struct MainContainerView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    private var initialView: MainTab = .Setup
    @State private var selectedView: MainTab = .Setup

    init(_ initialView: MainTab) {
        self.initialView = initialView
    }

    var body: some View {
        TabView(selection: $selectedView) {
            LightsListView()
                .tabItem {
                    Image(systemName: "lightbulb")
                    Text("Lights")
                }
                .tag(MainTab.Lights)
            RemindersListView()
                .tabItem {
                    Image(systemName: "alarm")
                    Text("Reminders")
                }
                .tag(MainTab.Reminders)
            SyncView()
                .tabItem {
                    Image(systemName: "arrow.2.circlepath")
                    Text("Sync")
                }
                .tag(MainTab.Sync)
            BridgeSelectView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Setup")
                }
                .tag(MainTab.Setup)
        }.onAppear {
            self.selectedView = self.initialView
        }
    }
}

struct MainContainerView_Previews: PreviewProvider {
    static var previews: some View {
        MainContainerView(MainTab.Setup)
    }
}
