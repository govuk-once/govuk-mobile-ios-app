import Foundation
import GovKit

struct VehicleSpecData {
    let make: String
    let model: String?
    let dateOfFirstRegistration: Date
    let fuelType: FuelType
    let colour: String
    let secondaryColour: String?
    let engineCapacity: Int?
    let exhaustEmissionsCo2: Int?
    let shouldDisplayModelRow: Bool

    init(vehicle: VehicleEnquiryResponse.Vehicle) {
        self.make = vehicle.make
        self.model = nil
        self.dateOfFirstRegistration = vehicle.dateOfFirstRegistration
        self.fuelType = vehicle.fuelType
        self.colour = vehicle.colour
        self.secondaryColour = vehicle.secondaryColour
        self.engineCapacity = vehicle.engineCapacity
        self.exhaustEmissionsCo2 = vehicle.exhaustEmissionsCo2
        self.shouldDisplayModelRow = false
    }

    init(vehicle: CustomerVehicleDetails.Vehicle) {
        self.make = vehicle.make
        self.model = vehicle.model
        self.dateOfFirstRegistration = vehicle.dateOfFirstRegistration
        self.fuelType = vehicle.fuelType
        self.colour = vehicle.colour
        self.secondaryColour = vehicle.secondaryColour
        self.engineCapacity = vehicle.engineCapacity
        self.exhaustEmissionsCo2 = vehicle.exhaustEmissionsCo2
        self.shouldDisplayModelRow = true
    }
}
