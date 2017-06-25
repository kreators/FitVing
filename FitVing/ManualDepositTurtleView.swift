
import UIKit

class ManualDepositTurtleView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        print("DRAW")
        drawPolygonBezier(rect.midX,y: rect.midY,radius: rect.width/2, sides: 6, color: UIColor.defaultBlueColor())
    }
    
    // MARK: - Helpers
    
    func degree2radian(_ a:CGFloat)->CGFloat {
        let b = CGFloat(M_PI) * a/180
        return b
    }
    
    func polygonPointArray(_ sides:Int,x:CGFloat,y:CGFloat,radius:CGFloat)->[CGPoint] {
        let angle = degree2radian(360/CGFloat(sides))
        let cx = x
        let cy = y
        let r  = radius
        var i = 0
        var points = [CGPoint]()
        while i <= sides {
            let xpo = cx + r * cos(angle * CGFloat(i) - CGFloat(M_PI_2))
            let ypo = cy + r * sin(angle * CGFloat(i) - CGFloat(M_PI_2))
            points.append(CGPoint(x: xpo, y: ypo))
            i += 1;
        }
        return points
    }
    
    func polygonPath(_ x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int) -> CGPath {
        let path = CGMutablePath()
        let points = polygonPointArray(sides, x: x, y: y, radius: radius)
        
        var cpg = points[0]
        path.move(to: cpg)
        for p in points {
            path.addLine(to: p)
        }
        path.closeSubpath()
        return path
    }
    
    func drawPolygonBezier(_ x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int, color:UIColor) {
        let path = polygonPath(x, y: y, radius: radius - 3, sides: sides)
        
        let bez = UIBezierPath(cgPath: path)
        UIColor.white.setFill()
        bez.fill()
        color.setStroke()
        bez.lineWidth = 6.0
        bez.stroke()
    }
}
