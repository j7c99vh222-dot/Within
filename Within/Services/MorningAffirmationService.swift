import Foundation
import UserNotifications

enum MorningAffirmationService {
    private static let notificationPrefix = "within.morning.affirmation"
    private static let daysToSchedule = 60

    static func refreshSchedule(profile: AccountProfile) async {
        guard await requestAuthorizationIfNeeded() else { return }

        let center = UNUserNotificationCenter.current()
        let pending = await pendingRequests()
        let oldIDs = pending
            .map(\.identifier)
            .filter { $0.hasPrefix(notificationPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: oldIDs)

        let calendar = Calendar.current
        let firstMorning = nextMorning(after: Date(), calendar: calendar)

        for offset in 0..<daysToSchedule {
            guard let date = calendar.date(byAdding: .day, value: offset, to: firstMorning) else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Within"
            content.body = AffirmationLibrary.affirmation(for: date, profile: profile)
            content.sound = .default

            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            components.second = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "\(notificationPrefix).\(dateStamp(for: date, calendar: calendar))", content: content, trigger: trigger)
            await add(request)
        }
    }

    private static func requestAuthorizationIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    continuation.resume(returning: granted)
                }
            }
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    private static func notificationSettings() async -> UNNotificationSettings {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                continuation.resume(returning: settings)
            }
        }
    }

    private static func pendingRequests() async -> [UNNotificationRequest] {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                continuation.resume(returning: requests)
            }
        }
    }

    private static func add(_ request: UNNotificationRequest) async {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().add(request) { _ in
                continuation.resume()
            }
        }
    }

    private static func nextMorning(after date: Date, calendar: Calendar) -> Date {
        let today = calendar.startOfDay(for: date)
        let todayMorning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: today) ?? date

        if todayMorning > date {
            return todayMorning
        }

        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? date
        return calendar.date(bySettingHour: 8, minute: 0, second: 0, of: tomorrow) ?? tomorrow
    }

    private static func dateStamp(for date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
    }
}
