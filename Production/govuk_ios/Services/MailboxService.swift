import Foundation

protocol MailboxServiceInterface {
    var isEnabled: Bool { get }
    var unopenedCount: Int { get }
    func fetchMessages(
        completion: @escaping (Result<[MailboxMessage], Error>) -> Void
    )
    func markAsOpened(
        messageId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func deleteMessage(
        messageId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func markAsUnopened(
        messageId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func updateActionStatus(
        messageId: String,
        status: ActionStatus,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

// swiftlint:disable:next type_body_length
final class MailboxService: MailboxServiceInterface {
    var isEnabled: Bool { true }

    private var messages: [MailboxMessage] = MailboxService.mockMessages

    var unopenedCount: Int {
        messages.filter { $0.status == .unopened }.count
    }

    func fetchMessages(
        completion: @escaping (Result<[MailboxMessage], Error>) -> Void
    ) {
        completion(.success(messages))
    }

    func markAsOpened(
        messageId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            messages[index].status = .opened
        }
        completion(.success(()))
    }

    func deleteMessage(
        messageId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        messages.removeAll { $0.id == messageId }
        completion(.success(()))
    }

    func markAsUnopened(
        messageId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            messages[index].status = .unopened
        }
        completion(.success(()))
    }

    func updateActionStatus(
        messageId: String,
        status: ActionStatus,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            messages[index].actionStatus = status
        }
        completion(.success(()))
    }

    // MARK: - Mock Data

    private static var mockMessages: [MailboxMessage] {
        [
            MailboxMessage(
                id: "msg-001",
                sender: .dvla,
                subject: "Your vehicle tax is due",
                body: """
                Vehicle tax reminder

                Your vehicle tax is due for renewal.

                Vehicle: AB12 CDE
                Make and model: Ford Focus
                Tax due date: 1 August 2026

                You must tax your vehicle before you can \
                drive it on public roads. If you do not \
                renew your tax, your vehicle could be \
                clamped, removed or you could receive a \
                fine of up to \u{00A3}1,000.

                Tax rates for your vehicle:
                - 12 months: \u{00A3}190.00
                - 6 months: \u{00A3}104.50
                - Direct Debit (monthly): \u{00A3}16.63/month

                You can tax your vehicle using the GOV.UK \
                app or online at gov.uk/vehicle-tax.

                You will need:
                - Your V11 reminder letter (ref number)
                - A valid MOT (if your vehicle needs one)
                - Payment by debit/credit card or \
                Direct Debit

                Driver and Vehicle Licensing Agency
                """,
                receivedDate: .now.addingTimeInterval(-1800),
                status: .unopened,
                previewText: "Your vehicle tax for AB12 CDE is due " +
                    "for renewal by 1 August 2026.",
                actions: [
                    .payment(
                        title: "Pay vehicle tax",
                        amount: 19000,
                        reference: "AB12 CDE"
                    ),
                    .openURL(
                        title: "Apply for a SORN",
                        url: URL(string: "https://www.gov.uk/make-a-sorn")!
                    )
                ],
                actionStatus: .paymentPending
            ),
            MailboxMessage(
                id: "msg-001b",
                sender: .dvla,
                subject: "Vehicle tax payment confirmed",
                body: """
                Payment confirmation

                Your vehicle tax payment has been received \
                and processed.

                Vehicle: XY67 ZAB
                Make and model: Volkswagen Golf
                Amount paid: \u{00A3}180.00
                Payment date: 10 July 2026
                Tax valid until: 1 August 2027

                Your vehicle is now taxed. You do not need \
                to display a tax disc.

                If you need to check your vehicle tax status \
                at any time, you can do so at \
                gov.uk/check-vehicle-tax.

                Driver and Vehicle Licensing Agency
                """,
                receivedDate: .now.addingTimeInterval(-86_400 * 2),
                status: .opened,
                previewText: "Your vehicle tax payment of " +
                    "\u{00A3}180.00 for XY67 ZAB has been confirmed.",
                actionStatus: .paid
            ),
            MailboxMessage(
                id: "msg-002",
                sender: .dvla,
                subject: "Your driving licence renewal reminder",
                body: """
                Dear user,

                Your driving licence is due for renewal \
                within the next 3 months. To avoid any \
                disruption, we recommend starting the \
                renewal process now.

                You can renew your licence using the \
                GOV.UK app or online. You will need:
                - Your current driving licence
                - A valid UK passport (to update your photo)
                - Addresses where you have lived over the \
                last 3 years

                The renewal fee is \u{00A3}14.00 when done online.

                If you have any medical conditions that may \
                affect your driving, please declare these \
                during the renewal process.

                Kind regards,
                Driver and Vehicle Licensing Agency
                """,
                receivedDate: .now.addingTimeInterval(-3600),
                status: .unopened,
                previewText: "Your driving licence is due for " +
                    "renewal within the next 3 months.",
                actions: [
                    .applyInApp(
                        title: "Renew your licence",
                        destination: .dvlaRenewLicence
                    )
                ],
                actionStatus: .actionRequired
            ),
            MailboxMessage(
                id: "msg-003",
                sender: .hmrc,
                subject: "Your Self Assessment tax return is due",
                body: """
                Important reminder

                Your Self Assessment tax return for the \
                2024 to 2025 tax year is due by \
                31 January 2026.

                If you file online, you have until \
                midnight on 31 January. If you miss the \
                deadline, you may have to pay a penalty.

                What you need to do:
                1. Gather your income records
                2. Log in to your HMRC online account
                3. Complete and submit your return
                4. Pay any tax owed

                If you need help, you can contact our \
                Self Assessment helpline or use the \
                GOV.UK guidance pages.

                HM Revenue & Customs
                """,
                receivedDate: .now.addingTimeInterval(-86_400),
                status: .unopened,
                previewText: "Your Self Assessment tax return " +
                    "for 2024-25 is due by 31 January 2026."
            ),
            MailboxMessage(
                id: "msg-004",
                sender: .govuk,
                subject: "New service updates for your saved topics",
                body: """
                Based on your saved topics, here are the \
                latest updates:

                - Benefits: Universal Credit payments will \
                increase in April 2026
                - Transport: New clean air zones announced \
                for 3 cities
                - Housing: Right to Buy discount amounts \
                updated

                You can manage your topic preferences in \
                the app settings. We send these updates \
                weekly based on changes to GOV.UK content \
                that matches your interests.

                GOV.UK Notify
                """,
                receivedDate: .now.addingTimeInterval(-5 * 86_400),
                status: .opened,
                previewText: "Based on your saved topics, " +
                    "here are the latest updates."
            ),
            MailboxMessage(
                id: "msg-005",
                sender: .manchesterCouncil,
                subject: "Waste collection schedule change",
                body: """
                Due to the upcoming bank holiday, your \
                waste collection schedule will change for \
                the week of 25 August 2026.

                Revised schedule:
                - General waste: collected Wednesday \
                (instead of Tuesday)
                - Recycling: collected Thursday \
                (instead of Wednesday)
                - Garden waste: collected Friday \
                (instead of Thursday)

                Please ensure your bins are out by 7:00 AM \
                on the revised day.

                If your bin is not collected, please allow \
                an additional working day before reporting \
                a missed collection.

                Manchester City Council Waste Services
                """,
                receivedDate: .now.addingTimeInterval(-9 * 86_400),
                status: .opened,
                previewText: "Due to the upcoming bank holiday, " +
                    "your waste collection schedule will change."
            ),
            MailboxMessage(
                id: "msg-006",
                sender: .dwp,
                subject: "Your benefit payment confirmation",
                body: """
                Your payment has been processed.

                Payment details:
                - Amount: \u{00A3}368.74
                - Payment date: 15 July 2026
                - Paid to: Account ending 4521

                This covers the period from 1 July to \
                14 July 2026.

                If the amount looks incorrect, or you have \
                not received the payment within 3 working \
                days, please contact us.

                You can view your full payment history in \
                your online journal.

                Department for Work and Pensions
                """,
                receivedDate: .now.addingTimeInterval(-12 * 86_400),
                status: .unopened,
                previewText: "Your payment of \u{00A3}368.74 has " +
                    "been processed for 15 July 2026."
            ),
            MailboxMessage(
                id: "msg-007",
                sender: .hmrc,
                subject: "Your tax code has changed",
                body: """
                We have updated your tax code for the \
                2026-27 tax year.

                Your new tax code: 1257L
                Effective from: 6 April 2026
                Employer: Acme Ltd

                This tax code means you can earn \
                \u{00A3}12,570 before paying tax. Your \
                employer will use this code to calculate \
                the tax on your pay.

                If you think this is wrong, you can check \
                your income tax estimate online or \
                contact us.

                HM Revenue & Customs
                """,
                receivedDate: .now.addingTimeInterval(-18 * 86_400),
                status: .opened,
                previewText: "We have updated your tax code " +
                    "to 1257L for the 2026-27 tax year."
            )
        ]
    }
}
