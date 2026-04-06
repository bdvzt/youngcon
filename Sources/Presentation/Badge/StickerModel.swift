import SwiftUI

struct Sticker: Identifiable, Equatable {
    let id: Int
    let name: String
    let icon: String
    let isUnlocked: Bool
    let bgColor: Color
    let fgColor: Color
    let description: String
}

extension Sticker {
    static let mockData: [Sticker] = [
        Sticker(
            id: 1,
            name: "Ранняя пташка",
            icon: "bolt.fill",
            isUnlocked: true,
            bgColor: AppColor.accentYellow,
            fgColor: .black,
            description: "Пришел на площадку в первые 30 минут после открытия фестиваля."
        ),
        Sticker(
            id: 2,
            name: "Слушатель",
            icon: "mic.fill",
            isUnlocked: true,
            bgColor: AppColor.accentPurple,
            fgColor: .white,
            description: "Посетил минимум 3 доклада и сохранил их в расписании."
        ),
        Sticker(
            id: 3,
            name: "Кофеман",
            icon: "cup.and.saucer.fill",
            isUnlocked: false,
            bgColor: AppColor.gray700,
            fgColor: AppColor.gray500,
            description: "Забрал фирменный кофе в партнерской зоне и отсканировал бейдж."
        ),
        Sticker(
            id: 4,
            name: "Нетворкер",
            icon: "person.2.fill",
            isUnlocked: true,
            bgColor: AppColor.accentPink,
            fgColor: .black,
            description: "Познакомился с 5 участниками и обменялся контактами в приложении."
        ),
        Sticker(
            id: 5,
            name: "Квест пройден",
            icon: "star.fill",
            isUnlocked: false,
            bgColor: AppColor.gray700,
            fgColor: AppColor.gray500,
            description: "Закрыл все задания квеста и нашел секретную локацию на карте."
        ),
        Sticker(
            id: 6,
            name: "Оффер в кармане!",
            icon: "briefcase.fill",
            isUnlocked: false,
            bgColor: AppColor.gray700,
            fgColor: AppColor.gray500,
            description: "Успешно прошел Fast Track и получил приглашение на собеседование."
        ),
    ]
}
