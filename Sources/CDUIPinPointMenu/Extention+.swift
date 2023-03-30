//
//  File.swift
//  
//
//  Created by Littlefox iOS Developer on 2023/03/30.
//

import UIKit


@inline(__always) public func getValueBy<T>(ipad : T,iphone : T) -> T{
    if UIDevice.current.userInterfaceIdiom == .pad{
        return ipad
    }else{
        return iphone
    }
}


public extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

public extension UIView {
    var endPosY: CGFloat {
        get{
            return self.frame.size.height + self.frame.origin.y
        }
    }
    var endPosX: CGFloat {
        get{
            return self.frame.size.width + self.frame.origin.x
        }
    }
    
    func addRound(cornerRadius: CGFloat,borderColor: UIColor ,borderWidth: CGFloat = 1) {
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.clipsToBounds = true
    }
}

public extension Int{
    var toCGFloat: CGFloat{
        CGFloat(self)
    }
}
