import Foundation

/// A collection of driving entitlements grouped under a single vehicle category.
struct EntitlementGroup: Identifiable, Equatable {
    var id: LicenceCategoryGroup { group }
    let group: LicenceCategoryGroup
    let entitlements: [Entitlement]
}

/// Driving entitlements partitioned into full and provisional licence groups.
struct CategorisedEntitlements: Equatable {
    let entitledToDrive: [EntitlementGroup]
    let provisionallyEntitledToDrive: [EntitlementGroup]
}

/// A type that groups and orders raw driving entitlements into categorised collections.
protocol EntitlementMapping {
    /// Partitions and orders the given entitlements into full and provisional category groups.
    func map(entitlements: [Entitlement]) -> CategorisedEntitlements
}

/// Maps flat driving entitlements into ordered category groups matching the predefined catalog specification.
struct EntitlementMapper: EntitlementMapping {
    func map(entitlements: [Entitlement]) -> CategorisedEntitlements {
        CategorisedEntitlements(
            entitledToDrive: makeOrderedGroups(from: entitlements, type: .full),
            provisionallyEntitledToDrive: makeOrderedGroups(from: entitlements, type: .provisional)
        )
    }

    private func makeOrderedGroups(
        from entitlements: [Entitlement],
        type: CategoryType
    ) -> [EntitlementGroup] {
        let filtered = entitlements.filter { $0.categoryType == type }
        let entitlementsByCode = Dictionary(
            grouping: filtered,
            by: { $0.categoryCode.uppercased() }
        )

        return catalogTemplate.compactMap { template in
            // Preserve the catalog's exact code ordering within each group
            let matchingEntitlements = template.codes.compactMap { code in
                entitlementsByCode[code.uppercased()]?.first
            }

            guard !matchingEntitlements.isEmpty else { return nil }

            return EntitlementGroup(
                group: template.group,
                entitlements: matchingEntitlements
            )
        }
    }

    // Master Catalog (Ordered strictly per GOVUKAPP-4152)
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
