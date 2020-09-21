import SwiftUI
import Combine
import CoreGraphics

struct HueError: Codable {
    var type: Int
    var address: String
    var description: String
}

struct HueSuccess: Codable {
    var username: String
}

struct HueConnectResponse: Codable {
    var success: HueSuccess?
    var error: HueError?
}

struct ConnectView: View {
    @ObservedObject var connectViewModel = ConnectViewModel()
    @Environment(\.managedObjectContext) var managedObjectContext

    private var cancellables = Set<AnyCancellable>()

    init() {
        connectViewModel.validIPAddressPublisher
            .combineLatest(connectViewModel.validBridgeNamePublisher)
            .map { $0 && $1 }
            .receive(on: RunLoop.main)
            .assign(to: \.canConnect, on: connectViewModel)
            .store(in: &cancellables)
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 25) {
                Text(NSLocalizedString("CONNECT-VIEW_INSTRUCTION-TEXT", comment: ""))
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.secondary)
                Text(connectViewModel.informationMessage)
                    .font(.subheadline)

//                if connectViewModel.isLoading {
//                    ActivityIndicator()
//                        .frame(width: 25, height: 25)
//                        .foregroundColor(.orange)
//                } else {
//                    ActivityIndicator()
//                        .frame(width: 25, height: 25)
//                        .hidden()
//                }

                TextField(NSLocalizedString("CONNECT-VIEW_BRIDGE-NAME-FIELD", comment: ""),
                          text: $connectViewModel.bridgeName)
                TextField(NSLocalizedString("CONNECT-VIEW_BRIDGE-ADDRESS-FIELD", comment: ""),
                          text: $connectViewModel.ipAddress)
                Spacer()
                Button(action: {
                    self.connectViewModel.connect(request: HueAPI.connect(to: self.connectViewModel.ipAddress))
                }) {
                    Text(NSLocalizedString("CONNECT-VIEW_CONNECT-BUTTON-TEXT", comment: ""))
                }
                .disabled(!self.connectViewModel.canConnect)
            }
            .padding(25)
        }
    }
}

struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectView()
    }
}
