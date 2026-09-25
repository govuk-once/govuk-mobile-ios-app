#if DEBUG

extension CustomerVehicles.Vehicle {
    /// Holds sample vehicles for Previews
    struct PreviewsData {
        /// A sample collection of vehicles representing various tax and MOT statuses.
        static var collection: [CustomerVehicles.Vehicle] =
        [
            .arrange(
                vehicleId: 1,
                registrationNumber: "AB71 CDE",
                make: "MITSUBISHI",
                model: "MIRAGE",
                taxStatus: .taxed,
                taxedUntil: .arrange("15/09/2030"),
                motStatus: "Valid",
                motExpiryDate: .arrange("15/09/2030")
            ),
            .arrange(
                vehicleId: 2,
                registrationNumber: "XY19 ZAB",
                make: "LAND ROVER",
                model: "RANGE ROVER SPORT",
                taxStatus: .sorn,
                motStatus: "Not valid",
                motExpiryDate: .arrange("01/03/2024"),
                sornStart: .arrange("01/01/2025")
            ),
            .arrange(
                vehicleId: 3,
                registrationNumber: "MN65 PQR",
                make: "VOLKSWAGEN",
                model: "GOLF",
                taxStatus: .untaxed,
                motStatus: "Valid",
                motExpiryDate: .arrange("20/11/2030")
            ),
        ]

        /// A sample Tesla vehicle instance with valid tax and MOT for standalone preview use.
        static var teslaVehicle: CustomerVehicles.Vehicle = .arrange(
            vehicleId: 1,
            registrationNumber: "FG23 HIJ",
            make: "TESLA",
            model: "MODEL 3",
            taxStatus: .taxed,
            taxedUntil: .arrange("01/04/2031"),
            motStatus: "Valid",
            motExpiryDate: .arrange("01/04/2031")
        )
    }
}

#endif // DEBUG

