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
            LightsListView(interactor: LightListInteractor())
                .tabItem {
                    Image(systemName: "lightbulb")
                    Text(NSLocalizedString("TAB-VIEW_TAB-LIGHT", comment: ""))
                }
                .tag(MainTab.Lights)
            RemindersListView()
                .tabItem {
                    Image(systemName: "alarm")
                    Text(NSLocalizedString("TAB-VIEW_TAB-REMINDERS", comment: ""))
                }
                .tag(MainTab.Reminders)
            SyncView(viewModel: SyncViewModel(), interactor: SyncInteractor())
                .tabItem {
                    Image(systemName: "arrow.2.circlepath")
                    Text(NSLocalizedString("TAB-VIEW_TAB-SYNC", comment: ""))
                }
                .tag(MainTab.Sync)
            BridgeSelectView()
                .tabItem {
                    Image(systemName: "gear")
                    Text(NSLocalizedString("TAB-VIEW_TAB-SETUP", comment: ""))
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
