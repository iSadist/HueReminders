//
//  ProgressBar.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-09-04.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI

struct ProgressBar: View {
    @Binding var value: Float

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 15, alignment: .center)
                    .foregroundColor(Color(UIColor.lightGray))
                    .opacity(0.25)
                Rectangle()
                    .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width),
                           height: 15,
                           alignment: .leading)
                    .foregroundColor(.blue)
            }
            .cornerRadius(50)
        }
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(0.5) { ProgressBar(value: $0) }
    }
}
