import SwiftUI

struct StaggeredFadeInModifier: ViewModifier {
    let index: Int
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(Double(index) * 0.1)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func staggeredFadeIn(index: Int) -> some View {
        self.modifier(StaggeredFadeInModifier(index: index))
    }
    
    func pressableEffect() -> some View {
        self.buttonStyle(PressableButtonStyle())
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
