import Foundation
import SwiftUI
import Combine

struct NewReminderView: View {
    @FetchRequest(fetchRequest: HueBridge.findAll()) var bridges: FetchedResults<HueBridge>
    
    private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        // BUG: Does not update to the active bridge
        NewReminderViewContent(bridges: bridges.sorted())
    }
}

struct NewReminderViewContent: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var viewModel: NewReminderViewModel

    var bridges: [HueBridge]
    
    private var interactor: AddReminderInteracting
    private var cancellables = Set<AnyCancellable>()
    
    init(bridges: [HueBridge]) {
        self.bridges = bridges
        viewModel = NewReminderViewModel()
        interactor = AddReminderInteractor()
        
        // Setup subscriber
        viewModel.isNameValid
            .combineLatest(viewModel.selectedLightPublisher)
            .map { $0.0 && $0.1 }
            .receive(on: RunLoop.main)
            .assign(to: \.valid, on: viewModel)
            .store(in: &cancellables)
    }
    
    func addPressed() {
        guard let bridge = viewModel.bridge else {
            fatalError("A new reminder cannot be created without a connected bridge")
        }
        let color = UIColor(viewModel.color)

        interactor.add(managedObjectContext: managedObjectContext,
                       name: viewModel.name,
                       color: color,
                       day: Int16(viewModel.day),
                       time: viewModel.time,
                       bridge: bridge,
                       lightIDs: viewModel.selectedLights) { success in
                        if success {
                            self.presentation.wrappedValue.dismiss()
                        }
        }
    }
    
    var body: some View {
        Form {
            Section {
                TextField(NSLocalizedString("NEW-REMINDER_FIELD-NAME", comment: ""), text: $viewModel.name)
                    .autocapitalization(.none)
            }
            Section {
                ColorPicker(NSLocalizedString("NEW-REMINDER_FIELD-COLOR", comment: ""), selection: $viewModel.color)
            }
            Section {
                Picker(NSLocalizedString("NEW-REMINDER_FIELD-DAY", comment: ""), selection: $viewModel.day) {
                    ForEach(0 ..< WeekDay.allCases.count) { index in
                        Text(WeekDay.allCases[index].rawValue)
                    }
                }
            }
            Section {
                DatePicker(NSLocalizedString("NEW-REMINDER_FIELD-TIME", comment: ""),
                           selection: $viewModel.time,
                           displayedComponents: .hourAndMinute)
            }
            
            Section {
                Text(NSLocalizedString("NEW-REMINDER_BRIDGE-TITLE", comment: ""))
                    .bold()
                
                if bridges.isEmpty {
                    EmptyView(text: NSLocalizedString("NEW-REMINDER_BRIDGE-EMPTY", comment: ""))
                }
                
                ForEach(bridges) { bridge in
                    HStack {
                        Text(bridge.name ?? "")
                        Spacer()
                        
                        if bridge.name == self.viewModel.bridge?.name {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .onTapGesture {
                        self.interactor.select(bridge: bridge, self.viewModel)
                    }
                }
            }
            
            if self.viewModel.bridge != nil {
                Section {
                    Text(NSLocalizedString("NEW-REMINDER_LIGHTS-TITLE", comment: ""))
                        .bold()
                    
                    if self.viewModel.lights.isEmpty {
                        EmptyView(text: NSLocalizedString("NEW-REMINDER_LIGHTS-EMPTY", comment: ""))
                    }

                    ForEach(self.viewModel.lights) { light in
                        HStack {
                            Text("\(light.name)")
                                .onTapGesture {
                                    self.interactor.toggleLightSelectedState(self.viewModel, lightID: light.id)
                            }
                            Spacer()
                            
                            if self.viewModel.selectedLights.contains(light.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            
            Section {
                Button(action: addPressed) {
                    Text(NSLocalizedString("NEW-REMINDER_ADD-BUTTON-TEXT", comment: ""))
                        .bold()
                }.disabled(!viewModel.valid)
            }
        }.navigationBarTitle(NSLocalizedString("NEW-REMINDER_NAVIGATION-TITLE", comment: ""))
    }
}

struct NewReminderView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let bridge = HueBridge(context: context)
        bridge.active = true
        bridge.address = "192.168.1.2"
        bridge.name = "Bridge"
        bridge.username = "fe9c003c-a646-430f-a189-516620fc5555"
        return NewReminderViewContent(bridges: [bridge])
    }
}
