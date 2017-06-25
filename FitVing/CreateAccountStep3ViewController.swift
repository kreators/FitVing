
import UIKit

class CreateAccountStep3ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITapGesture
    
    @IBAction func imageTapped(recognizer: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
