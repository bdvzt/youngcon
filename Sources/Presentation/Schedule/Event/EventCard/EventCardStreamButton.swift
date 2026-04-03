import Foundation
import SwiftUI

struct EventCardStreamButton: View {
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 40, height: 40)
                .foregroundColor(Color("AccentYellow"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            Image(systemName: "play.fill")
                .resizable()
                .frame(width: 14, height: 14)
                .foregroundStyle(Color.black)
        }
        .shadow(color: Color("AccentYellow"), radius: 7)
    }
}

#Preview {
    EventCardStreamButton()
}
