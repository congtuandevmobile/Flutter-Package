import HealthKit

class WorkoutReader {
    
    // Read Workouts for Running, Cycling, Swimming, Walking
    func readRunningWorkouts(
        startTime: Int64,
        endTime: Int64,
        completion: @escaping (Result<[HealthWorkoutRecord], Error>) -> Void
    ) {
        let startDate = Date(timeIntervalSince1970: TimeInterval(startTime) / 1000)
        let endDate = Date(timeIntervalSince1970: TimeInterval(endTime) / 1000)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate, end: endDate, options: .strictStartDate)
        
        // Filter for multiple workout types
        let typePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            HKQuery.predicateForWorkouts(with: .running),
            HKQuery.predicateForWorkouts(with: .walking),
            HKQuery.predicateForWorkouts(with: .cycling),
            HKQuery.predicateForWorkouts(with: .swimming)
        ])
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, typePredicate])
        
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: .workoutType(),
            predicate: compoundPredicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] (query, samples, error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let workouts = samples as? [HKWorkout] else {
                completion(.success([]))
                return
            }
            
            let results = workouts.map { self?.mapToRecord($0) ?? HealthWorkoutRecord() }
            completion(.success(results))
        }
        
        HealthKitManager.shared.healthStore.execute(query)
    }
    
    private func mapToRecord(_ workout: HKWorkout) -> HealthWorkoutRecord {
        return HealthWorkoutRecord(
            uuid: workout.uuid.uuidString,
            activityType: mapActivityType(workout.workoutActivityType),
            startTime: Int64(workout.startDate.timeIntervalSince1970 * 1000),
            endTime: Int64(workout.endDate.timeIntervalSince1970 * 1000),
            duration: workout.duration,
            totalDistance: workout.totalDistance?.doubleValue(for: .meter()),
            totalEnergyBurned: workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()),
            sourceName: workout.sourceRevision.source.name,
            sourceId: workout.sourceRevision.source.bundleIdentifier,
            isIndoor: (workout.metadata?[HKMetadataKeyIndoorWorkout] as? Bool)
        )
    }

    private func mapActivityType(_ type: HKWorkoutActivityType) -> String {
        switch type {
        case .running: return "running"
        case .walking: return "walking"
        case .cycling: return "cycling"
        case .swimming: return "swimming"
        default: return "other"
        }
    }
}
