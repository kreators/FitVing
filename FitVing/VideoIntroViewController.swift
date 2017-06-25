
import UIKit
import AVFoundation
import AVKit

class VideoIntroViewController: UIViewController {
    
    var playerLooper: AVPlayerLooper?
    var playerLayer: AVPlayerLayer?
    var player: AVQueuePlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playIntroVideo()
    }
    
    // MARK: - Helpers
    
    fileprivate func initUI() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        self.view.addGestureRecognizer(tap)
    }
    
    fileprivate func playIntroVideo() {
        guard let videoFile = Bundle.main.path(forResource: "TortoiseIntro", ofType: "mov") else { return }

        let playerItem = AVPlayerItem(url: URL(fileURLWithPath: videoFile))
        self.player = AVQueuePlayer(items: [playerItem])
        self.playerLayer = AVPlayerLayer(player: player)
        if let player = self.player, let playerLayer = self.playerLayer {
            playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
            self.view.layer.addSublayer(playerLayer)
            playerLayer.frame = self.view.frame
            player.play()
        }
    }
    
    // MARK: - TapGestureRecognizer
    
    func tapped(_ recognizer: UITapGestureRecognizer) {
        self.player?.pause()
        self.performSegue(withIdentifier: "introSegue", sender: nil)
    }
}
