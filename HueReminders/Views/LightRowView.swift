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
            
            if light.on {
                Image(systemName: "lightbulb.fill")
                    .imageScale(.large)
                    .foregroundColor(.yellow)
            } else {
                Image(systemName: "lightbulb")
                    .imageScale(.large)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct LightRowView_Previews: PreviewProvider {
    static var previews: some View {
        LightRowView(HueLightInfo(id: "abcd1234", name: "Office lamp", on: false))
            .previewLayout(.fixed(width: 300, height: 70))
    }
}
