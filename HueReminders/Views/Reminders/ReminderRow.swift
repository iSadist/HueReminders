import SwiftUI

struct ReminderRow: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var viewModel: ReminderRowViewModel
    var interactor: ReminderRowInteracting
    
    init(viewModel: ReminderRowViewModel) {
        self.viewModel = viewModel
        self.interactor = ReminderRowInteractor()
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.name)
                    .bold()
                HStack(alignment: .center, spacing: 10) {
                    Text(viewModel.day)
                    Text(viewModel.time)
                    Spacer()
                }
            }
            VStack(alignment: .trailing, spacing: 0) {
                Toggle(isOn: $viewModel.isActive) {
                    Text("").hidden()
                }.frame(alignment: .center)
                    .onTapGesture {
                        self.interactor.toggle(self.viewModel, context: self.managedObjectContext)
                }
            }
        }
        .padding()
        .background(viewModel.color) // TODO: Set the foreground color to either white or black depending on the background
        .cornerRadius(10)
    }
}

struct ReminderRow_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let reminder = Reminder(context: context)
        reminder.active = true
        reminder.color = HueColor.create(context: context, color: .red)
        reminder.day = 1
        reminder.name = "Reminder"
        reminder.time = Date()
        let bridge = HueBridge(context: context)
        let viewModel = ReminderRowViewModel(reminder, bridge)
        return ReminderRow(viewModel: viewModel)
            .previewLayout(.fixed(width: 400, height: 70))
    }
}
