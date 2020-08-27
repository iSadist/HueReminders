//
//  CalendarConfigurationView.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-26.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI
import Combine

struct CalendarConfigurationListView: View {
    @FetchRequest(fetchRequest: HueBridge.findAll()) var bridges: FetchedResults<HueBridge>
    var interactor: CalendarConfigurationInteracting
    @State var model: CalendarRowModel

    var body: some View {
        CalendarConfigurationView(model: model, bridges: bridges.sorted(), interactor: self.interactor)
    }
}

struct CalendarConfigurationView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var model: CalendarRowModel
    var bridges: [HueBridge]
    var interactor: CalendarConfigurationInteracting
    
    func addLight(light: HueLightInfo) {
        if !self.model.lights.contains(where: { $0.lightID == light.id }) {
            let hueLight = HueLight(context: self.managedObjectContext)
            hueLight.lightID = light.id
            self.model.lights.insert(hueLight)
        } else {
            if let index = self.model.lights.firstIndex(where: { $0.lightID == light.id }) {
                self.model.lights.remove(at: index)
            }
        }
    }

    @ViewBuilder
    var body: some View {
        if bridges.isEmpty {
            EmptyView(text: "Connect to a Hue Bridge to see lights")
        } else {
            List {
                ForEach(bridges) { bridge in
                    Text(bridge.name!).font(.title)
                    CalendarConfigurationContentView(viewModel: CalendarConfigurationViewModel(bridge: bridge),
                                                     selectedLights: self.model.lights,
                                                     interactor: self.interactor,
                                                     onTap: self.addLight(light:))
                }
            }
        }
    }
}

struct CalendarConfigurationContentView: View {
    @ObservedObject var viewModel: CalendarConfigurationViewModel
    var selectedLights: Set<HueLight>
    var interactor: CalendarConfigurationInteracting
    var onTap: (HueLightInfo) -> Void

    @ViewBuilder
    var body: some View {
        if viewModel.lights.isEmpty {
            EmptyView(text: "No lights found")
        } else {
            ForEach(viewModel.lights) { light in
                CalendarConfigurationRowView(light, selected: self.selectedLights.contains(where: { $0.lightID == light.id }))
                    .onTapGesture {
                        self.onTap(light)
                    }
            }
        }
    }
}

struct CalendarConfigurationRowView: View {
    var light: HueLightInfo
    var selected: Bool = true
    
    init(_ light: HueLightInfo, selected: Bool) {
        self.light = light
        self.selected = selected
    }
    
    var body: some View {
        HStack {
            Text("\(light.name)")
            Spacer()
            
            if selected {
                Image(systemName: "checkmark.circle")
                    .imageScale(.large)
                    .foregroundColor(.green)
            } else {
                Image(systemName: "checkmark.circle")
                    .imageScale(.large)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

//struct CalendarConfigurationView_Previews: PreviewProvider {
//    static var previews: some View {
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        let bridge = HueBridge(context: context)
//        bridge.name = "Test bridge"
//        bridge.address = "192.168.1.2"
//        bridge.active = true
//        bridge.username = ""
//        return CalendarConfigurationView(model: , bridges: [bridge], interactor: CalendarConfigurationInterator())
//    }
//}
