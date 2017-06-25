
import UIKit

class SegmentView: UIView {
    
    fileprivate var segmentIndicatorViews = [UIView]()
    fileprivate var completion: ((Int) -> Void)? = nil
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let labels = self.subviews.filter({$0 is UILabel})
        let width = self.bounds.size.width / CGFloat(labels.count)
        for (index, subview) in self.subviews.enumerated() {
            if subview is UILabel {
                subview.frame.origin.x = CGFloat(index) * width
                subview.frame.size.width = width
                for indicatorView in subview.subviews {
                    indicatorView.frame.size.width = width
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func setSegments(_ titles: [String], completion:@escaping (Int)->Void) {
        self.segmentIndicatorViews.removeAll()
        for v in self.subviews {
            v.removeFromSuperview()
        }
        self.completion = completion
        let width = self.bounds.size.width / CGFloat(titles.count)
        for i in 0 ..< titles.count {
            let label = UILabel(frame: CGRect(x: 0.0 + width * CGFloat(i), y: 0.0, width: width, height: self.bounds.size.height))
            label.text = titles[i]
            label.font = UIFont(name: "HelveticaNeue-Medium", size: 15.0)
            label.textColor = UIColor.defaultBlueColor()
            label.textAlignment = .center
            label.tag = i
            self.addSubview(label)
            
            let indicatorView = UIView(frame: CGRect(x: 0.0, y: self.bounds.size.height - 3.0, width: width, height: 3.0))
            indicatorView.backgroundColor = UIColor.defaultBlueColor()
            indicatorView.tag = i
            label.addSubview(indicatorView)
            if i != 0 {
                indicatorView.isHidden = true
            }
            
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(SegmentView.segmentViewTapped(_:)))
            tap.numberOfTapsRequired = 1
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(tap)
            segmentIndicatorViews.append(indicatorView)

        }
    }
    
    func setSegmentIndex(_ segmentIndex: Int) {
        for view in self.segmentIndicatorViews {
            if view.tag == segmentIndex {
                view.isHidden = false
            }
            else {
                view.isHidden = true
            }
        }
        if self.completion != nil {
            completion!(segmentIndex)
        }
    }
    
    // MARK: - Actions
    
    func segmentViewTapped(_ recognizer: UITapGestureRecognizer) {
        for view in self.segmentIndicatorViews {
            if view.tag == recognizer.view!.tag {
                view.isHidden = false
            }
            else {
                view.isHidden = true
            }
        }
        if self.completion != nil {
            completion!(recognizer.view!.tag)
        }
    }
}
