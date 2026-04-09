//
//  YoungConLiveActivityLiveActivity.swift
//  YoungConLiveActivity
//
//  Created by Сергей Мещеряков on 06.04.2026.
//

import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Lock screen & Dynamic Island

struct YoungConLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: EventLiveActivityAttributes.self) { context in
            EventLiveActivityView(state: context.state)
                .activityBackgroundTint(LiveActivityTheme.appBackground)
                .activitySystemActionForegroundColor(LiveActivityTheme.accentYellow)
        } dynamicIsland: { context in
            // Компактный трейлинг: не используем `Text(timerInterval:)` — он даёт длинную строку и разъезжается почти на всю ширину.
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .lineSpacing(2)
                        .truncationMode(.tail)
                        .minimumScaleFactor(0.62)
                        .allowsTightening(true)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .layoutPriority(1)
                        .padding(.leading, DynamicIslandExpandedLayout.horizontalInset)
                        .padding(.trailing, DynamicIslandExpandedLayout.laneSeparation)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        LivePulseIndicator(diameter: 7)
                        TimelineView(.periodic(from: .now, by: 30)) { timeline in
                            IslandMinutesLeftLabel(
                                end: context.state.endDate,
                                now: timeline.date,
                                fontSize: 10
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, DynamicIslandExpandedLayout.horizontalInset)
                    .padding(.leading, DynamicIslandExpandedLayout.laneSeparation)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 5) {
                        EventTimeProgressBar(
                            start: context.state.startDate,
                            end: context.state.endDate,
                            trackHeight: 2
                        )
                        islandMetaSingleLine(state: context.state)
                    }
                    .padding(.horizontal, DynamicIslandExpandedLayout.horizontalInset)
                }
            } compactLeading: {
                LivePulseIndicator(diameter: 8)
                    .fixedSize(horizontal: true, vertical: true)
            } compactTrailing: {
                TimelineView(.periodic(from: .now, by: 30)) { timeline in
                    IslandMinutesLeftLabel(
                        end: context.state.endDate,
                        now: timeline.date,
                        fontSize: 10
                    )
                }
                .fixedSize(horizontal: true, vertical: true)
            } minimal: {
                LivePulseIndicator(diameter: 6)
                    .fixedSize(horizontal: true, vertical: true)
            }
            .keylineTint(LiveActivityTheme.accentPurple)
        }
    }
}

// MARK: - Shared UI

/// В развёрнутом острове контент иначе упирается в радиус «капсулы» и обрезается по краям.
private enum DynamicIslandExpandedLayout {
    static let horizontalInset: CGFloat = 16
    static let laneSeparation: CGFloat = 8
}

private enum LiveActivityLayout {
    /// Система задаёт размер плашки — делаем воздух за счёт полей; контент держим компактным и в одной колонке.
    static let padH: CGFloat = 30
    static let padTop: CGFloat = 28
    static let padBottom: CGFloat = 28
    static let cardRadius: CGFloat = 20
    static let iconColumn: CGFloat = 19
    static let iconLabelGap: CGFloat = 8
    /// Единый шаг между строками «шкафчика».
    static let lineStep: CGFloat = 9
}

private struct EventLiveActivityView: View {
    let state: EventLiveActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: LiveActivityLayout.lineStep) {
            scheduleRow

            Text(state.title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
                .tracking(-0.12)
                .lineLimit(3)
                .minimumScaleFactor(0.88)
                .fixedSize(horizontal: false, vertical: true)

            EventTimeProgressBar(start: state.startDate, end: state.endDate)

            linearMetaRows(state: state)
        }
        .padding(.horizontal, LiveActivityLayout.padH)
        .padding(.top, LiveActivityLayout.padTop)
        .padding(.bottom, LiveActivityLayout.padBottom)
        .background {
            RoundedRectangle(cornerRadius: LiveActivityLayout.cardRadius, style: .continuous)
                .fill(LiveActivityTheme.cardBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: LiveActivityLayout.cardRadius, style: .continuous)
                        .strokeBorder(LiveActivityTheme.gray500.opacity(0.22), lineWidth: 1)
                }
        }
    }

    private var scheduleRow: some View {
        HStack(alignment: .center, spacing: 8) {
            timeRangeText(start: state.startDate, end: state.endDate)
            LivePulseIndicator()
            Spacer(minLength: 0)
        }
    }
}

private struct EventTimeProgressBar: View {
    let start: Date
    let end: Date
    var trackHeight: CGFloat = 3

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let now = context.date
            let span = end.timeIntervalSince(start)
            let progress: CGFloat = {
                guard span > 0 else { return 0 }
                let raw = now.timeIntervalSince(start) / span
                return CGFloat(min(max(raw, 0), 1))
            }()

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(LiveActivityTheme.gray500.opacity(0.32))
                    Capsule()
                        .fill(LiveActivityTheme.accentGradient)
                        .frame(width: max(geo.size.width * progress, progress > 0 ? 4 : 0))
                }
            }
            .frame(height: trackHeight)
        }
    }
}

private struct LivePulseIndicator: View {
    var diameter: CGFloat = 6

    var body: some View {
        // В extension Live Activity `withAnimation` в `onAppear` обычно не крутится — дышим через TimelineView.
        TimelineView(.periodic(from: .now, by: 0.12)) { context in
            let period = 2.5
            let t = context.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: period)
            let half = period / 2
            let opacity: CGFloat = {
                if t < half {
                    let p = CGFloat(t / half)
                    return 1 - p * (1 - 0.38)
                } else {
                    let p = CGFloat((t - half) / half)
                    return 0.38 + p * (1 - 0.38)
                }
            }()
            Circle()
                .fill(LiveActivityTheme.liveRed)
                .frame(width: diameter, height: diameter)
                .opacity(opacity)
        }
        .accessibilityLabel("Идёт сейчас")
    }
}

/// Короткий счётчик «минут до конца» — узкий, чтобы сложенный остров не растягивался.
private struct IslandMinutesLeftLabel: View {
    let end: Date
    let now: Date
    var fontSize: CGFloat = 10

    var body: some View {
        let sec = end.timeIntervalSince(now)
        let text: String = {
            if sec <= 0 { return "0m" }
            let minutes = max(1, Int(ceil(sec / 60)))
            if minutes >= 100 { return "99m" }
            return "\(minutes)m"
        }()
        return Text(text)
            .font(.system(size: fontSize, weight: .heavy, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(LiveActivityTheme.accentYellow)
            .accessibilityLabel("Минут до конца: \(text)")
    }
}

private func timeRangeText(start: Date, end: Date, fontSize: CGFloat = 14) -> some View {
    let style = Date.IntervalFormatStyle(date: .omitted, time: .shortened)
    let text: String = {
        guard end >= start else { return "—" }
        if end == start {
            return start.formatted(date: .omitted, time: .shortened)
        }
        return style.format(start ..< end)
    }()
    return Text(text)
        .font(.system(size: fontSize, weight: .bold))
        .monospacedDigit()
        .foregroundStyle(LiveActivityTheme.gray500)
}

/// Одна строка под прогрессом — меньше высоты, меньше обрезаний в развёрнутом острове.
private func islandMetaSingleLine(state: EventLiveActivityAttributes.ContentState) -> some View {
    let line: String = {
        if state.hostLine.isEmpty { return state.locationTitle }
        return "\(state.locationTitle) · \(state.hostLine)"
    }()
    return Text(line)
        .font(.system(size: 10, weight: .medium))
        .foregroundStyle(LiveActivityTheme.gray500.opacity(0.95))
        .lineLimit(1)
        .minimumScaleFactor(0.58)
        .frame(maxWidth: .infinity, alignment: .leading)
}

/// Одна колонка: иконка + строка, без подзаголовка «Спикер» — меньше уровней вложенности.
private func linearMetaRows(state: EventLiveActivityAttributes.ContentState) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        HStack(alignment: .firstTextBaseline, spacing: LiveActivityLayout.iconLabelGap) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(LiveActivityTheme.accentPurple)
                .frame(width: LiveActivityLayout.iconColumn, alignment: .center)

            Text(state.locationTitle)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(LiveActivityTheme.gray500.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }

        if !state.hostLine.isEmpty {
            HStack(alignment: .firstTextBaseline, spacing: LiveActivityLayout.iconLabelGap) {
                Image(systemName: "person.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(LiveActivityTheme.accentYellow)
                    .frame(width: LiveActivityLayout.iconColumn, alignment: .center)

                Text(state.hostLine)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.95))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Previews

private extension EventLiveActivityAttributes {
    static var preview: EventLiveActivityAttributes {
        EventLiveActivityAttributes(eventID: "preview-event")
    }
}

private extension EventLiveActivityAttributes.ContentState {
    static var preview: EventLiveActivityAttributes.ContentState {
        let start = Date().addingTimeInterval(-900)
        let end = Date().addingTimeInterval(1800)
        return EventLiveActivityAttributes.ContentState(
            title: "SwiftUI и WidgetKit: от идеи до продакшена",
            startDate: start,
            endDate: end,
            locationTitle: "Сцена А — конференц-зал",
            hostLine: "Анна Смирнова"
        )
    }
}

#Preview("Notification", as: .content, using: EventLiveActivityAttributes.preview) {
    YoungConLiveActivityLiveActivity()
} contentStates: {
    EventLiveActivityAttributes.ContentState.preview
}
