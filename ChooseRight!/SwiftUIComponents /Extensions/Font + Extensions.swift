//
//  Font + Extensions.swift
//  ChooseRight!
//
//  SwiftUI Font extensions using system San Francisco. No bundled fonts needed.
//

import SwiftUI

extension Font {

    static func sfProTextBold12() -> Font {
        .system(size: 12, weight: .bold)
    }
    static func sfProTextBold33() -> Font {
        .system(size: 33, weight: .bold)
    }

    static func sfProTextMedium12() -> Font {
        .system(size: 12, weight: .medium)
    }
    static func sfProTextMedium16() -> Font {
        .system(size: 16, weight: .medium)
    }
    static func sfProTextMedium24() -> Font {
        .system(size: 24, weight: .medium)
    }

    static func sfProTextRegular11() -> Font {
        .system(size: 11, weight: .regular)
    }
    static func sfProTextRegular14() -> Font {
        .system(size: 14, weight: .regular)
    }
    static func sfProTextRegular16() -> Font {
        .system(size: 16, weight: .regular)
    }
    static func sfProTextRegular20() -> Font {
        .system(size: 20, weight: .regular)
    }
    static func sfProTextRegular23() -> Font {
        .system(size: 23, weight: .regular)
    }

    static func sfProTextSemibold33() -> Font {
        .system(size: 33, weight: .semibold)
    }
    static func sfProTextSemibold80() -> Font {
        .system(size: 80, weight: .semibold)
    }

    static func sfProDisplayRegular15() -> Font {
        .system(size: 15, weight: .regular)
    }
    static func sfProDisplaySemibold12() -> Font {
        .system(size: 12, weight: .semibold)
    }
    static func sfProDisplaySemibold15() -> Font {
        .system(size: 15, weight: .semibold)
    }
    static func SFProDisplayHeavy12() -> Font {
        .system(size: 12, weight: .heavy)
    }
}
