import SwiftUI

struct EventDetailedCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                Text("11:30 - 13:00")
                    .foregroundColor(.white.opacity(1))
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.4))
                
                
            )
            
            Text("ОТКРЫТИЕ YOUNGCON:\nБУДУЩЕЕ БИГТЕХА")
                .foregroundColor(.white)
                .font(.system(size: 30, weight: .black))
            
            HStack(spacing: 8) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.purple)
                
                Text("LIVE Арена (Главная)")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.4))
            )
            
            Text("Ежегодное открытие фестиваля. Поговорим о том, куда движутся технологии, какие навыки будут востребованы через 5 лет и как ИИ меняет наши продукты прямо сейчас.")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(6)
            
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.27, green: 0.28, blue: 0.45))
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .frame(width: 96, height: 96)
                    
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 34, weight: .regular))
                        .foregroundColor(.white.opacity(0.55))
                }
                
                VStack(alignment: .leading, spacing: 6){
                    Text("Топ-менеджмент Яндекса")
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .black))
                    
                    Text("Ключевые спикеры")
                        .foregroundColor(.yellow.opacity(0.7))
                        .font(.system(size: 16, weight: .medium))
                }
                
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.4))
            )
        }
        
        
        
        
        
        
        
        .padding(24)
        .frame(width: 420, height: 540)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(red: 0.06, green: 0.07, blue: 0.16))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 30, y: 12)
        
    }
}

#Preview {
    EventDetailedCard()
}
