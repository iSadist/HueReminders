//
//  ConnectView.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-07-13.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

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
    @FetchRequest(fetchRequest: HueBridge.findAll()) var bridges: FetchedResults<HueBridge>

    private var cancellables = Set<AnyCancellable>()

    init() {
        connectViewModel.connectedPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isConnected, on: connectViewModel)
            .store(in: &cancellables)
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("Before you can start to set reminders you need to connect to a Hue Bridge")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.secondary)
                Text(connectViewModel.informationMessage)
                    .font(.subheadline)
                    .padding(EdgeInsets(top: 25, leading: 0, bottom: 0, trailing: 0))

                if connectViewModel.isAnimating {
                    ActivityIndicator()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.orange)
                } else {
                    ActivityIndicator()
                        .frame(width: 25, height: 25)
                        .hidden()
                }

                TextField("Hue Bridge address", text: $connectViewModel.ipAddress)
                    .padding(EdgeInsets(top: 0, leading: 25, bottom: 25, trailing: 25))
                Spacer()
                Button(action: {
                    self.connectViewModel.isAnimating = true
                    HueAPI.connect(to: self.connectViewModel.ipAddress, completion: { (data, error) in
                        // TODO: State should not be updated on the main thread
                        self.connectViewModel.isAnimating = false
                        guard let data = data else {
                            self.connectViewModel.informationMessage = "Could not connect"
                            return
                        }
                        if let dataResponses = try? JSONDecoder().decode([HueConnectResponse].self, from: data) {
                            let firstResponse = dataResponses.first

                            if let error = firstResponse?.error {
                                switch error.type {
                                case 101:
                                    self.connectViewModel.informationMessage = "The link button was not pressed"
                                default:
                                    self.connectViewModel.informationMessage = "Unknown error in response"
                                }
                            } else if let username = firstResponse?.success?.username {
                                self.connectViewModel.usernameID = username
                                self.connectViewModel.isConnected = true
                                self.connectViewModel.informationMessage = "Connection successful"

                                let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
                                let context = appDelegate.persistentContainer.viewContext
                                let bridge = HueBridge(context: context)
                                bridge.username = self.connectViewModel.usernameID
                                bridge.address = self.connectViewModel.ipAddress
                                bridge.name = "Bridge \(self.bridges.count)"
                                try? context.save()
                            }
                        } else {
                            self.connectViewModel.informationMessage = "Could not connect"
                        }
                    })
                }) {
                    Text("Connect")
                }
                Spacer()
            }
            Spacer()
        }
    }
}

struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectView()
    }
}
