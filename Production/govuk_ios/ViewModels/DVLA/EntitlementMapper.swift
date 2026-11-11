import Foundation

struct CategorisedEntitlements: Equatable {
    let entitledToDrive: [EntitlementGroup]
    let provisionallyEntitledToDrive: [EntitlementGroup]
}

protocol EntitlementMapping {
    func map(entitlements: [Entitlement]) -> CategorisedEntitlements
}

struct EntitlementMapper: EntitlementMapping {
    private let orderedGroups: [LicenceCategoryGroup] = [
        .mopeds,
        .motorcycles,
        .lightVehicles,
        .cars,
        .mediumSizedVehicles,
        .largeVehicles,
        .minibuses,
        .buses,
        .otherVehicles
    ]

    func map(entitlements: [Entitlement]) -> CategorisedEntitlements {
        CategorisedEntitlements(
            entitledToDrive: makeGroups(from: entitlements, type: .full),
            provisionallyEntitledToDrive: makeGroups(from: entitlements, type: .provisional)
        )
    }

    private func makeGroups(
        from entitlements: [Entitlement],
        type: CategoryType
    ) -> [EntitlementGroup] {
        let filtered = entitlements.filter { $0.categoryType == type }
        let groupedByGroup = Dictionary(grouping: filtered, by: \.group)

        return orderedGroups.compactMap { group in
            guard let matchedEntitlements =
                    groupedByGroup[group],
                    !matchedEntitlements.isEmpty else {
                return nil
            }
            return EntitlementGroup(group: group, entitlements: matchedEntitlements)
        }
    }
}

/* old
struct EntitlementMapper: EntitlementMapping {
    func map(entitlements: [Entitlement]) -> CategorisedEntitlements {
        CategorisedEntitlements(
            entitledToDrive: makeOrderedRows(from: entitlements, type: .full),
            provisionallyEntitledToDrive: makeOrderedRows(from: entitlements, type: .provisional)
        )
    }

    // MARK: - Private Helpers

    private func makeOrderedRows(
        from entitlements: [Entitlement],
        type: CategoryType
    ) -> [EntitlementRow] {
        let heldCodes = Set(
            entitlements
                .lazy
                .filter { $0.categoryType == type }
                .map { $0.categoryCode.uppercased() }
        )

        return catalogTemplate.compactMap { template in
            let heldInGroup = template.codes.filter { code in
                heldCodes.contains(code.uppercased())
            }

            guard !heldInGroup.isEmpty else { return nil }

            return EntitlementRow(
                title: template.group.title,
                codes: heldInGroup
            )
        }
    }

    // MARK: - Master Catalog (Ordered strictly per GOVUKAPP-4152)

    private var catalogTemplate: [(group: LicenceCategoryGroup, codes: [String])] {
        [
            (.mopeds, ["P", "AM", "Q"]),
            (.motorcycles, ["A", "A1", "A2"]),
            (.lightVehicles, ["B1"]),
            (.cars, ["B", "BE"]),
            (.mediumSizedVehicles, ["C1", "C1E"]),
            (.largeVehicles, ["C", "CE"]),
            (.minibuses, ["D1", "D1E"]),
            (.buses, ["D", "DE"]),
            (.otherVehicles, ["f", "G", "H", "k", "l", "M", "n"])
        ]
    }
}
 */
