
import UIKit

class TopAlignedLabel: UILabel {
    
    override func drawText(in rect: CGRect) {
        var rect = rect
        let height: CGFloat = self.sizeThatFits(rect.size).height
        rect.size.height = height
        super.drawText(in: rect)
    }
}
