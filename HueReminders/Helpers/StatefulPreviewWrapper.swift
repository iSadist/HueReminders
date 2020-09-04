//
//  StatefulPreviewWrapper.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-09-04.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content

    var body: some View {
        content($value)
    }

    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(wrappedValue: value)
        self.content = content
    }
}
