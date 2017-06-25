
import UIKit

class SyncWearableDevicesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Helpers
    
    fileprivate func initUI() {
            self.navigationController?.navigationBar.isHidden = true
        
    }

    // MARK: - Actions
    
    @IBAction func cancelPressed(_ sender: UIButton) {
            self.navigationController?.popViewController(animated: true)
            self.navigationController?.navigationBar.isHidden = false
    }
}
