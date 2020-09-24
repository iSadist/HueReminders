import SwiftUI
import Combine

struct CalendarConfigurationRowView: View {
    var viewModel: CalendarConfigurationRowViewModel
    
    init(_ viewModel: CalendarConfigurationRowViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            Text("\(viewModel.name)")
            Spacer()
            
            if viewModel.selected {
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
