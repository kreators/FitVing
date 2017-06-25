
import UIKit
import Alamofire

class FriendsView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    fileprivate let leftFriendLabel = UILabel()
    fileprivate let centerFriendLabel = UILabel()
    fileprivate let rightFriendLabel = UILabel()
    fileprivate let leftStepsLabel = UILabel()
    fileprivate let centerStepsLabel = UILabel()
    fileprivate let rightStepsLabel = UILabel()
    fileprivate let leftFriendTurtleView = FriendsTurtleView()
    fileprivate let centerFriendTurtleView = FriendsTurtleView()
    fileprivate let rightFriendTurtleView = FriendsTurtleView()
    
    fileprivate var collectionView: UICollectionView? = nil
    
    var facebookFriends = [[String:String]]()
    var facebookFriendsSteps = [[String:String]]()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - Helpers
    
    func commonInit() {
        let textLabel = UILabel()
        textLabel.text = NSLocalizedString("FRIENDS' STATUS", comment: "FRIENDS' STATUS")
        textLabel.font = UIFont(name: "HelveticaNeue", size: 10.0)
        textLabel.textColor = UIColor.defaultDarkGrayColor()
        textLabel.textAlignment = .left
        textLabel.frame = CGRect(x: 25.0, y: 15.0, width: 100.0, height: 10.0)
        self.addSubview(textLabel)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 60, height: 76)
        layout.scrollDirection = .horizontal
        
        self.collectionView = UICollectionView(frame: CGRect(x: 0.0, y: self.bounds.midY - 30.0, width: UIScreen.main.bounds.width, height: 60.0 + 6.0 + 10.0), collectionViewLayout: layout)
        guard let collectionView = self.collectionView else {
            return
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "FriendsViewCell", bundle: nil), forCellWithReuseIdentifier: "friendsViewCell")
        collectionView.backgroundColor = UIColor.clear
        collectionView.isScrollEnabled = true
        collectionView.bounces = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        self.addSubview(collectionView)

        updateSteps()
        
        }
    
    func updateSteps() {
        guard FBSDKAccessToken.current() != nil else {
            return
        }
        let params = ["fields":"id,name"]
        let request = FBSDKGraphRequest(graphPath: "/me/friends", parameters: params, httpMethod: "GET")
        request?.start { (connection, result, error) -> Void in
            self.facebookFriends.removeAll()
            if let result = result as? Dictionary<String, Any> {
                if let data = result["data"] as? [Dictionary<String, String>] {
                    for friend in data {
                        self.facebookFriends.append(friend)
                    }
                    self.requestFacebookFriendSteps()
                }
            }
        }
    }

    func requestFacebookFriendSteps() {
        guard self.facebookFriends.count > 0 else {
            self.facebookFriendsSteps.removeAll()
            return
        }
        var friendIds = [String]()
        for friend in self.facebookFriends {
            if let id = friend["id"] {
                friendIds.append(id)
            }
        }
        let calendar = Calendar.current
        var todayComponent = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute], from: Date())
        todayComponent.hour = 0
        todayComponent.minute = 0
        let today = calendar.date(from: todayComponent)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")!
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let startDate = dateFormatter.string(from: today!)
        let params: [String:Any] = ["startDate":startDate, "friendIds": friendIds]
        Alamofire.request("https://gateway.tinyvect0r.com/api/v1/friendsteps", method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                self.facebookFriendsSteps.removeAll()
                if let JSON = response.result.value as? [String:Any] {
                    if let result = JSON["result"] as? String {
                        if result == "success" {
                            if let steps = JSON["data"] as? [[String:String]] {
                                for step in steps {
                                    self.facebookFriendsSteps.append(step)
                                }
                            }
                        }
                    }
                }
                self.collectionView?.reloadData()
        }
    }
    
    // MARK: - UICollectionView
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.facebookFriendsSteps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "friendsViewCell", for: indexPath) as! FriendsViewCell
        let step = self.facebookFriendsSteps[(indexPath as NSIndexPath).row]
        if let currentSteps = step["currentSteps"] as? Int {
            cell.stepsLabel.text = String(currentSteps)
        }
        if let facebookId = step["facebookId"] as? String {
            for facebookFriend in self.facebookFriends {
                if facebookId == facebookFriend["id"] {
                    cell.friendLabel.text = facebookFriend["name"]
                }
            }
        }
        if let targetSteps = step["targetSteps"] as? Int, let currentSteps = step["currentSteps"] as? Int {
            let progress = Double(currentSteps) / Double(targetSteps)
            cell.friendTurtleView.progress = progress
        }
        return cell
    }
}
