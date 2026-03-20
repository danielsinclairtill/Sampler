//
//  PlainTheme.swift
//  Sampler
//
//
//
//

import Foundation
import UIKit

class PlainTheme: Attributes {
    let colors: Colors = PlainTheme.Color()
    let dimensions: Dimensions = PlainTheme.Dimension()
    let fonts: Fonts = PlainTheme.Font()

    // MARK: Colors
    class Color: Colors {
        func primary() -> UIColor {
            return UIColor(named: "PlainPrimary")!
        }
        
        func primaryFill() -> UIColor {
            return UIColor(named: "PlainPrimaryFill")!
        }
        
        func secondary() -> UIColor {
            return UIColor(named: "PlainSecondary")!
        }
        
        func secondaryFill() -> UIColor {
            return UIColor(named: "PlainSecondaryFill")!
        }
        
        func temporary() -> UIColor {
            return UIColor(named: "PlainTemporary")!
        }
    }
    
    // MARK: Fonts
    class Font: Fonts {
        func primaryTitleLarge() -> UIFont {
            switch UIDevice.current.screenType {
            case .iPhones_4_4S, .iPhones_5_5s_5c_SE:
                return createDynamicFont(font: UIFont.boldSystemFont(ofSize: 15.0), style: .title1)
            default:
                return createDynamicFont(font: UIFont.boldSystemFont(ofSize: 18.0), style: .title1)
            }
        }
        
        func primaryTitle() -> UIFont {
            switch UIDevice.current.screenType {
            case .iPhones_4_4S, .iPhones_5_5s_5c_SE:
                return createDynamicFont(font: UIFont.boldSystemFont(ofSize: 13.0), style: .title1)
            default:
                return createDynamicFont(font: UIFont.boldSystemFont(ofSize: 15.0), style: .title1)
            }
        }

        func body() -> UIFont {
            switch UIDevice.current.screenType {
            case .iPhones_4_4S, .iPhones_5_5s_5c_SE:
                return createDynamicFont(font: UIFont.systemFont(ofSize: 11.0), style: .title2)
            default:
                return createDynamicFont(font: UIFont.systemFont(ofSize: 13.0), style: .title2)
            }
        }
        
        private func createDynamicFont(font: UIFont, style: UIFont.TextStyle) -> UIFont {
            return UIFontMetrics(forTextStyle: style).scaledFont(for: font)
        }
    }
    
    // MARK: Dimensions
    class Dimension: Dimensions {
        func photoCornerRadius() -> CGFloat {
            return 4.0
        }
        
        func tagCornerRadius() -> CGFloat {
            return 4.0
        }
        
        func avatarSizeSmall() -> CGFloat {
            return 30.0
        }
    }
}
