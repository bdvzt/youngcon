//
//  EventCardStreamButton.swift
//  YoungCon
//
//  Created by Сергей Мещеряков on 02.04.2026.
//

import Foundation
import SwiftUI

struct EventCardStreamButton: View {
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 50, height: 50)
                .foregroundColor(Theme.primary)
                .clipShape(RoundedRectangle(cornerRadius: 19))
            Image(systemName: "play.fill")
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundStyle(Color.black)
        }
        .shadow(color: Theme.primary, radius: 7)
    }
        
}

#Preview {
    EventCardStreamButton()
}
