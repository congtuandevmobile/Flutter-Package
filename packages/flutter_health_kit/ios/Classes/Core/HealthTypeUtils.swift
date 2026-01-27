import HealthKit

class HealthTypeUtils {
    
    static func getTypeIdentifier(from key: String) -> HKQuantityTypeIdentifier? {
        switch key {
        case "steps": return .stepCount
        case "distance_walking_running": return .distanceWalkingRunning
        case "distance_cycling": return .distanceCycling
        case "distance_swimming": return .distanceSwimming
        case "flights_climbed": return .flightsClimbed
        case "active_energy": return .activeEnergyBurned
        case "basal_energy": return .basalEnergyBurned
            
        case "heart_rate": return .heartRate
        case "oxygen_saturation": return .oxygenSaturation 
        case "blood_pressure_systolic": return .bloodPressureSystolic
        case "body_temperature": return .bodyTemperature

        // Running Specific
        case "vo2_max": return .vo2Max
        case "running_speed":
            if #available(iOS 16.0, *) {
                return .runningSpeed
            } else {
                return nil
            }
        case "running_power":
            if #available(iOS 16.0, *) {
                return .runningPower
            } else {
                return nil
            }
            
        default: return nil
        }
    }

    static func getUnit(for type: HKQuantityTypeIdentifier) -> HKUnit {
        switch type {
        case .heartRate: return HKUnit.count().unitDivided(by: .minute())
        case .oxygenSaturation: return HKUnit.percent()
        case .activeEnergyBurned, .basalEnergyBurned: return HKUnit.kilocalorie()
        case .distanceWalkingRunning, .distanceCycling, .distanceSwimming: return HKUnit.meter()
        case .bodyTemperature: return HKUnit.degreeCelsius()
        case .vo2Max: return HKUnit(from: "ml/kg/min")
        default:
            // Handle iOS 16+ specific units safely
            if #available(iOS 16.0, *), type == .runningPower {
                return HKUnit.watt()
            }
            if #available(iOS 16.0, *), type == .runningSpeed {
                return HKUnit.meter().unitDivided(by: .second())
            }
            return HKUnit.count()
        }
    }
    
    static func getAllSupportedTypes() -> Set<HKObjectType> {
        let identifiers: [HKQuantityTypeIdentifier] = [
            .stepCount,
            .distanceWalkingRunning,
            .distanceCycling,
            .distanceSwimming,
            .flightsClimbed,
            .activeEnergyBurned,
            .heartRate,
            .oxygenSaturation,
            .bodyTemperature,
            .vo2Max
        ]
        
        let types = identifiers.compactMap { HKObjectType.quantityType(forIdentifier: $0) }
        var typeSet = Set<HKObjectType>(types)

        // Add Workout Type
        typeSet.insert(HKObjectType.workoutType())
        
        // Add Route Type
        typeSet.insert(HKSeriesType.workoutRoute())

        if #available(iOS 16.0, *) {
            if let speed = HKObjectType.quantityType(forIdentifier: .runningSpeed) {
                typeSet.insert(speed)
            }
            if let power = HKObjectType.quantityType(forIdentifier: .runningPower) {
                typeSet.insert(power)
            }
        }

        return typeSet
    }
}