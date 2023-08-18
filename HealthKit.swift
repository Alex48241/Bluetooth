

import UIKit
import HealthKit

//Read heart rate and body Temperature
class HealthKitManager {
    
    public var healthKitStore = HKHealthStore()
    
    func authorizationRequestHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        // 1
        if !HKHealthStore.isHealthDataAvailable() {
            let error = NSError(domain: "", code: 999,
                                userInfo: [NSLocalizedDescriptionKey : "Healthkit not available on this device"])
            completion(false, error)
            print("HealthKit not available on this device")
            return
        }
        
        
        // 2
        if #available(iOS 14.0, *) {
            let readTypes: Set<HKSampleType> = [HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyTemperature)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.respiratoryRate)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceCycling)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.basalEnergyBurned)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)!,HKObjectType.electrocardiogramType()]
            
            let writeTypes: Set<HKSampleType> = [HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyTemperature)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.respiratoryRate)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceCycling)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.basalEnergyBurned)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)!]
            
            healthKitStore.requestAuthorization(toShare: writeTypes, read: readTypes) { (success: Bool, error: Error?) in
                completion(success, error)
            }
        } else {
            let readTypes: Set<HKSampleType> = [HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyTemperature)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.respiratoryRate)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceCycling)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.basalEnergyBurned)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)!]
            
            let writeTypes: Set<HKSampleType> = [HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyTemperature)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.respiratoryRate)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceCycling)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.basalEnergyBurned)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)!]
            
            healthKitStore.requestAuthorization(toShare: writeTypes, read: readTypes) { (success: Bool, error: Error?) in
                
                completion(success, error)
            }
            
            
        }
        
        
    }
    
    
    func saveBloodPressureMeasurement(systolic: Int, diastolic: Int, heartRate: Int, completion: @escaping (Bool, Error?) -> Void) {
            // 1
            let startDate = Date()
            let endDate = startDate
            // 2
            let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!
            let systolicQuantity = HKQuantity(unit: HKUnit.millimeterOfMercury(), doubleValue: Double(systolic))
            let systolicSample = HKQuantitySample(type: systolicType, quantity: systolicQuantity, start: startDate, end: endDate)
            let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!
            let diastolicQuantity = HKQuantity(unit: HKUnit.millimeterOfMercury(), doubleValue: Double(diastolic))
            let diastolicSample = HKQuantitySample(type: diastolicType, quantity: diastolicQuantity, start: startDate, end: endDate)
            // 3
            let bpCorrelationType = HKCorrelationType.correlationType(forIdentifier: .bloodPressure)!
            let bpCorrelation = Set<HKSample>(arrayLiteral: systolicSample, diastolicSample)
            let bloodPressureSample = HKCorrelation(type: bpCorrelationType , start: startDate, end: endDate, objects: bpCorrelation)
            // 4
            let beatsCountUnit = HKUnit.count()
            let heartRateQuantity = HKQuantity(unit: beatsCountUnit.unitDivided(by: HKUnit.minute()), doubleValue: Double(heartRate))
            let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
            let heartRateSample = HKQuantitySample(type: heartRateType, quantity: heartRateQuantity, start: startDate, end: endDate)
            // 5
            healthKitStore.save([bloodPressureSample, heartRateSample]) { (success: Bool, error: Error?) in
                completion(success, error)
            }
        }
    
    func getAllVitals() -> [VitalModel] {
        var items = [VitalModel]()
    
        let heartRate:HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let dd = VitalModel.init(name:"Heart Rate" , quantityType: heartRate)
        items.append(dd)
        
        let bodyTemperature:HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyTemperature)!
        let dd1 = VitalModel.init(name:"Body Temperature" , quantityType: bodyTemperature)
        items.append(dd1)
        
        let respiratoryRate:HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.respiratoryRate)!
        let dd2 = VitalModel.init(name:"Respiratory Rate" , quantityType: respiratoryRate)
        items.append(dd2)
        
        let bloodPressureSystolic:HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic)!
        let dd3 = VitalModel.init(name:"Blood Pressure Systolic" , quantityType: bloodPressureSystolic)
        items.append(dd3)
        
        let bloodPressureDiastolic:HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic)!
        let dd4 = VitalModel.init(name:"Blood Pressure Diastolic" , quantityType: bloodPressureDiastolic)
        items.append(dd4)
        
        let stepCount:HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        let dd5 = VitalModel.init(name:"Step Count" , quantityType: stepCount)
        items.append(dd5)
        
        let distanceWalkingRunning:HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
        let dd6 = VitalModel.init(name:"Distance Walking Running" , quantityType: distanceWalkingRunning)
        items.append(dd6)
        
        let distanceCycling:HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceCycling)!
        let dd7 = VitalModel.init(name:"Distance Cycling" , quantityType: distanceCycling)
        items.append(dd7)
        
        let basalEnergyBurned:HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.basalEnergyBurned)!
        let dd8 = VitalModel.init(name:"Basal Energy Burned" , quantityType: basalEnergyBurned)
        items.append(dd8)
        
        let height:HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
        let dd9 = VitalModel.init(name:"Height" , quantityType: height)
        items.append(dd9)
        
        let weight:HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        let dd10 = VitalModel.init(name:"Weight" , quantityType: weight)
        items.append(dd10)
        
        let oxygenSaturation:HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)!
        let dd11 = VitalModel.init(name:"Blood Oxygen" , quantityType: oxygenSaturation)
        items.append(dd11)
        
       
        if #available(iOS 14.0, *) {
            let ECG:HKObjectType = HKObjectType.electrocardiogramType()
            let dd12 = VitalModel.init(name: "ECG", quantityType: nil, objectType: ECG)
            items.append(dd12)
        } else {
            // Fallback on earlier versions
        }
        
        return items
    }
}

