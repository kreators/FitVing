
import UIKit

class DailyDepositInformationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func closePressed(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
