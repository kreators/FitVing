
import UIKit

open class KYEmbedDrawerControllerSegue: UIStoryboardSegue {
    
    final override public func perform() {
        if let sourceViewController = source as? KYDrawerController {
            sourceViewController.drawerViewController = destination as? UIViewController
        } else {
            assertionFailure("SourceViewController must be KYDrawerController!")
        }
    }
   
}
