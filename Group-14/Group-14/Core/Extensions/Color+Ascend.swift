//
//  Color+Ascend.swift
//  Group-14 — Core/Extensions
//
//  Ascend brand color palette — centralized so all views stay consistent.
//

import SwiftUI

extension Color {
    // MARK: - Primary Palette
    static let ascendPrimary      = Color(hue: 0.72, saturation: 0.82, brightness: 0.72)
    static let ascendAccent       = Color(hue: 0.77, saturation: 0.60, brightness: 0.90)
    static let ascendCoral        = Color(hue: 0.03, saturation: 0.75, brightness: 0.92)

    // MARK: - Background / Surface
    static let ascendBackground   = Color(hue: 0.72, saturation: 0.15, brightness: 0.10)
    static let ascendSurface      = Color(hue: 0.72, saturation: 0.18, brightness: 0.16)
    static let ascendCard         = Color(hue: 0.72, saturation: 0.20, brightness: 0.20)

    // MARK: - Text
    static let ascendTextPrimary   = Color.white
    static let ascendTextSecondary = Color(white: 0.70)

    // MARK: - Confidence gradient stops
    static let confidenceLow      = Color(hue: 0.03, saturation: 0.80, brightness: 0.85)
    static let confidenceMid      = Color(hue: 0.13, saturation: 0.85, brightness: 0.95)
    static let confidenceHigh     = Color(hue: 0.40, saturation: 0.75, brightness: 0.80)

    // MARK: - Track badges
    static let trackFinancial     = Color(hue: 0.55, saturation: 0.65, brightness: 0.75)
    static let trackTech          = Color(hue: 0.72, saturation: 0.70, brightness: 0.88)
}
