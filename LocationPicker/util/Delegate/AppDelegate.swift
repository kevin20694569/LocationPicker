import UIKit
import CoreData
import SHFullscreenPopGestureSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        SHFullscreenPopGesture.configure()

        let navBarAppearance = UINavigationBarAppearance()
        let pointSize = UIFont.preferredFont(forTextStyle: .title3).pointSize
        navBarAppearance.titleTextAttributes = [
            .font : UIFont.systemFont(ofSize: pointSize, weight: .bold)
         ]
        var backButtonImage = UIImage(systemName: "chevron.backward", withConfiguration:  UIImage.SymbolConfiguration(font: UIFont.weightSystemSizeFont(systemFontStyle: .body, weight: .bold)))
        backButtonImage = backButtonImage?.withAlignmentRectInsets(UIEdgeInsets(top: 0 , left: -8, bottom: 0, right: 0)).withTintColor(.label, renderingMode: .alwaysOriginal)
        
        navBarAppearance.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)
        navBarAppearance.configureWithTransparentBackground()
        
        navBarAppearance.backButtonAppearance = UIBarButtonItemAppearance(style: .done)
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        return true
    }
    
    
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
        
    }
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "LocationPicker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

