import UIKit

extension UIColor {
    
    static var busanifyColor: UIColor {
        get {
            var rgbValue: UInt64 = 0
            Scanner(string: "D12D7D").scanHexInt64(&rgbValue)
            
            let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
            
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
}
