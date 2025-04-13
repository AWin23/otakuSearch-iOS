//
//  Extensions.swift
//  otakuSearch-iOS
// UI color library of this OtakuSearch app
//  Created by Andrew Nguyen on 4/13/25.
//

import UIKit

extension UIColor {
    convenience init(hex: String) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }

    static let otakuDark = UIColor(hex: "#1b1919")
    static let otakuPink = UIColor(hex: "#db2d69")
    static let otakuGray = UIColor(hex: "#efecec")
    static let otakuRed = UIColor(hex: "#DB372D")
}
