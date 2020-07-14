//
//  ConnectView.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-07-13.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI
import CoreGraphics

struct ConnectView: View {

    @State var ipAddress = ""
    @State var isAnimating = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 15) {
                if isAnimating {
                    ActivityIndicator()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.orange)
                }
                
                Button(action: {
                    print("Find the hue bridge now!")
                    self.ipAddress = "123.45.678.90"
                    self.isAnimating = !self.isAnimating
                }) {
                    Text("Connect to Hue Bridge")
                }
                
                TextField("Hue Bridge address", text: $ipAddress)
            }
        }.navigationBarTitle("Connect")
    }
}

struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectView()
    }
}
