import Foundation
import SwiftUI

struct EventCardStreamButton: View {
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 40, height: 40)
                .foregroundColor(AppColor.accentYellow)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            Image(systemName: "play.fill")
                .resizable()
                .frame(width: 14, height: 14)
                .foregroundStyle(Color.black)
        }
        .shadow(color: AppColor.accentYellow, radius: 7)
    }
}
