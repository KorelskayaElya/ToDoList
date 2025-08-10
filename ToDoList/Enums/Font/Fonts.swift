//
//  Fonts.swift
//  ToDoList
//
//  Created by Эля Корельская on 04.08.2025.
//

import UIKit

/// Набор используемых в приложении шрифтов
enum Fonts {
    private static let defaultFont: UIFont = .systemFont(ofSize: 25)

    static func sfProDisplayBoldFont(size: CGFloat) -> UIFont {
        UIFont(name: "SFProDisplay-Bold", size: size) ?? defaultFont
    }
    
    static func sfProDisplayMediumFont(size: CGFloat) -> UIFont {
        UIFont(name: "SFProDisplay-Medium", size: size) ?? defaultFont
    }
    
    static func sfProDisplayLightFont(size: CGFloat) -> UIFont {
        UIFont(name: "SFProDisplay-Light", size: size) ?? defaultFont
    }
    
    static func sfProDisplayBlackFont(size: CGFloat) -> UIFont {
        UIFont(name: "SFProDisplay-Black", size: size) ?? defaultFont
    }
}

