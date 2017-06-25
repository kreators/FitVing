
import UIKit

class ViewController1: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func closePressed(_ recognizer: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
