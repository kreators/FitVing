
import UIKit
import Fabric
import Crashlytics
import Flurry_iOS_SDK
import HealthKit
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let healthKitStore = HKHealthStore()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyA6Cq6iUn8TPLoRLNLjdeLeb-7e1UqFfIU")
        GMSPlacesClient.provideAPIKey("AIzaSyCFwEz2vL6EeO52q2-3nu6uBhAzFXUOFYo")
        Fabric.with([Crashlytics.self()])
        Flurry.startSession("BKJFQ986GC69FH9PGMPQ")
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        let sampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        healthKitStore.enableBackgroundDelivery(for: sampleType!, frequency: .immediate) { (success, error) in
            if success {
            }
        }
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?,        annotation: Any) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(
                application,
                open: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        FitVing.sharedInstance.lastdailybalanceAtCloud()
        completionHandler(.newData)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
}

