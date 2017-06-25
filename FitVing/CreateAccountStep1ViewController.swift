
import UIKit

class CreateAccountStep1ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - UITapGesture
    
    @IBAction func imageTapped(recognizer: UITapGestureRecognizer) {
        performSegue(withIdentifier: "basicInfoSegue", sender: nil)
    }
}
