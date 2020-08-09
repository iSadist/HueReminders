//
//  MultiColorCircle.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-06.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI

struct MultiColorCircle: View {
    var body: some View {
        ZStack {
            Circle().foregroundColor(.red)
            Circle().foregroundColor(.orange).scaleEffect(0.8)
            Circle().foregroundColor(.yellow).scaleEffect(0.6)
            Circle().foregroundColor(.green).scaleEffect(0.4)
            Circle().foregroundColor(.blue).scaleEffect(0.2)
        }
    }
}

struct MultiColorCircle_Previews: PreviewProvider {
    static var previews: some View {
        MultiColorCircle()
    }
}
