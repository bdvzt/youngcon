//
//  BottomNavBar.swift
//  app
//
//  Created by m.yaganova on 02.04.2026.
//

import SwiftUI

struct BottomNavBar: View {
    @Binding var activeTab: AppTab

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 0.5)

            HStack(alignment: .bottom) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    TabItemView(
                        tab: tab,
                        isActive: activeTab == tab
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            activeTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 28)
            .background(
                Color(hex: "#0A0B12")
                    .opacity(0.85)
                    .background(.ultraThinMaterial)
            )
        }
    }
}

struct TabItemView: View {
    let tab: AppTab
    let isActive: Bool
    let action: () -> Void

    private let activeColor   = Color(hex: "#FCFF72")
    private let inactiveColor = Color(hex: "#6B7280")

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    if isActive {
                        Ellipse()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        activeColor.opacity(0.55),
                                        activeColor.opacity(0)
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 26
                                )
                            )
                            .frame(width: 52, height: 28)
                            .blur(radius: 6)
                    }

                    Image(systemName: tab.icon)
                        .font(.system(size: 22, weight: isActive ? .semibold : .regular))
                        .foregroundColor(isActive ? activeColor : inactiveColor)
                        .shadow(
                            color: isActive ? activeColor.opacity(0.6) : .clear,
                            radius: 6
                        )
                }
                .frame(width: 44, height: 32)

                Text(tab.label)
                    .font(.system(size: 10, weight: .bold))
                    .kerning(0.8)
                    .textCase(.uppercase)
                    .foregroundColor(isActive ? activeColor : inactiveColor)
            }
            .offset(y: isActive ? -4 : 0)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color(hex: "#0A0B12").ignoresSafeArea()
        BottomNavBar(activeTab: .constant(.schedule))
    }
    .ignoresSafeArea(edges: .bottom)
}
