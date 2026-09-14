import SwiftUI
import GovKitUI

struct VehicleSummaryView: View {
    let viewModel: VehicleSummaryViewModel

    private static let standardPadding: CGFloat = 16.0
    private static let iconSize: CGFloat = 36.0

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Text(viewModel.vehicleMake)
                .font(.govUK.title1Bold)
                .multilineTextAlignment(.leading)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding(.top, Self.standardPadding)
                .padding(.horizontal, Self.standardPadding)
            Text(viewModel.vehicleModel)
                .font(.govUK.title3)
                .multilineTextAlignment(.leading)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding(.horizontal, Self.standardPadding)
                .padding(.vertical, 8)
            TaxValidityStatusView(viewModel: viewModel.taxStatusViewModel)
            Divider()
                .overlay(Color(uiColor: .govUK.strokes.listDivider))
                .padding(.horizontal, Self.standardPadding)
                .padding(.vertical, 8)
            ValidityStatusView(viewModel: viewModel.motStatusViewModel)
            Divider()
                .overlay(Color(uiColor: .govUK.strokes.listDivider))
                .padding(.top, 8)
            detailsButton
        }
    }

    private var headerView: some View {
        HStack {
            Text(viewModel.registrationNumber)
                .font(.govUK.vehicleRegistrationMarkBody)
                .foregroundStyle(Color.black)
                .padding([.top, .leading, .trailing], 7)
                .padding(.bottom, 4)
                .background(Color(uiColor: GOVUKColors.Fills.registrationPlate))
                .roundedBorder(
                    cornerRadius: 7,
                    borderColor: .black
                )
                .accessibilityLabel(registrationNumberAccessibilityLabel)
            Spacer()
            menuView
        }
        .padding(.top, Self.standardPadding)
        .padding(.bottom, 8)
        .padding(.horizontal, Self.standardPadding)
    }

    private var menuView: some View {
        Menu {
            ForEach(viewModel.menuItems, id: \.id) { item in
                Button(
                    action: { item.openURLAction(item.title) },
                    label: {
                        Text(item.title)
                            .accessibilityLabel(item.accessibilityLabel ?? item.title)
                            .accessibilityHint(String.common.localized("openWebLinkHint"))
                    }
                )
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.govUK.title1Bold)
                .frame(
                    minWidth: Self.iconSize,
                    minHeight: Self.iconSize
                )
                .foregroundColor(Color(UIColor.govUK.text.link))
        }
        .accessibilityLabel(String.dvla.localized("moreOptionsButtonAccessibilityLabel"))
    }

    private var detailsButton: some View {
        Button {
            viewModel.detailAction()
        } label: {
            HStack {
                Text(String.dvla.localized("detailsButtonTitle"))
                    .font(Font.govUK.body)
                    .foregroundStyle(Color(uiColor: .govUK.text.primary))
                    .multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(UIColor.govUK.text.link))
                    .font(Font.govUK.bodySemibold)
                    .frame(width: Self.iconSize)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, Self.standardPadding)
        }
    }

    private var registrationNumberAccessibilityLabel: Text {
        Text(viewModel.regNumberAccessibilityLabelPrefix)
        + Text(viewModel.registrationNumber.lowercased()).speechSpellsOutCharacters()
    }
}

#if DEBUG

struct MockAppConfigService: AppConfigServiceInterface {
    func fetchAppConfig() async -> FetchAppConfigResult {
        // Replace `.success` with your preferred default FetchAppConfigResult case if needed
        fatalError("Unimplemented: fetchAppConfig()")
    }

    func isFeatureEnabled(key: Feature) -> Bool {
        false
    }

    var chatPollIntervalSeconds: TimeInterval { 0 }
    var alertBanner: AlertBanner? { nil }
    var chatBanner: ChatBanner? { nil }
    var promoBanners: [PromoBanner]? { nil }
    var emergencyBanners: [EmergencyBanner]? { nil }
    var chatUrls: ChatURLs? { nil }
    var dvlaUrls: DvlaURLs? { nil }
    var refreshTokenExpirySeconds: Int? { nil }
    var termsAndConditions: TermsAndConditions? { nil }
}

import GovKit

public struct MockAnalyticsService: AnalyticsServiceInterface {
    public init() {}

    public func launch() {}
    public func track(event: AppEvent) {}
    public func track(screen: TrackableScreen) {}
    public func track(error: Error) {}
    public func set(userProperty: UserProperty) {}
    public func resetConsent() {}

    public func setAcceptedAnalytics(accepted: Bool) {}
    public func setExistingConsent() {}

    public var permissionState: AnalyticsPermissionState {
        // Replace with your preferred default AnalyticsPermissionState case if needed
        fatalError("Unimplemented: permissionState")
    }
}

let testData: [CustomerVehicles.Vehicle] = [
    // expired | untaxed
    CustomerVehicles.Vehicle(vehicleId: 102088978,
                             registrationNumber: "VX58 ABK",
                             make: "VAUXHALL",
                             model: "WYVERN",
                             motStatus: "No details held by DVLA",
                             taxStatus: .untaxed,
                             dateOfLiability: nil,
                             sornStart: nil,
                             taxedUntil: DVLAServiceClient.arrange("12/12/2026"),
                             motExpiryDate: DVLAServiceClient.arrange("12/12/2030"),
                             currentLicencePaymentMethod: nil),
    // not taxed for road use: not needed | no tax to pay
    CustomerVehicles.Vehicle(vehicleId: 102088979,
                             registrationNumber: "VX58 ABK",
                             make: "VAUXHALL",
                             model: "WYVERN",
                             motStatus: "No details held by DVLA",
                             taxStatus: .notTaxedForOnRoadUse,
                             dateOfLiability: nil,
                             sornStart: nil,
                             taxedUntil: nil,
                             motExpiryDate: nil,
                             currentLicencePaymentMethod: nil),
    // unknown | not found -  contact dvla
    CustomerVehicles.Vehicle(vehicleId: 102088981,
                             registrationNumber: "VX58 ABK",
                             make: "VAUXHALL",
                             model: "WYVERN",
                             motStatus: "No details held by DVLA",
                             taxStatus: nil,
                             dateOfLiability: nil,
                             sornStart: nil,
                             taxedUntil: nil,
                             motExpiryDate: nil,
                             currentLicencePaymentMethod: nil),
]
#endif // DEBUG

#Preview {
    let standardPadding: CGFloat = 16.0
    let iconSize: CGFloat = 36.0

    var viewModel: VehicleSummaryViewModel = {
        let mockVehicle = testData[0]

        return VehicleSummaryViewModel(
            vehicle: mockVehicle,
            detailAction: {},
            openURLAction: { _ in },
            configService: MockAppConfigService(),
            analyticsService: MockAnalyticsService()
        )
    }()

    var taxValidityStatusView: some View = {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                Text("taxValidity title")
                    .font(.govUK.title3Semibold)
                    .multilineTextAlignment(.leading)
                    .accessibilityAddTraits(.isHeader)
//              statusTextView
                }
                Spacer()
            }

            Text("taxValidity footer")
                .font(.govUK.footnote)
                .foregroundStyle(Color(uiColor: .govUK.text.secondary))
                .padding(.top, standardPadding)
                .padding(.bottom, 8)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
        .padding(standardPadding)
    }()

    VStack(spacing: 0) {
//        headerView
        Text(viewModel.vehicleMake)
            .font(.govUK.title1Bold)
            .multilineTextAlignment(.leading)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding(.top, standardPadding)
            .padding(.horizontal, standardPadding)
        Text(viewModel.vehicleModel)
            .font(.govUK.title3)
            .multilineTextAlignment(.leading)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding(.horizontal, standardPadding)
            .padding(.vertical, 8)
        Text("TaxValidityStatusView")
        taxValidityStatusView
        TaxValidityStatusView(viewModel: viewModel.taxStatusViewModel)
        Divider()
            .overlay(Color(uiColor: .govUK.strokes.listDivider))
            .padding(.horizontal, standardPadding)
            .padding(.vertical, 8)
        ValidityStatusView(viewModel: viewModel.motStatusViewModel)
        MotValidityStatusView(viewModel: viewModel.motStatusViewModel)

        Divider()
            .overlay(Color(uiColor: .govUK.strokes.listDivider))
            .padding(.top, 8)
//        detailsButton
        Button {
        } label: {
            HStack {
                Text(String.dvla.localized("detailsButtonTitle"))
                    .font(Font.govUK.body)
                    .foregroundStyle(Color(uiColor: .govUK.text.primary))
                    .multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(UIColor.govUK.text.link))
                    .font(Font.govUK.bodySemibold)
                    .frame(width: iconSize)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, standardPadding)
        }
    }
}
