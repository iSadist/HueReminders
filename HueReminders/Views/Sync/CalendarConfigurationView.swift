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
    
    func onTapped(light: HueLightInfo, bridge: HueBridge) {
        interactor.lightRowTapped(light: light, bridge: bridge, model: model, context: managedObjectContext)
    }

    @ViewBuilder
    var body: some View {
        if bridges.isEmpty {
            EmptyView(text: NSLocalizedString("SYNC_CONFIGURATION_NO-BRIDGES", comment: ""))
        } else {
            List {
                ForEach(bridges) { bridge in
                    if self.bridges.count > 1 {
                        Text(bridge.name!).font(.title)
                    }
                    CalendarConfigurationContentView(viewModel: CalendarConfigurationViewModel(bridge: bridge),
                                                     bridge: bridge,
                                                     selectedLights: self.model.lights,
                                                     interactor: self.interactor,
                                                     onTap: self.onTapped(light:bridge:))
                }.navigationBarTitle(model.title)
            }
        }
    }
}

struct CalendarConfigurationContentView: View {
    @ObservedObject var viewModel: CalendarConfigurationViewModel
    var bridge: HueBridge
    var selectedLights: Set<HueLight>
    var interactor: CalendarConfigurationInteracting
    var onTap: (HueLightInfo, HueBridge) -> Void

    @ViewBuilder
    var body: some View {
        if viewModel.lights.isEmpty {
            EmptyView(text: NSLocalizedString("SYNC_CONFIGURATION_NO-LIGHTS", comment: ""))
        } else {
            ForEach(viewModel.lights) { light in
                CalendarConfigurationRowView(light,
                                             selected: self.selectedLights.contains(where: { $0.lightID == light.id }))
                    .onTapGesture {
                        self.onTap(light, self.bridge)
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
