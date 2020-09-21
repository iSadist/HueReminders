//import SwiftUI
//
//struct ActivityIndicator: View {
//
//  @State private var isAnimating: Bool = false
//
//  var body: some View {
//    GeometryReader { (geometry: GeometryProxy) in
//      ForEach(0..<5) { index in
//        Circles(isAnimating: self.isAnimating, width: geometry.size.width, height: geometry.size.height)
//            .frame(width: geometry.size.width, height: geometry.size.height)
//            .rotationEffect(!self.isAnimating ? .degrees(0) : .degrees(360))
//            .animation(Animation
//              .timingCurve(0.5, 0.15 + Double(index) / 5, 0.25, 1, duration: 1.5)
//              .repeatForever(autoreverses: false))
//        }
//      }
//    .aspectRatio(1, contentMode: .fit)
//    .onAppear {
//        self.isAnimating = true
//    }
//  }
//}
//
//struct Circles: View {
//    var isAnimating: Bool = false
//    var width: CGFloat
//    var height: CGFloat
//    
//    var body: some View {
//        Group {
//          Circle()
//            .frame(width: width / 5, height: height / 5)
//            .scaleEffect(!isAnimating ? 1 - CGFloat(index) / 5 : 0.2 + CGFloat(index) / 5)
//            .offset(y: width / 10 - height / 2)
//        }
//    }
//}
//
//struct ActivityIndicator_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityIndicator()
//            .frame(width: 50, height: 50)
//            .foregroundColor(.orange)
//    }
//}
