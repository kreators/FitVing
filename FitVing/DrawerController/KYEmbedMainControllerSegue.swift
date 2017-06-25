
import UIKit

open class KYEmbedMainControllerSegue: UIStoryboardSegue {
    
    final override public func perform() {
        if let sourceViewController = source as? KYDrawerController {
            sourceViewController.mainViewController = destination as? UIViewController
        } else {
            assertionFailure("SourceViewController must be KYDrawerController!")
        }
    }
    
}
