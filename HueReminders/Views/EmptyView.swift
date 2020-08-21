//
//  EmptyView.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-21.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI

struct EmptyView: View {
    var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .imageScale(.large)
                .foregroundColor(.red)
            Text(text).font(.caption)
        }
    }
}

struct EmptyView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView(text: "Nothing found")
    }
}
