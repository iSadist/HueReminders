//
//  LightsListView.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-07-29.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI

struct LightsListView: View {
    var lights: [HueLight]
    
    init(_ lights: [String]) {
        self.lights = lights.map({ str -> HueLight in
            let hue = HueLight()
//            hue.name = str
            return hue
        })
    }
    
    var body: some View {
        List(lights) { light in
            Text("Hello")
        }
    }
}

struct LightsListView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
