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
    var interactor: BridgeSelectInteracting = BridgeSelectInteractor()
    
    var body: some View {
        NavigationView {
            List {
                if bridges.isEmpty {
                    EmptyView(text: NSLocalizedString("BRIDGE-SELECT_NO-BRIDGE", comment: ""))
                }
                ForEach(bridges) { bridge in
                    BridgeRowView(bridge)
                        .onTapGesture {
                            self.interactor.tap(on: bridge, list: self.bridges, context: self.managedObjectContext)
                    }
                }.onDelete { indexSet in
                    self.interactor.delete(indexSet: indexSet,
                                           bridges: self.bridges,
                                           context: self.managedObjectContext)
                }
            }
            .navigationBarTitle(NSLocalizedString("BRIDGE-SELECT_NAVIGATION-TITLE", comment: ""))
            .navigationBarItems(leading: EditButton(), trailing: NavigationLink(destination: ConnectView(), label: {
                Image(systemName: "plus")
                    .imageScale(.large)
            }))
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
