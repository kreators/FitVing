
import UIKit
import Alamofire
import PKHUD

class BankListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet fileprivate weak var differentBankButton: UIButton! {
        didSet {
            differentBankButton.setBackgroundImage(UIImage.fromColor(color: .defaultBlueColor()), for: .normal)
            differentBankButton.isHidden = true
        }
    }
    
    var banks = [[String:String?]]()
    var indexSelected = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestBankList()
    }
    
    // MARK: - Helpers
    
    fileprivate func requestBankList() {
        HUD.show(.progress)
        Alamofire.request("https://synapsepay.com/api/v3/institutions/show", method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
            if let JSON = response.result.value as? [String:Any] {
                if let banklist = JSON["banks"] as? [[String:String?]] {
                    for bank in banklist {
                        self.banks.append(bank)
                    }
                    self.collectionView.reloadData()
                }
            }
            HUD.hide()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func cancelPressed(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2.0, height: collectionView.bounds.width / 2.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return banks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bankCell", for: indexPath)
        if let imageView = cell.contentView.viewWithTag(100) as? UIImageView {
            let bank = banks[indexPath.row]
            if let url = bank["logo"] as? String {
                imageView.af_setImage(withURL: URL(string: url)!, placeholderImage: nil, filter: nil, imageTransition: .crossDissolve(0.2))
            }
        }
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        indexSelected = indexPath.row
        performSegue(withIdentifier: "bankIDRegisterSegue", sender: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bankIDRegisterSegue" {
            let vc = segue.destination as! BankIDRegisterViewController
            let bank = banks[indexSelected]
            if let bankCode = bank["bank_code"] {
                vc.bankCode = bankCode
            }
        }
    }
}
