//
//  LightRowView.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-06.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI

struct LightRowView: View {
    var light: HueLightInfo
    
    init(_ light: HueLightInfo) {
        self.light = light
    }
    
    var body: some View {
        HStack {
            Text("\(light.name)")
            Spacer()
            MultiColorCircle()
                .frame(width: 50.0)
                .onTapGesture {
                    print("Change the color now of \(self.light.name)")
                }
            
            if light.on {
                Image(systemName: "lightbulb.fill")
                    .imageScale(.large)
                    .foregroundColor(light.color)
            } else {
                Image(systemName: "lightbulb")
                    .imageScale(.large)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

struct LightRowView_Previews: PreviewProvider {
    static var previews: some View {
        LightRowView(HueLightInfo(id: "abcd1234", name: "Office lamp", on: true, color: .yellow))
            .previewLayout(.fixed(width: 300, height: 70))
    }
}
